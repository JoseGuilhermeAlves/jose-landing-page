import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  group('DomainsCatalog', () {
    test('expoe pelo menos 4 dominios (cobrindo o range do Jose)', () {
      expect(DomainsCatalog.all(l10n).length, greaterThanOrEqualTo(4));
    });

    test('todos os dominios tem id, label e blurb nao-vazios', () {
      for (final d in DomainsCatalog.all(l10n)) {
        expect(d.id, isNotEmpty, reason: d.toString());
        expect(d.label, isNotEmpty, reason: d.toString());
        expect(d.blurb, isNotEmpty, reason: d.toString());
      }
    });

    test('ids sao unicos', () {
      final domains = DomainsCatalog.all(l10n);
      final ids = domains.map((d) => d.id).toSet();
      expect(ids, hasLength(domains.length));
    });

    test('inclui o dominio "retail" como o unico end-to-end '
        '— alinhado com o que Jose construiu sozinho', () {
      final endToEnd = DomainsCatalog.all(l10n)
          .where((d) => d.scope == DomainScope.endToEnd)
          .toList();
      expect(endToEnd, hasLength(1));
      expect(endToEnd.first.id, 'retail');
    });

    test('NUNCA cita nominalmente empresas/produtos com que o Jose '
        'trabalhou — quem quiser detalhe abre o LinkedIn', () {
      const banned = [
        'Solutis',
        'Serasa',
        'TJ-BA',
        'TJBA',
        'Sabesp',
        'PocketLab',
        'Pocket Lab',
        'Passaporte',
        'TaqTaq',
        'Taq Taq',
        'Sumire',
        'Sumirê',
      ];
      for (final d in DomainsCatalog.all(l10n)) {
        for (final term in banned) {
          for (final field in [d.label, d.blurb]) {
            expect(
              field.toLowerCase().contains(term.toLowerCase()),
              isFalse,
              reason: 'Encontrou "$term" em "$field" da entry $d',
            );
          }
        }
      }
    });
  });
}
