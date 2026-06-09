import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Endereco de entrega mock do Aurora. Usado na etapa de checkout pra
/// o cliente escolher entre alguns enderecos salvos antes de fechar o
/// pedido. Sem CEP/geocoding real — narrativa de bairro.
@immutable
class DeliveryAddress extends Equatable {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.district,
  });

  final String id;

  /// Rotulo curto do endereco ("Casa", "Trabalho", "Mae").
  final String label;

  /// Linha principal — rua + numero + complemento.
  final String street;

  /// Bairro + cidade ("Pinheiros · SP").
  final String district;

  /// Linha unica usada pelo pedido (`addressLine`): rua · bairro.
  String get oneLine => '$street · $district';

  @override
  List<Object?> get props => [id, label, street, district];
}
