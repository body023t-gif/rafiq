import 'dart:convert';

/// Repairs UTF-8 text that was incorrectly decoded as Latin-1 (common with Dio).
String repairUtf8Text(String text) {
  if (text.isEmpty) return text;

  final looksCorrupted = text.contains('Ø') ||
      text.contains('Ù') ||
      text.contains('Ø§') ||
      text.contains('Ã');

  if (!looksCorrupted) return text;

  try {
    final bytes = text.codeUnits.map((codeUnit) => codeUnit & 0xFF).toList();
    return utf8.decode(bytes);
  } catch (_) {
    return text;
  }
}
