import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Endereco mockado de entrega — usado na tela de resumo de pedido
/// pra comunicar "a compra esta a caminho" sem coletar dados reais.
@immutable
class MockAddress extends Equatable {
  const MockAddress({
    required this.recipient,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.zip,
  });

  final String recipient;
  final String street;
  final String neighborhood;
  final String city;
  final String zip;

  /// Linha condensada do endereco — "Rua X, 100 · Bairro · Cidade".
  String get oneLine => '$street · $neighborhood · $city';

  static const MockAddress garoaDefault = MockAddress(
    recipient: 'Cliente Garoa',
    street: 'Rua Augusta, 1500',
    neighborhood: 'Consolacao',
    city: 'Sao Paulo · SP',
    zip: '01304-001',
  );

  @override
  List<Object?> get props => [recipient, street, neighborhood, city, zip];
}

/// Resumo imutavel de um pedido concluido. Construido pelo CartBloc
/// no checkout e exibido na tela de resumo da Garoa.
@immutable
class OrderSummary extends Equatable {
  const OrderSummary({
    required this.orderNumber,
    required this.itemsCount,
    required this.subtotalCents,
    required this.shippingCents,
    required this.address,
    required this.etaLabel,
  });

  /// Numero de pedido — string com prefixo "GAR-" pra ar do mock.
  final String orderNumber;

  /// Total de unidades (somatorio das quantidades). Util pra "X itens".
  final int itemsCount;

  /// Subtotal dos produtos em centavos (sem frete).
  final double subtotalCents;

  /// Frete aplicado em centavos. Pode ser 0 (frete gratis).
  final double shippingCents;

  /// Endereco mock pra exibicao.
  final MockAddress address;

  /// Estimativa de entrega ja formatada ("3-5 dias uteis").
  final String etaLabel;

  /// Total final (subtotal + frete).
  double get totalCents => subtotalCents + shippingCents;

  @override
  List<Object?> get props => [
        orderNumber,
        itemsCount,
        subtotalCents,
        shippingCents,
        address,
        etaLabel,
      ];
}
