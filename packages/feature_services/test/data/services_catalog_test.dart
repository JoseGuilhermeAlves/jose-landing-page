import 'package:feature_services/feature_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServicesCatalog', () {
    test('expoe os 5 servicos canonicos do PROJECT.md §4.2', () {
      final ids = ServicesCatalog.all.map((s) => s.id).toList();
      expect(ids, hasLength(5));
      expect(
        ids,
        containsAll([
          'mobile',
          'web',
          'integrations',
          'maintenance',
          'consulting',
        ]),
      );
    });

    test('todos os servicos tem titulo e descricao nao-vazios', () {
      for (final s in ServicesCatalog.all) {
        expect(s.title, isNotEmpty, reason: 'titulo vazio em ${s.id}');
        expect(s.description, isNotEmpty, reason: 'descricao vazia em ${s.id}');
      }
    });

    test('nao expoe duplicatas de id', () {
      final ids = ServicesCatalog.all.map((s) => s.id).toSet();
      expect(ids, hasLength(ServicesCatalog.all.length));
    });

    test('lista e imutavel — nao aceita adds em runtime', () {
      expect(
        () => ServicesCatalog.all.add(ServicesCatalog.all.first),
        throwsUnsupportedError,
      );
    });
  });
}
