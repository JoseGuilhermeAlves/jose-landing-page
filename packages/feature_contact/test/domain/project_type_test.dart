import 'package:feature_contact/feature_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectType', () {
    test('expoe ao menos 4 opcoes para o dropdown', () {
      expect(ProjectType.values.length, greaterThanOrEqualTo(4));
    });

    test('cada opcao tem um label legivel em pt-BR (sem chaves de enum)', () {
      for (final t in ProjectType.values) {
        expect(t.label, isNotEmpty);
        expect(t.label, isNot(equals(t.name)));
      }
    });
  });
}
