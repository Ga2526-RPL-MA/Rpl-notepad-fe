import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/auth_landing_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/login_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flow integration', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.window.physicalSizeTestValue = const ui.Size(1080, 1920);
      binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        binding.window.clearPhysicalSizeTestValue();
        binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('AuthLandingPage shows expected UI', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AuthLandingPage()));

      await tester.pumpAndSettle();

      expect(find.text('Selamat datang di\nRPL Notepad'), findsOneWidget);
      expect(
        find.text('Eksplorasi catatan dan ide dari sesama mahasiswa RPL.'),
        findsOneWidget,
      );
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Daftar Akun'), findsOneWidget);
    });

    testWidgets('Tapping Masuk navigates to LoginPage and shows form', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthLandingPage()));

      await tester.pumpAndSettle();

      // Tap the Masuk button on landing page
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // Verify we are on LoginPage by checking unique title text
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('RPL Notepad'), findsOneWidget);

      // Verify form labels (scoped to LoginPage to avoid offstage matches)
      final loginPageFinder = find.byType(LoginPage);
      expect(
        find.descendant(of: loginPageFinder, matching: find.text('Email')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: loginPageFinder, matching: find.text('Kata sandi')),
        findsOneWidget,
      );

      // There should be two TextFields (email and password) within LoginPage
      expect(
        find.descendant(of: loginPageFinder, matching: find.byType(TextField)),
        findsNWidgets(2),
      );

      // And a login button labeled Masuk within LoginPage
      expect(
        find.descendant(of: loginPageFinder, matching: find.text('Masuk')),
        findsOneWidget,
      );

      // Test back navigation (no AppBar back button present)
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AuthLandingPage), findsOneWidget);
    });
  });
}
