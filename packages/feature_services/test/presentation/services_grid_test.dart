import 'package:design_system/design_system.dart';
import 'package:feature_services/feature_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 1200)}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
  }

  group('ServicesGrid', () {
    testWidgets('renderiza um ServiceCard pra cada servico do catalogo', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ServicesGrid()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byType(ServiceCard),
        findsNWidgets(ServicesCatalog.all.length),
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mobile (<600): cards em uma unica coluna', (tester) async {
      await tester.pumpWidget(
        wrap(const ServicesGrid(), size: const Size(360, 1600)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final cards = tester.widgetList<ServiceCard>(find.byType(ServiceCard));
      final rects = cards.map((c) => tester.getRect(find.byWidget(c))).toList();

      // Todos os cards comecam na mesma coluna (left aprox igual).
      final firstLeft = rects.first.left;
      for (final r in rects.skip(1)) {
        expect((r.left - firstLeft).abs(), lessThan(2));
        // E cada card subsequente esta abaixo do anterior.
        expect(r.top, greaterThan(rects.first.top));
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('desktop (>=900): cards em multi-coluna lado a lado', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ServicesGrid()));
      await tester.pump(const Duration(milliseconds: 16));

      final cards = tester.widgetList<ServiceCard>(find.byType(ServiceCard));
      final rects = cards.map((c) => tester.getRect(find.byWidget(c))).toList();

      // Pelo menos dois cards compartilham aprox a mesma linha (top igual).
      var sameRowPair = false;
      for (var i = 0; i < rects.length; i++) {
        for (var j = i + 1; j < rects.length; j++) {
          if ((rects[i].top - rects[j].top).abs() < 4 &&
              (rects[i].left - rects[j].left).abs() > 4) {
            sameRowPair = true;
          }
        }
      }
      expect(
        sameRowPair,
        isTrue,
        reason: 'desktop deveria render cards lado a lado',
      );

      await tester.pumpWidget(const SizedBox());
    });
  });
}
