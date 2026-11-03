import 'package:flutter/foundation.dart';

typedef DiagnosticSink = void Function(String message);

/// Emits bounded event identifiers only; arbitrary payloads and exceptions are
/// deliberately not part of this API.
class PrivacySafeDiagnostics {
  PrivacySafeDiagnostics({bool? enabled, DiagnosticSink? sink})
    : enabled = enabled ?? kDebugMode,
      _sink = sink ?? debugPrint;

  static final RegExp _validEventCode = RegExp(
    r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$',
  );

  final bool enabled;
  final DiagnosticSink _sink;

  void event(String code) {
    if (code.length > 64 || !_validEventCode.hasMatch(code)) {
      throw ArgumentError.value(code, 'code', 'Use a bounded event identifier');
    }
    if (enabled) {
      _sink('sehat_coach:$code');
    }
  }
}

final PrivacySafeDiagnostics privacySafeDiagnostics = PrivacySafeDiagnostics();
