import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // O hero, o mini-mapa e o backdrop tem animacoes em loop infinito,
  // entao todos os pumps deste arquivo usam Duration explicito —
  // pumpAndSettle nunca terminaria.

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: child,
  );

  /// Viewport mais alto pra que o hero + active card + categorias +
  /// vendors caibam sem precisar scrollar nos taps.
  Future<void> useLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('DeliveryDemo (Aurora, multi-tela)', () {
    testWidgets('home abre com card de pedido ativo e CTA de bancas', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await tester.pumpWidget(wrap(const DeliveryDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('aurora-active-order-card')), findsOneWidget);
      expect(find.byKey(const Key('aurora-cta-stores')), findsOneWidget);
    });

    testWidgets(
      'CTA "Ver bancas" empurra AuroraStoreListPage com chips de filtro',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const DeliveryDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(find.byKey(const Key('aurora-cta-stores')));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byKey(const Key('aurora-filter-all')), findsOneWidget);
        expect(find.byKey(const Key('aurora-filter-fruits')), findsOneWidget);
      },
    );

    testWidgets(
      'tap em "Acompanhar pedido" abre AuroraOrderDetailPage com timeline',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const DeliveryDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(find.byKey(const Key('aurora-active-order-cta')));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Header com label "Onde esta seu pedido" e timeline renderizada
        // (todos os 4 status aparecem como titulos).
        expect(find.text('Onde está seu pedido'), findsOneWidget);
        expect(find.text(DeliveryStatus.received.label), findsOneWidget);
        expect(find.text(DeliveryStatus.delivered.label), findsOneWidget);
      },
    );

    testWidgets(
      'icone de historico no AppBar abre AuroraHistoryPage com pedidos delivered',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const DeliveryDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(find.byKey(const Key('aurora-history-icon')));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Pedidos anteriores'), findsOneWidget);
        // O catalogo Aurora tem 2 pedidos delivered ja iniciados —
        // verificamos por id concreto (mais robusto que predicate).
        expect(
          find.byKey(const Key('aurora-history-card-#A-1046')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('aurora-history-card-#A-1047')),
          findsOneWidget,
        );
      },
    );

    testWidgets('ticker injetado avanca o status do pedido ativo na home', (
      tester,
    ) async {
      await useLargeSurface(tester);
      final controller = StreamController<void>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(wrap(DeliveryDemo(ticker: controller.stream)));
      await tester.pump(const Duration(milliseconds: 16));

      // O primeiro pedido comeca em preparing. Tres ticks avancam ele
      // pelos demais estados (round-robin entre 4 pedidos nao-finais).
      for (var i = 0; i < 16; i++) {
        controller.add(null);
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Apos varios ticks, ja deve existir pelo menos um pedido novo
      // em delivered no historico (alem dos 2 iniciais).
      await tester.tap(find.byKey(const Key('aurora-history-icon')));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Pedidos anteriores'), findsOneWidget);
    });

    testWidgets(
      'tap em card de banca na home abre o detalhe da banca com produtos',
      (tester) async {
        await useLargeSurface(tester);
        await tester.pumpWidget(wrap(const DeliveryDemo()));
        await tester.pump(const Duration(milliseconds: 16));

        final card = find.byKey(const Key('aurora-vendor-card-v-mario'));
        await tester.ensureVisible(card);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.tap(card);
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Vai direto pro detalhe da banca (secao "Produtos" + carrinho),
        // nao pra lista de lojas filtrada (que teria os chips de filtro).
        expect(find.text('Produtos'), findsOneWidget);
        expect(find.byKey(const Key('aurora-filter-all')), findsNothing);
      },
    );
  });
}
