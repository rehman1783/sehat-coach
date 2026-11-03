import 'dart:io';

class SecretFinding {
  const SecretFinding(this.path, this.reason);

  final String path;
  final String reason;

  @override
  String toString() => '$path: $reason';
}

final List<({String reason, RegExp pattern})> _contentRules = [
  (
    reason: 'private key material',
    pattern: RegExp(
      '-----BEGIN '
      r'(?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    ),
  ),
  (
    reason: 'service-account private key',
    pattern: RegExp(r'"private_key"\s*:\s*"-----BEGIN'),
  ),
  (
    reason: 'service-account credential document',
    pattern: RegExp(r'"type"\s*:\s*"service_account"'),
  ),
  (
    reason: 'OAuth client secret value',
    pattern: RegExp(r'"client_secret"\s*:\s*"[^"\s]{8,}"'),
  ),
  (reason: 'AWS access key', pattern: RegExp(r'\bAKIA[0-9A-Z]{16}\b')),
  (
    reason: 'GitHub access token',
    pattern: RegExp(r'\bgh[pousr]_[0-9A-Za-z]{20,}\b'),
  ),
  (
    reason: 'Slack access token',
    pattern: RegExp(r'\bxox[baprs]-[0-9A-Za-z-]{20,}\b'),
  ),
];

final Set<String> _excludedDirectories = {
  '.dart_tool',
  '.git',
  '.gradle',
  'build',
  'coverage',
  'ephemeral',
};

final Set<String> _textExtensions = {
  '.dart',
  '.gradle',
  '.html',
  '.java',
  '.js',
  '.json',
  '.kts',
  '.kt',
  '.md',
  '.properties',
  '.sh',
  '.toml',
  '.txt',
  '.xml',
  '.yaml',
  '.yml',
};

List<SecretFinding> scanRepositoryForSecrets(Directory root) {
  final findings = <SecretFinding>[];
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || _isExcluded(root, entity)) continue;
    final relativePath = _relativePath(root, entity);
    final fileName = entity.uri.pathSegments.last.toLowerCase();

    final sensitiveReason = _sensitiveFileReason(fileName);
    if (sensitiveReason != null) {
      findings.add(SecretFinding(relativePath, sensitiveReason));
      continue;
    }
    if (!_isTextFile(fileName) || entity.lengthSync() > 2 * 1024 * 1024) {
      continue;
    }

    String contents;
    try {
      contents = entity.readAsStringSync();
    } on FileSystemException {
      continue;
    }
    for (final rule in _contentRules) {
      if (rule.pattern.hasMatch(contents)) {
        findings.add(SecretFinding(relativePath, rule.reason));
      }
    }
  }
  return findings;
}

bool _isExcluded(Directory root, File file) {
  final relative = _relativePath(root, file);
  final segments = relative.split('/');
  return segments.any(_excludedDirectories.contains);
}

String _relativePath(Directory root, File file) {
  final rootPath = root.absolute.path.replaceAll('\\', '/');
  final filePath = file.absolute.path.replaceAll('\\', '/');
  return filePath.substring(rootPath.length + 1);
}

String? _sensitiveFileReason(String fileName) {
  if (fileName == 'key.properties') return 'Android signing configuration';
  if (fileName.endsWith('.jks') || fileName.endsWith('.keystore')) {
    return 'Android signing key';
  }
  if (fileName == '.env' ||
      (fileName.startsWith('.env.') && fileName != '.env.example')) {
    return 'local environment file';
  }
  if (fileName.contains('production-defines') && fileName.endsWith('.json')) {
    return 'production define file';
  }
  if ((fileName.contains('service-account') ||
          fileName.contains('service_account')) &&
      fileName.endsWith('.json')) {
    return 'service-account file';
  }
  return null;
}

bool _isTextFile(String fileName) {
  if (fileName == 'dockerfile' || fileName == 'makefile') return true;
  final dot = fileName.lastIndexOf('.');
  return dot >= 0 && _textExtensions.contains(fileName.substring(dot));
}
