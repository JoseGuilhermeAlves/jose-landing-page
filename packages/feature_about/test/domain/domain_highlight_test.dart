import 'package:feature_about/feature_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainHighlight', () {
    DomainHighlight make({
      String id = 'fintech',
      String label = 'Fintech',
      String blurb = 'Produto de credito mobile em escala.',
      IconData icon = Icons.credit_card_outlined,
      DomainScope scope = DomainScope.team,
    }) {
      return DomainHighlight(
        id: id,
        label: label,
        blurb: blurb,
        icon: icon,
        scope: scope,
      );
    }

    test('valor: dois highlights identicos sao iguais', () {
      expect(make(), equals(make()));
      expect(make().hashCode, equals(make().hashCode));
    });

    test('ids diferentes -> distintos', () {
      expect(make() == make(id: 'retail'), isFalse);
    });

    test('toString debug-friendly inclui label', () {
      expect(make().toString(), contains('Fintech'));
    });
  });

  group('DomainScope', () {
    test('expoe ao menos endToEnd e team', () {
      expect(DomainScope.values, contains(DomainScope.endToEnd));
      expect(DomainScope.values, contains(DomainScope.team));
    });
  });
}
