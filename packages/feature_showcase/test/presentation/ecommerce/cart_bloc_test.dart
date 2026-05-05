import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = Product(id: 'a', name: 'A', priceCents: 1000, emoji: '🅰️');
  const b = Product(id: 'b', name: 'B', priceCents: 2500, emoji: '🅱️');

  group('CartBloc', () {
    test('estado inicial: carrinho vazio, totalCents zero', () {
      final bloc = CartBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.totalCents, 0);
      expect(bloc.state.totalQuantity, 0);
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
      'clear esvazia o carrinho de uma vez',
      build: CartBloc.new,
      seed: () => const CartState(
        items: [
          CartLine(product: a, quantity: 3),
          CartLine(product: b, quantity: 2),
        ],
      ),
      act: (bloc) => bloc.add(const CartCleared()),
      verify: (bloc) => expect(bloc.state.items, isEmpty),
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
  });
}
