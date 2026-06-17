import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  group('ShowcaseCatalog', () {
    test('expoe os 3 nichos da vitrine', () {
      final ids = ShowcaseCatalog.all(l10n).map((t) => t.id).toList();
      expect(ids, hasLength(3));
      expect(
        ids,
        containsAll(['delivery', 'realestate', 'finance']),
      );
    });

    test('todos os nichos vem com hasDemo=true', () {
      for (final t in ShowcaseCatalog.all(l10n)) {
        expect(
          t.hasDemo,
          isTrue,
          reason: '${t.id} deveria estar com demo plugada',
        );
      }
    });

    test('todos os templates tem label e descricao nao-vazios', () {
      for (final t in ShowcaseCatalog.all(l10n)) {
        expect(t.label, isNotEmpty);
        expect(t.description, isNotEmpty);
      }
    });

    test('ids unicos', () {
      final templates = ShowcaseCatalog.all(l10n);
      final ids = templates.map((t) => t.id).toSet();
      expect(ids, hasLength(templates.length));
    });
  });
}
