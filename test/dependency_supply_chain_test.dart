import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('direct dependencies use bounded registry or Flutter SDK sources', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('\ndependency_overrides:')));
    expect(
      RegExp(r'^\s+(?:git|path):\s*\S*', multiLine: true).hasMatch(pubspec),
      isFalse,
      reason: 'Git/path packages require explicit security review.',
    );
    expect(
      RegExp(
        r'^\s{2}[a-zA-Z0-9_]+:\s+any\s*$',
        multiLine: true,
      ).hasMatch(pubspec),
      isFalse,
      reason: 'Direct packages must not use an unbounded any constraint.',
    );
  });

  test('CI actions are pinned to immutable commit hashes', () {
    final workflow = File('.github/workflows/flutter_checks.yml')
        .readAsStringSync();
    final actionReferences = RegExp(
      r'^\s*-\s+uses:\s+([^\s#]+)',
      multiLine: true,
    ).allMatches(workflow).map((match) => match.group(1)!).toList();

    expect(actionReferences, isNotEmpty);
    for (final reference in actionReferences) {
      expect(
        reference,
        matches(RegExp(r'^[^@\s]+@[0-9a-f]{40}$')),
        reason: '$reference is mutable or is not pinned to a full commit.',
      );
    }
    expect(workflow, contains('permissions:\n  contents: read'));
    expect(
      workflow,
      contains(
        'flutter build apk --debug --target lib/consumer_main.dart --no-pub',
      ),
      reason: 'CI must compile the real Android consumer entry point.',
    );
  });

  test('scheduled update monitoring covers every package ecosystem', () {
    final dependabot = File('.github/dependabot.yml').readAsStringSync();

    for (final ecosystem in ['pub', 'gradle', 'github-actions']) {
      expect(dependabot, contains('package-ecosystem: $ecosystem'));
    }
    expect(RegExp(r'interval:\s+weekly').allMatches(dependabot), hasLength(3));
  });
}
