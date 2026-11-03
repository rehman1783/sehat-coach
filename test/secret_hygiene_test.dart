import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/secret_hygiene.dart';

void main() {
  test(
    'repository contains no server credentials or private signing files',
    () {
      expect(scanRepositoryForSecrets(Directory.current), isEmpty);
    },
  );

  test('scanner detects sensitive content and filenames', () {
    final root = Directory.systemTemp.createTempSync('sehat-secret-scan-');
    addTearDown(() => root.deleteSync(recursive: true));
    File('${root.path}/leaked.txt').writeAsStringSync(
      '-----BEGIN '
      'PRIVATE KEY-----\nnot-a-real-key',
    );
    File('${root.path}/service-account-prod.json').writeAsStringSync('{}');

    final findings = scanRepositoryForSecrets(root);

    expect(findings, hasLength(2));
    expect(
      findings.map((finding) => finding.reason),
      containsAll(['private key material', 'service-account file']),
    );
  });

  test('scanner ignores generated directories and safe examples', () {
    final root = Directory.systemTemp.createTempSync('sehat-secret-scan-');
    addTearDown(() => root.deleteSync(recursive: true));
    Directory('${root.path}/build').createSync();
    File('${root.path}/build/key.properties').writeAsStringSync('generated');
    File('${root.path}/.env.example').writeAsStringSync('NAME=placeholder');

    expect(scanRepositoryForSecrets(root), isEmpty);
  });
}
