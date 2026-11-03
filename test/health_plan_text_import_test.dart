import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_text_import.dart';

void main() {
  test('decodes a bounded UTF-8 text document', () {
    final imported = decodeHealthPlanTextDocument(
      fileName: 'fixture-plan.txt',
      bytes: Uint8List.fromList(utf8.encode('  Synthetic guidance  ')),
    );
    expect(imported.fileName, 'fixture-plan.txt');
    expect(imported.text, 'Synthetic guidance');
  });

  test('rejects unsupported, oversized, malformed and empty documents', () {
    expect(
      () => decodeHealthPlanTextDocument(
        fileName: 'fixture.pdf',
        bytes: Uint8List.fromList([1]),
      ),
      throwsA(isA<InvalidHealthPlanDocument>()),
    );
    expect(
      () => decodeHealthPlanTextDocument(
        fileName: 'fixture.txt',
        bytes: Uint8List(5),
        maximumBytes: 4,
      ),
      throwsA(isA<InvalidHealthPlanDocument>()),
    );
    expect(
      () => decodeHealthPlanTextDocument(
        fileName: 'fixture.md',
        bytes: Uint8List.fromList([0xC3, 0x28]),
      ),
      throwsA(isA<InvalidHealthPlanDocument>()),
    );
    expect(
      () => decodeHealthPlanTextDocument(
        fileName: 'fixture.txt',
        bytes: Uint8List.fromList(utf8.encode('  ')),
      ),
      throwsA(isA<InvalidHealthPlanDocument>()),
    );
  });
}
