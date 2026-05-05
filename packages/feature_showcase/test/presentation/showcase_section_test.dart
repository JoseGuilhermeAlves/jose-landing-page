import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  group('ShowcaseSection', () {
    testWidgets('renderiza um ShowcaseCard pra cada nicho do catalogo',
        (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byType(ShowcaseCard),
        findsNWidgets(ShowcaseCatalog.all.length),
      );
    });

    testWidgets('templates sem demo mostram badge "em breve"', (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // 2 dos 5 templates ainda sem demo (fitness, imobiliaria).
      expect(
        find.textContaining('em breve'),
        findsNWidgets(2),
      );
    });

    testWidgets('tap no card de e-commerce abre o EcommerceDemo em modal',
        (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('showcase-card-ecommerce')));
      await tester.pumpAndSettle();

      expect(find.byType(EcommerceDemo), findsOneWidget);
    });

    testWidgets('tap no card de delivery abre o DeliveryDemo em modal',
        (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('showcase-card-delivery')));
      await tester.pumpAndSettle();

      expect(find.byType(DeliveryDemo), findsOneWidget);
    });

    testWidgets('tap no card de scheduling abre o SchedulingDemo em modal',
        (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // Scheduling fica em row 2 do grid no viewport de teste (800px),
      // entao precisa rolar pra ficar dentro da hit area antes do tap.
      final card = find.byKey(const Key('showcase-card-scheduling'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.byType(SchedulingDemo), findsOneWidget);
    });

    testWidgets('tap em card sem demo (fitness) nao abre modal',
        (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      final card = find.byKey(const Key('showcase-card-fitness'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.byType(EcommerceDemo), findsNothing);
      expect(find.byType(DeliveryDemo), findsNothing);
      expect(find.byType(SchedulingDemo), findsNothing);
    });
  });
}
