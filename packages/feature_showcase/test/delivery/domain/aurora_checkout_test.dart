import 'package:feature_showcase/src/delivery/data/aurora_checkout_catalog.dart';
import 'package:feature_showcase/src/delivery/data/aurora_items_catalog.dart';
import 'package:feature_showcase/src/delivery/data/aurora_vendors_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_address.dart';
import 'package:feature_showcase/src/delivery/domain/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryAddress', () {
    const addr = DeliveryAddress(
      id: 'a1',
      label: 'Casa',
      street: 'Rua X, 10',
      district: 'Pinheiros · SP',
    );

    test('oneLine junta rua e bairro', () {
      expect(addr.oneLine, 'Rua X, 10 · Pinheiros · SP');
    });

    test('valor: enderecos identicos sao iguais', () {
      expect(
        addr,
        equals(
          const DeliveryAddress(
            id: 'a1',
            label: 'Casa',
            street: 'Rua X, 10',
            district: 'Pinheiros · SP',
          ),
        ),
      );
    });
  });

  group('PaymentMethod', () {
    const pay = PaymentMethod(
      id: 'p1',
      label: 'Pix',
      detail: 'Aprovação na hora',
      kind: PaymentKind.pix,
    );

    test('oneLine junta rotulo e detalhe', () {
      expect(pay.oneLine, 'Pix · Aprovação na hora');
    });

    test('cobre os tres tipos de pagamento', () {
      expect(PaymentKind.values, hasLength(3));
    });
  });

  group('AuroraCheckoutCatalog', () {
    test('tem ao menos 2 enderecos e 2 formas de pagamento', () {
      expect(
        AuroraCheckoutCatalog.addresses.length,
        greaterThanOrEqualTo(2),
      );
      expect(
        AuroraCheckoutCatalog.paymentMethods.length,
        greaterThanOrEqualTo(2),
      );
    });

    test('ids de endereco e pagamento sao unicos', () {
      final addrIds = AuroraCheckoutCatalog.addresses.map((a) => a.id).toSet();
      expect(addrIds, hasLength(AuroraCheckoutCatalog.addresses.length));
      final payIds = AuroraCheckoutCatalog.paymentMethods
          .map((p) => p.id)
          .toSet();
      expect(payIds, hasLength(AuroraCheckoutCatalog.paymentMethods.length));
    });

    test('lookup por id encontra e devolve null pra inexistente', () {
      final first = AuroraCheckoutCatalog.addresses.first;
      expect(AuroraCheckoutCatalog.addressById(first.id), first);
      expect(AuroraCheckoutCatalog.addressById('nope'), isNull);
      final pay = AuroraCheckoutCatalog.paymentMethods.first;
      expect(AuroraCheckoutCatalog.paymentById(pay.id), pay);
      expect(AuroraCheckoutCatalog.paymentById('nope'), isNull);
    });

    test('tem sugestoes de observacao nao vazias', () {
      expect(AuroraCheckoutCatalog.noteSuggestions, isNotEmpty);
      for (final n in AuroraCheckoutCatalog.noteSuggestions) {
        expect(n, isNotEmpty);
      }
    });
  });

  group('Catalogos Aurora — fotos', () {
    test('todo vendor declara um photoAsset apontando pra assets/delivery', () {
      for (final v in AuroraVendorsCatalog.all) {
        expect(v.photoAsset, isNotNull, reason: 'vendor ${v.id} sem foto');
        expect(v.photoAsset, startsWith('assets/delivery/'));
        expect(v.photoAsset, endsWith('.webp'));
      }
    });

    test('todo item declara photoAsset e descricao longa', () {
      for (final i in AuroraItemsCatalog.all) {
        expect(i.photoAsset, isNotNull, reason: 'item ${i.id} sem foto');
        expect(i.photoAsset, startsWith('assets/delivery/'));
        expect(i.photoAsset, endsWith('.webp'));
        expect(i.description, isNotEmpty, reason: 'item ${i.id} sem descricao');
      }
    });
  });
}
