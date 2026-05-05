import 'package:feature_about/feature_about.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainsCatalog', () {
    test('expoe pelo menos 5 dominios (cobrindo o range do Jose)', () {
      expect(DomainsCatalog.all.length, greaterThanOrEqualTo(5));
    });

    test('todos os dominios tem id, label e blurb nao-vazios', () {
      for (final d in DomainsCatalog.all) {
        expect(d.id, isNotEmpty, reason: d.toString());
        expect(d.label, isNotEmpty, reason: d.toString());
        expect(d.blurb, isNotEmpty, reason: d.toString());
      }
    });

    test('ids sao unicos', () {
      final ids = DomainsCatalog.all.map((d) => d.id).toSet();
      expect(ids, hasLength(DomainsCatalog.all.length));
    });

    test('lista e imutavel (nao aceita add)', () {
      expect(
        () => DomainsCatalog.all.add(DomainsCatalog.all.first),
        throwsUnsupportedError,
      );
    });

    test(
        'inclui o dominio "retail" como o unico end-to-end '
        '— alinhado com o que Jose construiu sozinho', () {
      final endToEnd = DomainsCatalog.all
          .where((d) => d.scope == DomainScope.endToEnd)
          .toList();
      expect(endToEnd, hasLength(1));
      expect(endToEnd.first.id, 'retail');
    });

    test(
      'NUNCA cita nominalmente empresas/produtos com que o Jose '
      'trabalhou — quem quiser detalhe abre o LinkedIn',
      () {
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
        for (final d in DomainsCatalog.all) {
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
      },
    );
  });

  group('StackCatalog', () {
    test(
      'expoe stack com pelo menos 5 itens (Flutter, Dart, Bloc, Clean '
      'Architecture, etc.)',
      () {
        expect(StackCatalog.all.length, greaterThanOrEqualTo(5));
      },
    );

    test('contem ao menos Flutter e Dart (nao-negociavel)', () {
      expect(StackCatalog.all, contains('Flutter'));
      expect(StackCatalog.all, contains('Dart'));
    });

    test('lista e imutavel (nao aceita add)', () {
      expect(
        () => StackCatalog.all.add('foo'),
        throwsUnsupportedError,
      );
    });
  });
}
