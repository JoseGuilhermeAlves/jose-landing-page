import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:flutter/foundation.dart';

/// Profissional do estudio Vitral. Sem foto real — a ilustracao usa o
/// glifo da categoria principal mais um monograma com as iniciais.
@immutable
class Specialist extends Equatable {
  const Specialist({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    this.photoAsset,
  });

  final String id;

  /// Nome do profissional ("Sofia A.", "Lucas M.") — primeiro nome +
  /// inicial pra preservar privacidade no mock sem virar generico.
  final String name;

  /// Cargo curto ("Estrategista", "Fotografa", "Designer UI").
  final String role;

  /// Bio curta de 1-2 linhas pro card.
  final String bio;

  /// Categorias que esse profissional atende. A primeira e a principal.
  final List<ServiceCategory> categories;

  /// Nota de 0 a 5 (mock, sem reviews reais).
  final double rating;

  /// Numero de avaliacoes (mock).
  final int reviewCount;

  /// Caminho do asset de headshot (relativo ao pacote `feature_showcase`,
  /// ex.: `assets/scheduling/sofia_a.webp`). Null cai no
  /// `ShowcaseMonogramAvatar` via `ShowcasePhoto` — entao o painter de
  /// monograma continua como rede de seguranca quando os `.webp` ainda
  /// nao existem. Aditivo: default null preserva compat com testes
  /// legados.
  final String? photoAsset;

  /// Categoria principal (primeira da lista).
  ServiceCategory get primaryCategory => categories.first;

  /// Iniciais usadas no monograma do avatar desenhado em painter.
  String get monogram {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    bio,
    categories,
    rating,
    reviewCount,
    photoAsset,
  ];
}
