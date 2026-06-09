import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // O hero, o mini-mapa e o backdrop tem animacoes em loop infinito,
  // entao todos os pumps usam Duration explicito — pumpAndSettle nunca
  // terminaria.

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: child,
  );

  Future<void> useLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Abre a banca do Seu Mario a partir da home.
  Future<void> openVendorMario(WidgetTester tester) async {
    await tester.pumpWidget(wrap(const DeliveryDemo()));
    await tester.pump(const Duration(milliseconds: 16));

    final card = find.byKey(const Key('aurora-vendor-card-v-mario'));
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(card);
    await settle(tester);
    expect(find.text('Produtos'), findsOneWidget);
  }

  group('Aurora — item detail sheet', () {
    testWidgets(
      'tap no card do produto abre o sheet com descricao e botao adicionar',
      (tester) async {
        await useLargeSurface(tester);
        await openVendorMario(tester);

        final product = find.byKey(const Key('aurora-product-card-i-banana'));
        await tester.ensureVisible(product);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.tap(product);
        await settle(tester);

        // Sheet aberto: descricao longa e CTA de adicionar presentes.
        expect(find.byKey(const Key('aurora-item-sheet-add')), findsOneWidget);
        expect(find.text('Quantidade'), findsOneWidget);
      },
    );

    testWidgets('adicionar pelo sheet popula a barra de carrinho', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await openVendorMario(tester);

      final product = find.byKey(const Key('aurora-product-card-i-banana'));
      await tester.ensureVisible(product);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(product);
      await settle(tester);

      // Sobe a quantidade pra 2 e adiciona.
      await tester.tap(find.byKey(const Key('aurora-item-sheet-increment')));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(find.byKey(const Key('aurora-item-sheet-add')));
      await settle(tester);

      // De volta no detalhe da banca, a barra de carrinho aparece.
      expect(find.byKey(const Key('aurora-cart-bar')), findsOneWidget);
    });
  });

  group('Aurora — checkout', () {
    /// Adiciona a banana ao carrinho (via botao + do card) e avanca pro
    /// checkout.
    Future<void> reachCheckout(WidgetTester tester) async {
      await openVendorMario(tester);

      // Adiciona pelo botao "+" do card (sem abrir o sheet).
      final addButtons = find.byKey(const Key('aurora-add-item'));
      await tester.ensureVisible(addButtons.first);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(addButtons.first);
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('aurora-cart-bar')));
      await settle(tester);
    }

    testWidgets('cart bar leva ao checkout com endereco, pagamento e resumo', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await reachCheckout(tester);

      expect(find.text('Revisar pedido'), findsOneWidget);
      expect(
        find.byKey(const Key('aurora-checkout-address-addr-casa')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('aurora-checkout-payment-pay-pix')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('aurora-checkout-confirm')),
        findsOneWidget,
      );
    });

    testWidgets(
      'confirmar pedido cria o pedido e abre o detalhe com a timeline',
      (tester) async {
        await useLargeSurface(tester);
        await reachCheckout(tester);

        // Escolhe outro endereco + pagamento + observacao.
        await tester.tap(
          find.byKey(const Key('aurora-checkout-address-addr-mae')),
        );
        await tester.pump(const Duration(milliseconds: 16));
        await tester.tap(
          find.byKey(const Key('aurora-checkout-payment-pay-credito')),
        );
        await tester.pump(const Duration(milliseconds: 16));
        await tester.tap(find.byKey(const Key('aurora-checkout-note-1')));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(find.byKey(const Key('aurora-checkout-confirm')));
        await settle(tester);

        // Caiu no detalhe do pedido (timeline com os status).
        expect(find.text(DeliveryStatus.received.label), findsOneWidget);
        expect(find.text(DeliveryStatus.delivered.label), findsOneWidget);
      },
    );

    testWidgets('voltar do checkout retorna ao detalhe da banca', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await reachCheckout(tester);
      expect(find.text('Revisar pedido'), findsOneWidget);

      // Back do AppBar volta pra banca (Produtos), nao avanca o pedido.
      // Toca direto no BackButton inserido pela AppBar (pageBack do
      // tester espera um back button materializado e e fragil com
      // navigators aninhados — o tap explicito e mais robusto).
      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.text('Produtos'), findsOneWidget);
    });
  });
}
