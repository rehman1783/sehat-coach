import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef ApplicationSupportDirectoryLookup = Future<Directory> Function();

/// Resolves the private, OS-managed root used for encrypted account storage.
///
/// Callers receive an app-owned subdirectory rather than the provider root, so
/// account data never relies on a working directory or a guessed device path.
class PlatformApplicationDataDirectory {
  PlatformApplicationDataDirectory({
    ApplicationSupportDirectoryLookup? lookup,
  }) : _lookup = lookup ?? getApplicationSupportDirectory;

  final ApplicationSupportDirectoryLookup _lookup;

  Future<Directory> resolve() async {
    final support = await _lookup();
    if (support.path.trim().isEmpty || !support.isAbsolute) {
      throw FileSystemException(
        'Application support directory must be an absolute path.',
        support.path,
      );
    }

    final root = Directory(
      '${support.path}${Platform.pathSeparator}sehat_coach${Platform.pathSeparator}accounts_v1',
    );
    final entityType = await FileSystemEntity.type(root.path, followLinks: false);
    if (entityType != FileSystemEntityType.notFound &&
        entityType != FileSystemEntityType.directory) {
      throw FileSystemException(
        'Encrypted account storage root is not a directory.',
        root.path,
      );
    }
    if (entityType == FileSystemEntityType.notFound) {
      await root.create(recursive: true);
    }
    return root.absolute;
  }
}
