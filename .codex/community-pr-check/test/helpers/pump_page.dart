// Test helper that pumps a full page inside the themed MaterialApp at a
// chosen logical screen size and text scale, and resets the view afterwards.
import 'package:chapter_no/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpPage on WidgetTester {
  Future<void> pumpPage(
    Widget page, {
    Size size = const Size(400, 800),
    double textScale = 1,
    TargetPlatform platform = TargetPlatform.android,
  }) async {
    view.devicePixelRatio = 1;
    view.physicalSize = size;
    platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(view.reset);
    addTearDown(platformDispatcher.clearAllTestValues);
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light().copyWith(platform: platform),
        home: page,
      ),
    );
  }
}
