import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: child),
      );

  group('EcommerceDemo', () {
    testWidgets('renderiza um card pra cada produto do catalogo',
        (tester) async {
      await tester.pumpWidget(wrap(const EcommerceDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      // Pelo menos 6 produtos no catalogo
      expect(
        find.byKey(const Key('ecommerce-product-card')),
        findsAtLeast(6),
      );
    });

    testWidgets('contador do carrinho comeca em 0', (tester) async {
      await tester.pumpWidget(wrap(const EcommerceDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('ecommerce-cart-count')), findsOneWidget);
      expect(
        (tester.widget(find.byKey(const Key('ecommerce-cart-count'))) as Text)
            .data,
        '0',
      );
    });

    testWidgets('tap em "adicionar" incrementa o carrinho', (tester) async {
      await tester.pumpWidget(wrap(const EcommerceDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(
        find.byKey(const Key('ecommerce-add-button')).first,
      );
      await tester.pump();

      expect(
        (tester.widget(find.byKey(const Key('ecommerce-cart-count'))) as Text)
            .data,
        '1',
      );
    });

    testWidgets(
      'tap no botao do carrinho abre bottom sheet com itens e total',
      (tester) async {
        await tester.pumpWidget(wrap(const EcommerceDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(find.byKey(const Key('ecommerce-add-button')).first);
        await tester.pump();

        await tester.tap(find.byKey(const Key('ecommerce-cart-button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('ecommerce-cart-sheet')), findsOneWidget);
        expect(find.textContaining(r'R$'), findsWidgets);
      },
    );
  });
}
