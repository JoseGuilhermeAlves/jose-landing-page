import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 1600)}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox.fromSize(
            size: size,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  const domains = [
    DomainHighlight(
      id: 'fintech',
      label: 'Fintech',
      blurb: 'Credito mobile em escala.',
      icon: Icons.credit_card_outlined,
    ),
    DomainHighlight(
      id: 'retail',
      label: 'Varejo B2B',
      blurb: 'Operacao de loja, estoque e pedidos.',
      icon: Icons.storefront_outlined,
      scope: DomainScope.endToEnd,
    ),
  ];

  group('DomainsGrid', () {
    testWidgets('renderiza um card pra cada DomainHighlight', (tester) async {
      await tester.pumpWidget(wrap(const DomainsGrid(domains: domains)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Fintech'), findsOneWidget);
      expect(find.text('Varejo B2B'), findsOneWidget);
      expect(find.text('Credito mobile em escala.'), findsOneWidget);
    });

    testWidgets(
      'sinaliza visualmente o card end-to-end com badge "front end inteiro"',
      (tester) async {
        await tester.pumpWidget(wrap(const DomainsGrid(domains: domains)));
        await tester.pump(const Duration(milliseconds: 16));

        // Badge so aparece no card de varejo (DomainScope.endToEnd)
        expect(find.textContaining('front end inteiro'), findsOneWidget);
      },
    );

    testWidgets('mobile (<600): cards em uma unica coluna', (tester) async {
      await tester.pumpWidget(
        wrap(const DomainsGrid(domains: domains), size: const Size(360, 1200)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final rects = tester
          .widgetList<DomainCard>(find.byType(DomainCard))
          .map((w) => tester.getRect(find.byWidget(w)))
          .toList();
      // dois cards em coluna unica -> mesmo `left`
      expect((rects[0].left - rects[1].left).abs(), lessThan(2));
      expect(rects[1].top, greaterThan(rects[0].top));
    });

    testWidgets('lista vazia: nao lanca e nao renderiza cards', (tester) async {
      await tester.pumpWidget(wrap(const DomainsGrid(domains: [])));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(DomainCard), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
