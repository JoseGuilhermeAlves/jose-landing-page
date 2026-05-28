import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/program_week.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:flutter/foundation.dart';

/// Mesociclo completo — periodizacao de 8 semanas com progressao de
/// carga e deload final. Imutavel; entidade raiz que agrega
/// [ProgramWeek] e [SessionTemplate].
@immutable
class Program extends Equatable {
  const Program({
    required this.id,
    required this.name,
    required this.tagline,
    required this.weeks,
    required this.currentWeekIndex,
  });

  /// `hypertrophy-ppl-8w`, `strength-ul-6w`.
  final String id;

  /// Nome exibivel: "Hipertrofia PPL · 8 semanas".
  final String name;

  /// Subtitulo curto pra cards: "Push / Pull / Legs · 4x na semana".
  final String tagline;

  /// 8 semanas (ou quantas o programa tiver). Indexadas 1..N.
  final List<ProgramWeek> weeks;

  /// Semana ativa (1-based). Pro mock vem do catalogo.
  final int currentWeekIndex;

  int get durationWeeks => weeks.length;

  ProgramWeek? get currentWeek {
    for (final w in weeks) {
      if (w.index == currentWeekIndex) return w;
    }
    return weeks.isEmpty ? null : weeks.first;
  }

  /// Sessao planejada pra um dia da semana atual, ou `null` em descanso.
  SessionTemplate? sessionForToday(int weekday) =>
      currentWeek?.sessionFor(weekday);

  @override
  List<Object?> get props => [id, name, tagline, weeks, currentWeekIndex];

  @override
  String toString() => 'Program($id, week $currentWeekIndex/$durationWeeks)';
}
