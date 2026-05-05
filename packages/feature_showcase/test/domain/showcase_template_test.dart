import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShowcaseTemplate', () {
    ShowcaseTemplate make({
      String id = 'ecommerce',
      String label = 'E-commerce',
      String description = 'Catalogo + carrinho.',
      IconData icon = Icons.shopping_bag_outlined,
      bool hasDemo = true,
    }) {
      return ShowcaseTemplate(
        id: id,
        label: label,
        description: description,
        icon: icon,
        hasDemo: hasDemo,
      );
    }

    test('valor: dois templates identicos sao iguais', () {
      expect(make(), equals(make()));
      expect(make().hashCode, equals(make().hashCode));
    });

    test('ids diferentes -> distintos', () {
      expect(make() == make(id: 'delivery'), isFalse);
    });

    test('toString debug-friendly', () {
      expect(make().toString(), contains('ecommerce'));
    });
  });
}
