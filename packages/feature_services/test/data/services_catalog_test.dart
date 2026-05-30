import 'package:design_system/design_system.dart';
import 'package:feature_services/feature_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  group('ServicesCatalog', () {
    test('expoe os 5 servicos canonicos do PROJECT.md §4.2', () {
      final services = ServicesCatalog.all(l10n);
      final ids = services.map((s) => s.id).toList();
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
      for (final s in ServicesCatalog.all(l10n)) {
        expect(s.title, isNotEmpty, reason: 'titulo vazio em ${s.id}');
        expect(s.description, isNotEmpty, reason: 'descricao vazia em ${s.id}');
      }
    });

    test('nao expoe duplicatas de id', () {
      final services = ServicesCatalog.all(l10n);
      final ids = services.map((s) => s.id).toSet();
      expect(ids, hasLength(services.length));
    });
  });
}
