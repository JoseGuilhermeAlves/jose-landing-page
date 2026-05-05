import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product', () {
    Product make({
      String id = 'p-001',
      String name = 'Cafeteira Italiana',
      double priceCents = 12990,
      String emoji = '☕',
    }) {
      return Product(id: id, name: name, priceCents: priceCents, emoji: emoji);
    }

    test('valor: dois Product identicos sao iguais', () {
      expect(make(), equals(make()));
    });

    test('priceCents diferentes -> distintos', () {
      expect(make() == make(priceCents: 9990), isFalse);
    });

    test(r'formattedPrice exibe BRL com R$ e separadores', () {
      expect(make().formattedPrice, contains(r'R$'));
      expect(make().formattedPrice, contains('129'));
      expect(make().formattedPrice, contains('90'));
    });

    test('formattedPrice arredonda valores quebrados a 2 casas', () {
      expect(make(priceCents: 100).formattedPrice, contains('1,00'));
      expect(make(priceCents: 1000).formattedPrice, contains('10,00'));
    });
  });

  group('ProductsCatalog', () {
    test('expoe pelo menos 6 produtos pra demo nao parecer fraca', () {
      expect(ProductsCatalog.all.length, greaterThanOrEqualTo(6));
    });

    test('todos com id unico, name, priceCents > 0 e emoji', () {
      final ids = <String>{};
      for (final p in ProductsCatalog.all) {
        expect(p.id, isNotEmpty);
        expect(ids.add(p.id), isTrue, reason: 'id duplicado: ${p.id}');
        expect(p.name, isNotEmpty);
        expect(p.priceCents, greaterThan(0));
        expect(p.emoji, isNotEmpty);
      }
    });
  });
}
