import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShowcaseCatalog', () {
    test('expoe os 5 nichos da vitrine', () {
      final ids = ShowcaseCatalog.all.map((t) => t.id).toList();
      expect(ids, hasLength(5));
      expect(
        ids,
        containsAll([
          'delivery',
          'scheduling',
          'fitness',
          'realestate',
          'finance',
        ]),
      );
    });

    test('todos os nichos vem com hasDemo=true', () {
      for (final t in ShowcaseCatalog.all) {
        expect(
          t.hasDemo,
          isTrue,
          reason: '${t.id} deveria estar com demo plugada',
        );
      }
    });

    test('todos os templates tem label e descricao nao-vazios', () {
      for (final t in ShowcaseCatalog.all) {
        expect(t.label, isNotEmpty);
        expect(t.description, isNotEmpty);
      }
    });

    test('ids unicos e lista imutavel', () {
      final ids = ShowcaseCatalog.all.map((t) => t.id).toSet();
      expect(ids, hasLength(ShowcaseCatalog.all.length));

      expect(
        () => ShowcaseCatalog.all.add(ShowcaseCatalog.all.first),
        throwsUnsupportedError,
      );
    });
  });
}
