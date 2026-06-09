import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/mesocycle_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_session_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Historico de treinos da sessao de uso. Lista as [LoggedSession]
/// finalizadas (da mais recente pra mais antiga) com data, volume e
/// strain. Tap em um card abre o recap read-only (reusa o
/// [PulsoSessionSummaryPage] em modo `readOnly`).
///
/// Empurrado a partir do header do Today. Quando ainda nao ha treinos
/// registrados na sessao, mostra um estado vazio com tom da marca.
class PulsoHistoryPage extends StatelessWidget {
  const PulsoHistoryPage({super.key});

  static const _monthLabels = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: colors.background,
        iconTheme: IconThemeData(color: colors.onSurface),
        title: Text(
          'Histórico',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<FitnessBloc, FitnessState>(
        builder: (context, state) {
          final sessions = state.completedSessions;
          if (sessions.isEmpty) return const _EmptyHistory();
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final session = sessions[i];
              return _HistoryCard(
                session: session,
                dateLabel: _dateLabel(session),
                onTap: () => _openRecap(context, session),
              );
            },
          );
        },
      ),
    );
  }

  String _dateLabel(LoggedSession session) {
    final d = session.finishedAt ?? session.startedAt;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_monthLabels[d.month - 1]} · $hh:$mm';
  }

  void _openRecap(BuildContext context, LoggedSession session) {
    final bloc = context.read<FitnessBloc>();
    final template = _templateFor(session.templateId);
    if (template == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: PulsoSessionSummaryPage(
            session: session,
            template: template,
            readOnly: true,
          ),
        ),
      ),
    );
  }

  /// Resolve o template original a partir do id armazenado na sessao —
  /// varre as semanas do mesociclo padrao. Mantem o historico
  /// independente do estado atual do programa.
  SessionTemplate? _templateFor(String templateId) {
    final program = MesocycleCatalog.build();
    for (final week in program.weeks) {
      for (final template in week.sessions) {
        if (template.id == templateId) return template;
      }
    }
    return null;
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.session,
    required this.dateLabel,
    required this.onTap,
  });

  final LoggedSession session;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strainColor = FitnessBrand.strainColor(session.peakStrain);
    final tons = (session.totalVolumeKg / 1000).toStringAsFixed(1);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: colors.onSurfaceMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Semana ${session.programWeek} · '
                      '${session.completedSetsCount} sets',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniStat(label: 'VOL', value: '${tons}t', color: colors.onSurface),
              const SizedBox(width: AppSpacing.md),
              _MiniStat(
                label: 'STRAIN',
                value: session.peakStrain.toStringAsFixed(1),
                color: strainColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: FitnessBrand.displayMonoFontFamily,
            fontFeatures: FitnessBrand.numFeatures,
          ),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: colors.onSurfaceMuted,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhum treino registrado ainda',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Termine uma sessão e ela aparece aqui com volume, '
              'strain e os recordes do dia.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
