import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryStatus', () {
    test('expoe os 4 status canonicos na ordem certa', () {
      expect(DeliveryStatus.values, [
        DeliveryStatus.received,
        DeliveryStatus.preparing,
        DeliveryStatus.outForDelivery,
        DeliveryStatus.delivered,
      ]);
    });

    test('cada status tem label legivel em pt-BR', () {
      for (final s in DeliveryStatus.values) {
        expect(s.label, isNotEmpty);
        expect(s.label, isNot(equals(s.name)));
      }
    });

    test('isFinal=true so para delivered', () {
      expect(DeliveryStatus.received.isFinal, isFalse);
      expect(DeliveryStatus.preparing.isFinal, isFalse);
      expect(DeliveryStatus.outForDelivery.isFinal, isFalse);
      expect(DeliveryStatus.delivered.isFinal, isTrue);
    });

    test('next: avanca um passo; em delivered fica em delivered', () {
      expect(DeliveryStatus.received.next, DeliveryStatus.preparing);
      expect(DeliveryStatus.preparing.next, DeliveryStatus.outForDelivery);
      expect(DeliveryStatus.outForDelivery.next, DeliveryStatus.delivered);
      expect(DeliveryStatus.delivered.next, DeliveryStatus.delivered);
    });
  });

  group('DeliveryOrder', () {
    DeliveryOrder make({
      String id = 'o-001',
      String customerName = 'Ana',
      int items = 3,
      DeliveryStatus status = DeliveryStatus.received,
      int etaMinutes = 25,
    }) {
      return DeliveryOrder(
        id: id,
        customerName: customerName,
        items: items,
        status: status,
        etaMinutes: etaMinutes,
      );
    }

    test('valor: dois orders identicos sao iguais', () {
      expect(make(), equals(make()));
    });

    test('campos diferentes -> distintos', () {
      expect(make() == make(status: DeliveryStatus.delivered), isFalse);
    });

    test('copyWith preserva campos nao mencionados', () {
      final base = make();
      final next = base.copyWith(status: DeliveryStatus.preparing);
      expect(next.id, base.id);
      expect(next.customerName, base.customerName);
      expect(next.status, DeliveryStatus.preparing);
    });

    test('toString debug-friendly', () {
      expect(make().toString(), contains('o-001'));
    });
  });

  group('DeliveryOrdersCatalog', () {
    test('expoe pelo menos 6 pedidos pra demo nao parecer fraca', () {
      expect(DeliveryOrdersCatalog.all.length, greaterThanOrEqualTo(6));
    });

    test('ids unicos', () {
      final ids = DeliveryOrdersCatalog.all.map((o) => o.id).toSet();
      expect(ids, hasLength(DeliveryOrdersCatalog.all.length));
    });

    test('todos comecam em status received (start fresh)', () {
      for (final o in DeliveryOrdersCatalog.all) {
        expect(o.status, DeliveryStatus.received);
      }
    });
  });
}
