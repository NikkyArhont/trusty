import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/main.dart';

void main() {
  testWidgets('tap outside dismisses the active text field', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: DismissKeyboardOnTapOutside(
          child: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const Expanded(
                  child: ColoredBox(key: Key('outside'), color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(100.0, 300.0));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}
