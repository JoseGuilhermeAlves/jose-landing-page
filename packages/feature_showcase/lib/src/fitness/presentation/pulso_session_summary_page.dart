import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_recovery.dart';
import 'package:feature_showcase/src/fitness/domain/session_summary.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_body_diagram.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_summary_burst.dart';
import 'package:flutter/material.dart';

/// Resumo pos-treino — o "payoff" do loop de logging. Empurrado em
/// full-screen quando o atleta finaliza a sessao, substituindo o
/// snackbar anticlimatico anterior. Mostra volume, sets, PRs, strain,
/// impacto no recovery e mapa muscular do que foi trabalhado.
///
/// O mesmo corpo (`_SummaryBody`) e reusado no recap read-only do
/// historico (`PulsoHistoryPage`) — la sem animacao de entrada e com
/// um titulo de "registro" em vez do tom de celebracao.
class PulsoSessionSummaryPage extends StatefulWidget {
  const PulsoSessionSummaryPage({
    required this.session,
    required this.template,
    this.readOnly = false,
    super.key,
  });

  final LoggedSession session;
  final SessionTemplate template;

  /// Quando true, e o recap do historico: sem animacao de entrada nem
  /// copy de celebracao, e o CTA vira "Voltar".
  final bool readOnly;

  @override
  State<PulsoSessionSummaryPage> createState() =>
      _PulsoSessionSummaryPageState();
}

class _PulsoSessionSummaryPageState extends State<PulsoSessionSummaryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final SessionSummary _summary;

  @override
  void initState() {
    super.initState();
    _summary = SessionSummary.fromSession(
      session: widget.session,
      template: widget.template,
      nameOf: (id) => ExercisesCatalog.byId(id)?.name ?? id,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (!widget.readOnly) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: colors.background,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.readOnly ? 'Registro do treino' : 'Treino concluído',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _SummaryBody(
        summary: _summary,
        progress: widget.readOnly ? null : _controller,
        readOnly: widget.readOnly,
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.summary,
    required this.readOnly,
    this.progress,
  });

  final SessionSummary summary;
  final Animation<double>? progress;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strainColor = FitnessBrand.strainColor(summary.strainDelta);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        // --- Cabecalho com selo animado + headline. ---
        Center(
          child: PulsoSummaryBurst(
            color: colors.primary,
            progress: progress,
            diameter: 104,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          readOnly ? summary.templateLabel : 'Mandou bem, atleta!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          readOnly
              ? 'Semana ${summary.programWeek} · ${summary.completedSets} sets'
              : '${summary.templateLabel} fechado. Aqui está o que rolou.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // --- Grid de KPIs principais. ---
        // IntrinsicHeight limita o eixo vertical da Row pra que o
        // `stretch` (cards de mesma altura) funcione dentro do ListView,
        // que dá altura ilimitada aos filhos — sem ele, stretch propaga
        // h=Infinity e estoura "BoxConstraints forces an infinite height".
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'VOLUME',
                  value: summary.totalVolumeTons.toStringAsFixed(1),
                  unit: 't',
                  accent: colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  label: 'SETS',
                  value: '${summary.completedSets}',
                  unit: '',
                  accent: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'STRAIN',
                  value: summary.strainDelta.toStringAsFixed(1),
                  unit: '',
                  accent: strainColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _KpiCard(
                  label: 'DURAÇÃO',
                  value: _durationLabel(summary.duration),
                  unit: '',
                  accent: colors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // --- Impacto no recovery do dia seguinte. ---
        _RecoveryImpactCard(percent: summary.recoveryImpactPercent),

        // --- PRs da sessao. ---
        if (summary.prs.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel(label: 'RECORDES DA SESSÃO'),
          const SizedBox(height: AppSpacing.sm),
          _PrList(prs: summary.prs),
        ],

        // --- Mapa muscular do que foi trabalhado. ---
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel(label: 'MÚSCULOS TRABALHADOS'),
        const SizedBox(height: AppSpacing.sm),
        _MuscleMapCard(summary: summary),

        if (!readOnly) ...[
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                'Voltar para Hoje',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _durationLabel(Duration d) {
    if (d.inMinutes <= 0) return '—';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    return '${m}min';
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                  fontFeatures: FitnessBrand.numFeatures,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: colors.onSurfaceMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveryImpactCard extends StatelessWidget {
  const _RecoveryImpactCard({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.14),
            colors.accent.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.bedtime_outlined, color: colors.accent, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impacto no recovery',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Esse treino vai pedir umas ${percent.toStringAsFixed(0)}% '
                  'a mais de recuperação amanhã. Capriche no sono.',
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrList extends StatelessWidget {
  const _PrList({required this.prs});
  final List<ExercisePr> prs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        children: [
          for (var i = 0; i < prs.length; i++) ...[
            if (i > 0) Divider(color: colors.border, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: colors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      prs[i].exerciseName,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${prs[i].weightKg.toStringAsFixed(0)}kg × ${prs[i].reps}',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: FitnessBrand.displayMonoFontFamily,
                      fontFeatures: FitnessBrand.numFeatures,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MuscleMapCard extends StatelessWidget {
  const _MuscleMapCard({required this.summary});
  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mostWorked = summary.mostWorkedMuscle;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: PulsoBodyDiagram(
              recovery: _workedToRecovery(summary.volumePerMuscle),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mostWorked == null
                      ? 'Sem volume registrado nesta sessão.'
                      : 'Quem mais sofreu: ${mostWorked.label.toLowerCase()}.',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'As regiões mais quentes foram as que absorveram mais '
                  'volume. Esfria, hidrata e deixa o recovery subir.',
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Converte volume por musculo numa pseudo-leitura de recovery pro
  /// body diagram: o grupo mais castigado vira "vermelho" (baixo
  /// recovery = fadiga alta); grupos sem volume ficam neutros (100).
  MuscleRecovery _workedToRecovery(Map<MuscleGroup, double> worked) {
    if (worked.isEmpty) return const MuscleRecovery(scores: {});
    var maxVolume = 0.0;
    for (final v in worked.values) {
      if (v > maxVolume) maxVolume = v;
    }
    if (maxVolume <= 0) return const MuscleRecovery(scores: {});
    final scores = <MuscleGroup, double>{};
    worked.forEach((group, volume) {
      // Mais volume => mais perto de 15 (vermelho); menos => perto de 70.
      final intensity = (volume / maxVolume).clamp(0.0, 1.0);
      scores[group] = 70 - intensity * 55;
    });
    return MuscleRecovery(scores: scores);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.colors.onSurfaceMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }
}
