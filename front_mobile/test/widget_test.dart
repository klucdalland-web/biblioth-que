import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:get/get.dart';

/// Widget test isolé (sans Dio, GetStorage ni google_fonts).
void main() {
  tearDown(() {
    Get.reset();
  });

  testWidgets('OfflineBanner affiche le message hors ligne', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: OfflineBanner()),
      ),
    );

    expect(find.textContaining('hors ligne'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });

  testWidgets('ErrorBanner affiche le message et le bouton Réessayer',
      (tester) async {
    var retried = false;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: ErrorBanner(
            message: 'Erreur réseau simulée',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Erreur réseau simulée'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    expect(retried, isTrue);
  });
}
