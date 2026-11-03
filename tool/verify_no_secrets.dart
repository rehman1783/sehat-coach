import 'dart:io';

import 'secret_hygiene.dart';

void main() {
  final findings = scanRepositoryForSecrets(Directory.current);
  if (findings.isEmpty) {
    stdout.writeln('Secret hygiene check passed.');
    return;
  }

  stderr.writeln('Secret hygiene check failed:');
  for (final finding in findings) {
    stderr.writeln('- $finding');
  }
  exitCode = 1;
}
