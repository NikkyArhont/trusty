import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/flutter_flow/text_normalization.dart';

void main() {
  test('collapses repeated spaces and trims every line', () {
    expect(
      normalizeUserText('  Привет,   меня зовут Анна.  \n  Я мастер.  '),
      'Привет, меня зовут Анна.\nЯ мастер.',
    );
  });

  test('keeps at most one blank line between paragraphs', () {
    expect(
      normalizeUserText('Первый абзац.\n \n\n\n  Второй абзац.'),
      'Первый абзац.\n\nВторой абзац.',
    );
  });

  test('removes all whitespace and empty lines after the text', () {
    expect(normalizeUserText('Текст.   \n\n   \n\t'), 'Текст.');
  });

  test('normalizes Windows newlines and non-breaking spaces', () {
    expect(
      normalizeUserText('Один\u00A0\u00A0два\r\n\r\nТри'),
      'Один два\n\nТри',
    );
  });
}
