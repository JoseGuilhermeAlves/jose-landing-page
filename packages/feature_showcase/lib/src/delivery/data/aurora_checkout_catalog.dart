import 'package:feature_showcase/src/delivery/domain/delivery_address.dart';
import 'package:feature_showcase/src/delivery/domain/payment_method.dart';

/// Dados estaticos da etapa de checkout do Aurora — enderecos salvos,
/// formas de pagamento e observacoes prontas. Tudo mock, sem backend.
abstract final class AuroraCheckoutCatalog {
  /// Enderecos salvos do cliente. O primeiro e o default da etapa.
  static const List<DeliveryAddress> addresses = [
    DeliveryAddress(
      id: 'addr-casa',
      label: 'Casa',
      street: 'Rua das Palmeiras, 240 · ap 52',
      district: 'Pinheiros · SP',
    ),
    DeliveryAddress(
      id: 'addr-trabalho',
      label: 'Trabalho',
      street: 'Av. Faria Lima, 1700 · 8º andar',
      district: 'Itaim Bibi · SP',
    ),
    DeliveryAddress(
      id: 'addr-mae',
      label: 'Casa da mãe',
      street: 'Rua Harmonia, 88',
      district: 'Vila Madalena · SP',
    ),
  ];

  /// Formas de pagamento. O primeiro e o default da etapa.
  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'pay-pix',
      label: 'Pix',
      detail: 'Aprovação na hora',
      kind: PaymentKind.pix,
    ),
    PaymentMethod(
      id: 'pay-credito',
      label: 'Cartão de crédito',
      detail: 'Final 4821',
      kind: PaymentKind.creditCard,
    ),
    PaymentMethod(
      id: 'pay-dinheiro',
      label: 'Dinheiro',
      detail: 'Na entrega',
      kind: PaymentKind.cashOnDelivery,
    ),
  ];

  /// Observacoes prontas pra anexar ao pedido — evita campo de texto
  /// livre num mock, mantendo o fluxo tátil. Vazio (`null`) = sem nota.
  static const List<String> noteSuggestions = [
    'Trocar se faltar algum item',
    'Deixar na portaria',
    'Pode tocar a campainha',
    'Caprichar na escolha das frutas',
  ];

  static DeliveryAddress? addressById(String id) {
    for (final a in addresses) {
      if (a.id == id) return a;
    }
    return null;
  }

  static PaymentMethod? paymentById(String id) {
    for (final p in paymentMethods) {
      if (p.id == id) return p;
    }
    return null;
  }
}
