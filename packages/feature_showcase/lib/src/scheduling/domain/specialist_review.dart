import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Avaliacao mock de um profissional do estudio Vitral. Sem backend —
/// dados estaticos curados no `VitralReviewsCatalog`. Cada review
/// pertence a um `Specialist` via [specialistId].
@immutable
class SpecialistReview extends Equatable {
  const SpecialistReview({
    required this.id,
    required this.specialistId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.relativeDate,
  });

  final String id;

  /// FK pro Specialist avaliado.
  final String specialistId;

  /// Nome de quem avaliou (primeiro nome + inicial — fala ficticia).
  final String authorName;

  /// Nota de 1 a 5.
  final int rating;

  /// Comentario curto da avaliacao.
  final String comment;

  /// Rotulo relativo ("ha 3 dias", "ha 2 semanas") — mock sem timestamp
  /// real pra nao envelhecer a demo.
  final String relativeDate;

  /// Iniciais do autor pro avatar monograma.
  String get authorMonogram {
    final parts = authorName.split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    specialistId,
    authorName,
    rating,
    comment,
    relativeDate,
  ];
}
