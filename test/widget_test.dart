import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerala_soil_erosion_monitor/core/constants/app_constants.dart';
import 'package:kerala_soil_erosion_monitor/main.dart';

void main() {
  testWidgets('KeralaSoilErosionApp basic smoke test', (WidgetTester tester) async {
    // Build app within ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: KeralaSoilErosionApp(),
      ),
    );

    // Initial pump shows MaterialApp with Kerala title
    expect(find.byType(MaterialApp), findsOneWidget);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, AppConstants.appName);
  });
}
