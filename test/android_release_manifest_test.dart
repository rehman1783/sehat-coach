import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'release manifest permits HTTPS networking and disables data backup',
    () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();

      expect(_permissions(manifest), {
        'android.permission.INTERNET',
      }, reason: 'V1 must not silently add sensitive Android permissions.');
      expect(manifest, contains('android:usesCleartextTraffic="false"'));
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, contains('android:fullBackupContent="false"'));
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
    },
  );

  test('Android 12 extraction rules exclude every account-data domain', () {
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
        .readAsStringSync();

    for (final section in ['cloud-backup', 'device-transfer']) {
      final match = RegExp('<$section>([\\s\\S]*?)</$section>')
          .firstMatch(rules);
      expect(match, isNotNull);
      final body = match!.group(1)!;
      for (final domain in [
        'root',
        'file',
        'database',
        'sharedpref',
        'external',
        'device_root',
        'device_file',
        'device_database',
        'device_sharedpref',
      ]) {
        expect(body, contains('domain="$domain" path="."'));
      }
    }
  });

  test('release activity protects health screens from platform capture', () {
    final activity = File(
      'android/app/src/main/kotlin/com/example/sehat_coach/MainActivity.kt',
    ).readAsStringSync();

    expect(activity, contains('if (!BuildConfig.DEBUG)'));
    expect(
      activity,
      contains('window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)'),
    );
  });
}

Set<String> _permissions(String manifest) =>
    RegExp(r'<uses-permission\s+android:name="([^"]+)"\s*/>')
        .allMatches(manifest)
        .map((match) => match.group(1)!)
        .toSet();
