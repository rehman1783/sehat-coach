import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/platform_application_data_directory.dart';

void main() {
  late Directory temporary;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('sehat-app-data-test-');
  });

  tearDown(() async {
    if (await temporary.exists()) await temporary.delete(recursive: true);
  });

  test('creates and returns the versioned private account root', () async {
    final directory = await PlatformApplicationDataDirectory(
      lookup: () async => temporary,
    ).resolve();

    expect(directory.isAbsolute, isTrue);
    expect(await directory.exists(), isTrue);
    expect(
      directory.path,
      endsWith(
        '${Platform.pathSeparator}sehat_coach'
        '${Platform.pathSeparator}accounts_v1',
      ),
    );
  });

  test('reuses an existing account root without replacing its data', () async {
    final resolver = PlatformApplicationDataDirectory(
      lookup: () async => temporary,
    );
    final directory = await resolver.resolve();
    final marker = File('${directory.path}${Platform.pathSeparator}marker');
    await marker.writeAsString('preserve');

    final second = await resolver.resolve();

    expect(second.path, directory.path);
    expect(await marker.readAsString(), 'preserve');
  });

  test('rejects a relative provider path', () async {
    final resolver = PlatformApplicationDataDirectory(
      lookup: () async => Directory('relative-support'),
    );

    await expectLater(resolver.resolve(), throwsA(isA<FileSystemException>()));
  });

  test('fails closed when the reserved root is a file', () async {
    final reserved = File(
      '${temporary.path}${Platform.pathSeparator}sehat_coach'
      '${Platform.pathSeparator}accounts_v1',
    );
    await reserved.parent.create(recursive: true);
    await reserved.writeAsString('not a directory');
    final resolver = PlatformApplicationDataDirectory(
      lookup: () async => temporary,
    );

    await expectLater(resolver.resolve(), throwsA(isA<FileSystemException>()));
  });
}
