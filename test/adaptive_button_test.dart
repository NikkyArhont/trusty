import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/flutter_flow/flutter_flow_widgets.dart';

void main() {
  testWidgets('FFButton grows instead of clipping at a large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: FFButtonWidget(
              text: 'Продолжить через Telegram',
              onPressed: () {},
              options: const FFButtonOptions(
                width: 260,
                height: 40,
                textStyle: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ElevatedButton)).height, greaterThan(40));
  });
}
