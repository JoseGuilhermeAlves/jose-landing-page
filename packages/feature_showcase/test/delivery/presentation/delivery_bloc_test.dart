import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orders = [
    DeliveryOrder(
      id: 'a',
      customerName: 'Ana',
      items: 2,
      status: DeliveryStatus.received,
      etaMinutes: 20,
    ),
    DeliveryOrder(
      id: 'b',
      customerName: 'Bruno',
      items: 1,
      status: DeliveryStatus.received,
      etaMinutes: 30,
    ),
  ];

  group('DeliveryBloc', () {
    test('estado inicial: orders carregados, allDelivered=false', () {
      final bloc = DeliveryBloc(initialOrders: orders);
      expect(bloc.state.orders, orders);
      expect(bloc.state.allDelivered, isFalse);
      bloc.close();
    });

    blocTest<DeliveryBloc, DeliveryState>(
      'tick avanca o primeiro pedido nao-final pelo proximo status',
      build: () => DeliveryBloc(initialOrders: orders),
      act: (bloc) => bloc.add(const DeliveryTickRequested()),
      verify: (bloc) {
        expect(bloc.state.orders[0].status, DeliveryStatus.preparing);
        expect(bloc.state.orders[1].status, DeliveryStatus.received);
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'tick rotaciona round-robin entre pedidos nao-finais',
      build: () => DeliveryBloc(initialOrders: orders),
      act: (bloc) => bloc
        ..add(const DeliveryTickRequested()) // a -> preparing
        ..add(const DeliveryTickRequested()) // b -> preparing
        ..add(const DeliveryTickRequested()) // a -> outForDelivery
        ..add(const DeliveryTickRequested()), // b -> outForDelivery
      verify: (bloc) {
        expect(bloc.state.orders[0].status, DeliveryStatus.outForDelivery);
        expect(bloc.state.orders[1].status, DeliveryStatus.outForDelivery);
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'depois de ticks suficientes, allDelivered=true',
      build: () => DeliveryBloc(initialOrders: orders),
      act: (bloc) {
        // 3 status transicoes por pedido x 2 pedidos = 6 ticks
        for (var i = 0; i < 6; i++) {
          bloc.add(const DeliveryTickRequested());
        }
      },
      verify: (bloc) {
        for (final o in bloc.state.orders) {
          expect(o.status, DeliveryStatus.delivered);
        }
        expect(bloc.state.allDelivered, isTrue);
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'tick em estado allDelivered eh idempotente',
      build: () => DeliveryBloc(
        initialOrders: const [
          DeliveryOrder(
            id: 'a',
            customerName: 'A',
            items: 1,
            status: DeliveryStatus.delivered,
            etaMinutes: 0,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeliveryTickRequested()),
      expect: () => <DeliveryState>[],
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'reset volta os pedidos pro status received e re-permite ticks',
      build: () => DeliveryBloc(initialOrders: orders),
      act: (bloc) => bloc
        ..add(const DeliveryTickRequested())
        ..add(const DeliveryTickRequested())
        ..add(const DeliveryReset()),
      verify: (bloc) {
        for (final o in bloc.state.orders) {
          expect(o.status, DeliveryStatus.received);
        }
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'tick decrementa etaMinutes de pedidos em andamento',
      build: () => DeliveryBloc(initialOrders: orders),
      act: (bloc) => bloc.add(const DeliveryTickRequested()),
      verify: (bloc) {
        expect(bloc.state.orders[0].etaMinutes, 19); // 20 - 1
        expect(bloc.state.orders[1].etaMinutes, 29); // 30 - 1
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'cancel marca pedido como cancelled, zera ETA e migra pro historico',
      build: () => DeliveryBloc(initialOrders: orders),
      act: (bloc) => bloc.add(const DeliveryOrderCancelled('a')),
      verify: (bloc) {
        final cancelled = bloc.state.orders.firstWhere((o) => o.id == 'a');
        expect(cancelled.status, DeliveryStatus.cancelled);
        expect(cancelled.etaMinutes, 0);
        expect(bloc.state.historyOrders.map((o) => o.id), contains('a'));
        expect(bloc.state.activeOrder?.id, 'b');
      },
    );

    blocTest<DeliveryBloc, DeliveryState>(
      'cancel em pedido final eh idempotente',
      build: () => DeliveryBloc(
        initialOrders: const [
          DeliveryOrder(
            id: 'a',
            customerName: 'A',
            items: 1,
            status: DeliveryStatus.delivered,
            etaMinutes: 0,
          ),
        ],
      ),
      act: (bloc) => bloc.add(const DeliveryOrderCancelled('a')),
      expect: () => <DeliveryState>[],
    );

    group('DeliveryOrderPlacedWithCart (checkout)', () {
      setUp(DeliveryBloc.resetOrderCounter);

      blocTest<DeliveryBloc, DeliveryState>(
        'sem campos de checkout usa endereco/pagamento default do catalogo',
        build: () => DeliveryBloc(initialOrders: orders),
        act: (bloc) => bloc.add(
          const DeliveryOrderPlacedWithCart(
            vendorId: 'v-mario',
            quantities: {'i-banana': 2},
          ),
        ),
        verify: (bloc) {
          final placed = bloc.state.orders.first;
          expect(placed.vendorId, 'v-mario');
          expect(placed.status, DeliveryStatus.received);
          expect(placed.lineItems, hasLength(1));
          expect(placed.lineItems.first.quantity, 2);
          // Default vem do AuroraCheckoutCatalog (primeiro endereco/pagto).
          expect(placed.addressLine, isNotEmpty);
          expect(placed.paymentLabel, isNotEmpty);
          expect(placed.notes, isEmpty);
        },
      );

      blocTest<DeliveryBloc, DeliveryState>(
        'com campos de checkout grava endereco, pagamento e observacao',
        build: () => DeliveryBloc(initialOrders: orders),
        act: (bloc) => bloc.add(
          const DeliveryOrderPlacedWithCart(
            vendorId: 'v-mario',
            quantities: {'i-banana': 1, 'i-maca': 3},
            addressLine: 'Rua Harmonia, 88 · Vila Madalena · SP',
            paymentLabel: 'Pix · Aprovação na hora',
            notes: 'Deixar na portaria',
          ),
        ),
        verify: (bloc) {
          final placed = bloc.state.orders.first;
          expect(placed.lineItems, hasLength(2));
          expect(placed.addressLine, 'Rua Harmonia, 88 · Vila Madalena · SP');
          expect(placed.paymentLabel, 'Pix · Aprovação na hora');
          expect(placed.notes, 'Deixar na portaria');
        },
      );

      blocTest<DeliveryBloc, DeliveryState>(
        'quantities vazio (nenhum item do vendor) nao emite pedido',
        build: () => DeliveryBloc(initialOrders: orders),
        act: (bloc) => bloc.add(
          const DeliveryOrderPlacedWithCart(
            vendorId: 'v-mario',
            quantities: {'item-inexistente': 1},
          ),
        ),
        expect: () => <DeliveryState>[],
      );

      blocTest<DeliveryBloc, DeliveryState>(
        'vendor inexistente nao emite pedido',
        build: () => DeliveryBloc(initialOrders: orders),
        act: (bloc) => bloc.add(
          const DeliveryOrderPlacedWithCart(
            vendorId: 'v-fantasma',
            quantities: {'i-banana': 1},
          ),
        ),
        expect: () => <DeliveryState>[],
      );
    });

    test('ticker stream dispara ticks automaticamente', () async {
      final controller = StreamController<void>.broadcast();
      final bloc = DeliveryBloc(
        initialOrders: orders,
        ticker: controller.stream,
      );

      controller.add(null);
      await Future<void>.delayed(Duration.zero);
      controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.orders[0].status, DeliveryStatus.preparing);
      expect(bloc.state.orders[1].status, DeliveryStatus.preparing);

      await controller.close();
      await bloc.close();
    });
  });
}
