import 'package:feature_services/feature_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Service', () {
    Service make({
      String id = 'mobile',
      String title = 'Apps mobile',
      String description = 'Android nativo via Flutter.',
      IconData icon = Icons.phone_android,
    }) {
      return Service(
        id: id,
        title: title,
        description: description,
        icon: icon,
      );
    }

    test('valor: dois Services com mesmos campos sao iguais', () {
      expect(make(), equals(make()));
      expect(make().hashCode, equals(make().hashCode));
    });

    test('valor: ids diferentes -> instancias distintas', () {
      expect(make() == make(id: 'web'), isFalse);
    });

    test('toString inclui o id (debug-friendly)', () {
      expect(make().toString(), contains('mobile'));
    });
  });
}
