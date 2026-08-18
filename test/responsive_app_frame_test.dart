import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/main.dart';

void main() {
  Future<void> pumpFrame(
    WidgetTester tester, {
    required Size viewportSize,
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAppFrame(
          child: ColoredBox(
            key: Key('content'),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  testWidgets('uses all available width on a narrow screen', (tester) async {
    await pumpFrame(tester, viewportSize: const Size(320, 700));

    expect(tester.getSize(find.byKey(const Key('content'))).width, 320.0);
    expect(tester.getTopLeft(find.byKey(const Key('content'))).dx, 0.0);
  });

  testWidgets('centers and limits content on a wide screen', (tester) async {
    await pumpFrame(tester, viewportSize: const Size(1440, 900));

    expect(
      tester.getSize(find.byKey(const Key('content'))).width,
      ResponsiveAppFrame.maxContentWidth,
    );
    expect(tester.getTopLeft(find.byKey(const Key('content'))).dx, 360.0);
  });
}
