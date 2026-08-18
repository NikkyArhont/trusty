/// Normalizes free-form text before it is saved or sent.
///
/// Keeps intentional paragraphs, while removing accidental indentation,
/// repeated horizontal whitespace, excessive blank lines and trailing space.
String normalizeUserText(String value) {
  final normalizedLines = value
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n')
      .map((line) => line.trim().replaceAll(RegExp(r'[ \t\u00A0]+'), ' '))
      .join('\n');

  return normalizedLines.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
