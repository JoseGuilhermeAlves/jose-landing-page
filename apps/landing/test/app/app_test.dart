import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/app.dart';

void main() {
  group('LandingApp', () {
    testWidgets('builda sem lancar e aplica AppTheme dark', (tester) async {
      await tester.pumpWidget(const LandingApp());
      await tester.pump(const Duration(milliseconds: 32));

      expect(tester.takeException(), isNull);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);

      // tear down animacoes pendentes
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('expoe AppColors via Theme extension (sanity do design system)',
        (tester) async {
      await tester.pumpWidget(const LandingApp());
      await tester.pump(const Duration(milliseconds: 32));

      // Pega o BuildContext da Home — basta que `context.colors` resolva.
      final BuildContext ctx = tester.element(find.byKey(const Key('home-page')));
      expect(() => ctx.colors.primary, returnsNormally);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
