import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/flutter_flow/internationalization.dart';

void main() {
  test('the app only advertises the populated Russian locale', () {
    expect(FFLocalizations.languages(), const ['ru']);
  });

  test('missing translations fall back to Russian text', () {
    final localizations = FFLocalizations(const Locale('en'));

    expect(localizations.getText('rhoo2u3p'), 'Добро пожаловать в Сарафан');
    expect(
      localizations.getVariableText(ruText: 'Продолжить', enText: ''),
      'Продолжить',
    );
  });
}
