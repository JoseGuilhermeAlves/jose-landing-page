import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = Product(id: 'a', name: 'A', priceCents: 1000, emoji: '🅰️');
  const b = Product(id: 'b', name: 'B', priceCents: 2500, emoji: '🅱️');

  setUp(CartBloc.resetOrderCounter);

  group('CartBloc', () {
    test('estado inicial: carrinho vazio, totalCents zero, sem lastOrder', () {
      final bloc = CartBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.totalCents, 0);
      expect(bloc.state.totalQuantity, 0);
      expect(bloc.state.lastOrder, isNull);
    });

    blocTest<CartBloc, CartState>(
      'add insere com qty=1; add do mesmo produto incrementa qty',
      build: CartBloc.new,
      act: (bloc) => bloc
        ..add(const CartAddProduct(a))
        ..add(const CartAddProduct(a))
        ..add(const CartAddProduct(b)),
      verify: (bloc) {
        expect(bloc.state.items, hasLength(2));
        expect(bloc.state.quantityFor(a.id), 2);
        expect(bloc.state.quantityFor(b.id), 1);
        expect(bloc.state.totalCents, 1000 * 2 + 2500);
        expect(bloc.state.totalQuantity, 3);
      },
    );

    blocTest<CartBloc, CartState>(
      'add com quantity > 1 acumula no item existente',
      build: CartBloc.new,
      act: (bloc) => bloc
        ..add(const CartAddProduct(a))
        ..add(const CartAddProduct(a, quantity: 3)),
      verify: (bloc) {
        expect(bloc.state.quantityFor(a.id), 4);
        expect(bloc.state.totalCents, 4000);
      },
    );

    blocTest<CartBloc, CartState>(
      'remove decrementa; chega a zero -> remove o item',
      build: CartBloc.new,
      seed: () => const CartState(
        items: [
          CartLine(product: a, quantity: 2),
          CartLine(product: b, quantity: 1),
        ],
      ),
      act: (bloc) => bloc
        ..add(const CartRemoveProduct('a'))
        ..add(const CartRemoveProduct('a'))
        ..add(const CartRemoveProduct('b')),
      verify: (bloc) {
        expect(bloc.state.items, isEmpty);
        expect(bloc.state.totalCents, 0);
      },
    );

    blocTest<CartBloc, CartState>(
      'setQuantity define direto; <= 0 remove o item',
      build: CartBloc.new,
      seed: () => const CartState(items: [CartLine(product: a, quantity: 1)]),
      act: (bloc) => bloc
        ..add(const CartSetQuantity('a', 5))
        ..add(const CartAddProduct(b))
        ..add(const CartSetQuantity('b', 0)),
      verify: (bloc) {
        expect(bloc.state.quantityFor('a'), 5);
        expect(bloc.state.quantityFor('b'), 0);
        expect(bloc.state.items.where((l) => l.product.id == 'b'), isEmpty);
      },
    );

    blocTest<CartBloc, CartState>(
      'clear esvazia o carrinho e o lastOrder',
      build: CartBloc.new,
      seed: () => const CartState(
        items: [
          CartLine(product: a, quantity: 3),
          CartLine(product: b, quantity: 2),
        ],
      ),
      act: (bloc) => bloc.add(const CartCleared()),
      verify: (bloc) {
        expect(bloc.state.items, isEmpty);
        expect(bloc.state.lastOrder, isNull);
      },
    );

    test('CartLine.subtotalCents = product.priceCents * quantity', () {
      const line = CartLine(product: a, quantity: 3);
      expect(line.subtotalCents, 3000);
    });

    test('CartState.formattedTotal usa formatador de Product', () {
      const state = CartState(items: [CartLine(product: a, quantity: 3)]);
      expect(state.formattedTotal, contains(r'R$'));
      expect(state.formattedTotal, contains('30,00'));
    });

    group('CartCheckoutRequested', () {
      blocTest<CartBloc, CartState>(
        'carrinho vazio: ignora o evento (sem state novo)',
        build: CartBloc.new,
        act: (bloc) => bloc.add(const CartCheckoutRequested()),
        expect: () => <CartState>[],
      );

      blocTest<CartBloc, CartState>(
        'subtotal < 150,00: aplica frete de R\$ 15,00',
        build: CartBloc.new,
        seed: () => const CartState(
          items: [CartLine(product: a, quantity: 1)],
        ),
        act: (bloc) => bloc.add(const CartCheckoutRequested()),
        verify: (bloc) {
          final order = bloc.state.lastOrder;
          expect(order, isNotNull);
          expect(order!.subtotalCents, 1000);
          expect(order.shippingCents, 1500);
          expect(order.totalCents, 2500);
          expect(order.itemsCount, 1);
          expect(order.orderNumber, startsWith('GAR-'));
          expect(bloc.state.items, isEmpty);
        },
      );

      blocTest<CartBloc, CartState>(
        'subtotal >= 150,00: frete gratis',
        build: CartBloc.new,
        seed: () => const CartState(
          items: [CartLine(product: b, quantity: 6)], // 25000 cents = R\$ 250
        ),
        act: (bloc) => bloc.add(const CartCheckoutRequested()),
        verify: (bloc) {
          final order = bloc.state.lastOrder;
          expect(order, isNotNull);
          expect(order!.shippingCents, 0);
          expect(order.totalCents, 15000);
        },
      );

      test('orderNumber e sequencial entre pedidos da mesma sessao', () async {
        final bloc = CartBloc()
          ..add(const CartAddProduct(a))
          ..add(const CartCheckoutRequested());
        await Future<void>.delayed(Duration.zero);
        final first = bloc.state.lastOrder!.orderNumber;

        bloc
          ..add(const CartAddProduct(b))
          ..add(const CartCheckoutRequested());
        await Future<void>.delayed(Duration.zero);
        final second = bloc.state.lastOrder!.orderNumber;

        expect(first, 'GAR-0001');
        expect(second, 'GAR-0002');
        await bloc.close();
      });
    });
  });
}
