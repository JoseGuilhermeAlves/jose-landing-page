import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: child,
      );

  group('DeliveryDemo', () {
    testWidgets('renderiza um card pra cada pedido do catalogo',
        (tester) async {
      await tester.pumpWidget(wrap(const DeliveryDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byKey(const Key('delivery-order-card')),
        findsAtLeast(6),
      );
    });

    testWidgets('mostra label do status atual em cada card', (tester) async {
      await tester.pumpWidget(wrap(const DeliveryDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      // Todos comecam em "Recebido"
      expect(
        find.text(DeliveryStatus.received.label),
        findsAtLeast(6),
      );
    });

    testWidgets(
      'avancar manualmente via Bloc com ticker injetado muda os status',
      (tester) async {
        final controller = StreamController<void>.broadcast();
        addTearDown(controller.close);

        await tester.pumpWidget(
          wrap(DeliveryDemo(ticker: controller.stream)),
        );
        await tester.pump(const Duration(milliseconds: 16));

        controller.add(null);
        await tester.pump(const Duration(milliseconds: 50));

        // Pelo menos um card agora mostra "Em preparo"
        expect(find.text(DeliveryStatus.preparing.label), findsAtLeast(1));
      },
    );

    testWidgets('botao "reset" volta todos os pedidos pra Recebido',
        (tester) async {
      final controller = StreamController<void>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        wrap(DeliveryDemo(ticker: controller.stream)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      // 6 pedidos × 3 transicoes pra que pelo menos o primeiro
      // chegue em "Entregue" pelo round-robin.
      for (var i = 0; i < 18; i++) {
        controller.add(null);
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text(DeliveryStatus.delivered.label), findsAtLeast(1));

      await tester.tap(find.byKey(const Key('delivery-reset-button')));
      // pumpAndSettle pra terminar a transicao do AnimatedSwitcher do
      // texto de status — sem isso o widget antigo ainda esta no tree.
      await tester.pumpAndSettle();

      expect(
        find.text(DeliveryStatus.received.label),
        findsAtLeast(6),
      );
      expect(find.text(DeliveryStatus.delivered.label), findsNothing);
    });
  });
}
