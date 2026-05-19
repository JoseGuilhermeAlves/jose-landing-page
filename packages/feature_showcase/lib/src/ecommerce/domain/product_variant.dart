import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Variante de produto (ex.: torra do cafe, cor do caderno, tamanho
/// da caneca). [deltaCents] e somado ao preco base quando selecionada.
@immutable
class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.sublabel,
    this.deltaCents = 0,
  });

  /// Id estavel pra comparacao (evita comparar por label sensivel a
  /// acentos).
  final String id;

  /// Rotulo exibido no chip (ex.: "Media", "Cinza grafite").
  final String label;

  /// Linha de apoio curta (ex.: "Notas de chocolate ao leite").
  final String sublabel;

  /// Diferenca de preco em centavos versus o preco base do produto.
  /// Pode ser negativa pra opcoes mais baratas.
  final double deltaCents;

  @override
  List<Object?> get props => [id, label, sublabel, deltaCents];
}
