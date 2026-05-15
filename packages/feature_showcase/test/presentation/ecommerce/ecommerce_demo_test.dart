import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // pumpAndSettle nao termina enquanto o `GaroaHeroBackdrop` esta em
  // loop infinito de animacao, entao todos os pumps neste arquivo sao
  // com `Duration` explicito.

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: child,
      );

  // Viewport mais alto pra que o grid featured (abaixo do hero +
  // categorias) caiba sem precisar scrollar nos taps. Default e
  // 800x600 e o grid comeca por volta de ~700px. setSurfaceSize so
  // pode ser chamado dentro de `testWidgets`, entao helper local.
  Future<void> useLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('EcommerceDemo (Garoa, multi-tela)', () {
    testWidgets(
      'home da marca renderiza ao menos 4 cards de produtos em destaque',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const EcommerceDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        // Featured tem 4 produtos (ver ProductsCatalog.featured).
        expect(
          find.byKey(const Key('ecommerce-product-card')),
          findsAtLeast(4),
        );
      },
    );

    testWidgets(
      'badge do contador nao aparece com carrinho vazio',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const EcommerceDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        expect(find.byKey(const Key('ecommerce-cart-count')), findsNothing);
      },
    );

    testWidgets(
      'tap em "+" do card faz aparecer o badge "1"',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const EcommerceDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(
          find.byKey(const Key('ecommerce-add-button')).first,
        );
        await tester.pump();

        final counter =
            tester.widget(find.byKey(const Key('ecommerce-cart-count')))
                as Text;
        expect(counter.data, '1');
      },
    );

    testWidgets(
      'tap no botao do carrinho abre o bottom sheet retematizado',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const EcommerceDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        // Adiciona um produto pra o sheet nao estar vazio.
        await tester.tap(
          find.byKey(const Key('ecommerce-add-button')).first,
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('ecommerce-cart-button')));
        // Aguarda a animacao do sheet — usar pump fixo em vez de
        // pumpAndSettle por causa do backdrop animado.
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byKey(const Key('ecommerce-cart-sheet')), findsOneWidget);
        expect(
          find.byKey(const Key('garoa-checkout-button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tap em card de produto empurra o detalhe com nome do produto',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const EcommerceDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        // Captura o nome do primeiro produto featured antes do tap pra
        // verificar que aparece na pagina de detalhe.
        final firstProduct = ProductsCatalog.featured.first;
        final cardFinder = find.byKey(const Key('ecommerce-product-card'));

        await tester.tap(cardFinder.first);
        // MaterialPageRoute leva ~300ms. Pumpamos varios frames pra
        // garantir que a route assenta — pumpAndSettle nao serve por
        // causa do backdrop animado infinito.
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text(firstProduct.name), findsAtLeast(1));
        expect(
          find.byKey(const Key('garoa-detail-add-to-cart')),
          findsOneWidget,
        );
      },
    );
  });
}
