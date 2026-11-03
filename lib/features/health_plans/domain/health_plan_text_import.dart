import 'dart:convert';
import 'dart:typed_data';

class ImportedHealthPlanText {
  const ImportedHealthPlanText({required this.fileName, required this.text});
  final String fileName;
  final String text;
}

abstract interface class HealthPlanDocumentPicker {
  Future<ImportedHealthPlanText?> pickTextDocument();
}

class InvalidHealthPlanDocument implements Exception {
  const InvalidHealthPlanDocument(this.message);
  final String message;
}

ImportedHealthPlanText decodeHealthPlanTextDocument({
  required String fileName,
  required Uint8List bytes,
  int maximumBytes = 1024 * 1024,
}) {
  final normalizedName = fileName.trim();
  final extension = normalizedName.contains('.')
      ? normalizedName.split('.').last.toLowerCase()
      : '';
  if (!const {'txt', 'md'}.contains(extension)) {
    throw const InvalidHealthPlanDocument(
      'Only plain-text or Markdown documents are supported',
    );
  }
  if (bytes.isEmpty || bytes.length > maximumBytes) {
    throw const InvalidHealthPlanDocument(
      'Document must be non-empty and no larger than 1 MB',
    );
  }
  late final String text;
  try {
    text = utf8
        .decode(bytes, allowMalformed: false)
        .replaceAll('\u0000', '')
        .trim();
  } on FormatException {
    throw const InvalidHealthPlanDocument('Document must use UTF-8 text');
  }
  if (text.isEmpty) {
    throw const InvalidHealthPlanDocument('Document contains no readable text');
  }
  return ImportedHealthPlanText(fileName: normalizedName, text: text);
}
