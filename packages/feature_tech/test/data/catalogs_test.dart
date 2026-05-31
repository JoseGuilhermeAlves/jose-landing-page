import 'package:design_system/design_system.dart';
import 'package:feature_tech/feature_tech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  group('ArchDecisionsCatalog', () {
    test('expoe 6 decisoes com ids unicos', () {
      const all = ArchDecisionsCatalog.all;
      expect(all, hasLength(6));
      final ids = all.map((d) => d.id).toSet();
      expect(ids.length, all.length, reason: 'ids devem ser unicos');
    });

    test('todo title e body sao non-empty', () {
      for (final d in ArchDecisionsCatalog.all) {
        expect(d.title, isNotEmpty);
        expect(d.body, isNotEmpty);
      }
    });
  });

  group('StackCatalog', () {
    test('byCategory cobre todas as categorias enum', () {
      final byCategory = StackCatalog.byCategory(l10n);
      for (final c in StackCategory.values) {
        expect(
          byCategory.containsKey(c),
          isTrue,
          reason: 'categoria ${c.name} ausente do agrupamento',
        );
      }
    });

    test('cada item carrega name + version + role + category', () {
      for (final item in StackCatalog.all(l10n)) {
        expect(item.name, isNotEmpty);
        expect(item.version, isNotEmpty);
        expect(item.role, isNotEmpty);
      }
    });

    test('itens estao distribuidos em mais de uma categoria', () {
      final categories = StackCatalog.all(l10n).map((i) => i.category).toSet();
      expect(categories.length, greaterThan(1));
    });
  });

  group('PaintersCatalog', () {
    test('expoe pelo menos 9 painters com role nao-vazio', () {
      const all = PaintersCatalog.all;
      expect(all.length, greaterThanOrEqualTo(9));
      for (final p in all) {
        expect(p.name, isNotEmpty);
        expect(p.role, isNotEmpty);
        expect(p.location, isNotEmpty);
      }
    });

    test('nomes dos painters sao unicos', () {
      final names = PaintersCatalog.all.map((p) => p.name).toSet();
      expect(names.length, PaintersCatalog.all.length);
    });
  });
}
