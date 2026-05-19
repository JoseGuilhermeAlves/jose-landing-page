import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/ecommerce/domain/product_category.dart';
import 'package:feature_showcase/src/ecommerce/domain/product_variant.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/foundation.dart';

/// Produto do mock de e-commerce. Sem imagem real — a ilustracao e
/// renderizada via Custom Painter (categoricamente, por
/// [ProductCategory]). O [emoji] e o fallback exibido onde uma
/// ilustracao em painter nao caberia (ex.: linha do carrinho).
@immutable
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.emoji,
    this.category = ProductCategory.tabletop,
    this.subtitle = '',
    this.description = '',
    this.origin = '',
    this.variants = const [],
  });

  final String id;
  final String name;

  /// Preco em centavos (evita arredondamento de double).
  final double priceCents;

  /// Emoji "produto" — fallback leve quando nao da pra desenhar.
  final String emoji;

  /// Categoria editorial — define a ilustracao no painter e o filtro
  /// no catalogo.
  final ProductCategory category;

  /// Linha curta de catalogo (ex.: "Torra media", "Bolso A6").
  final String subtitle;

  /// Texto editorial pro detalhe (1-2 paragrafos).
  final String description;

  /// Origem / produtor / atelie (opcional). Vazio quando nao aplicavel.
  final String origin;

  /// Opcoes de personalizacao do produto (torra, cor, tamanho).
  final List<ProductVariant> variants;

  /// Preco base + delta da variante (em centavos). Quando [variant] e
  /// null, retorna [priceCents].
  double priceWithVariantCents(ProductVariant? variant) {
    if (variant == null) return priceCents;
    return priceCents + variant.deltaCents;
  }

  /// Formatado como BRL: "R\$ 129,90".
  String get formattedPrice => formatBrl(priceCents);

  @override
  List<Object?> get props => [
        id,
        name,
        priceCents,
        emoji,
        category,
        subtitle,
        description,
        origin,
        variants,
      ];
}
