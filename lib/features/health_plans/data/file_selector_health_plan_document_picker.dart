import 'package:file_selector/file_selector.dart';

import '../domain/health_plan_text_import.dart';

class FileSelectorHealthPlanDocumentPicker implements HealthPlanDocumentPicker {
  const FileSelectorHealthPlanDocumentPicker();

  static const _textDocuments = XTypeGroup(
    label: 'Text health plans',
    extensions: ['txt', 'md'],
    mimeTypes: ['text/plain', 'text/markdown'],
    uniformTypeIdentifiers: [
      'public.plain-text',
      'net.daringfireball.markdown',
    ],
    webWildCards: ['text/plain', 'text/markdown'],
  );

  @override
  Future<ImportedHealthPlanText?> pickTextDocument() async {
    final file = await openFile(acceptedTypeGroups: const [_textDocuments]);
    if (file == null) return null;
    return decodeHealthPlanTextDocument(
      fileName: file.name,
      bytes: await file.readAsBytes(),
    );
  }
}
