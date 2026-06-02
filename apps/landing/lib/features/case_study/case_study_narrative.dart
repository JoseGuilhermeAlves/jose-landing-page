import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Narrativa "por que pintar" — eyebrow + titulo + 3 paragrafos longos
/// explicando o trade-off (Canvas x asset x Lottie) e a arquitetura do
/// CosmosPainter. Coluna legivel, sem cards aninhados.
class CaseStudyNarrative extends StatelessWidget {
  const CaseStudyNarrative({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.caseStudy_pivotEyebrow,
          style: tt.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.caseStudy_pivotTitle,
          style: (context.isMobile ? tt.headlineSmall : tt.headlineMedium)
              ?.copyWith(
                color: colors.onSurface,
                height: 1.2,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Paragraph(context.l10n.caseStudy_pivotPara1),
        const SizedBox(height: AppSpacing.md),
        _Paragraph(context.l10n.caseStudy_pivotPara2),
        const SizedBox(height: AppSpacing.md),
        _Paragraph(context.l10n.caseStudy_pivotPara3),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceMuted,
          height: 1.65,
        ),
      ),
    );
  }
}

/// Decisoes tecnicas (rendering / determinismo / batch) em 3 cards +
/// takeaway de fechamento com gradient brand.
class CaseStudyDecisions extends StatelessWidget {
  const CaseStudyDecisions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isMobile = context.isMobile;
    final decisions = [
      _DecisionCard(
        eyebrow: l10n.caseStudy_decisionArchEyebrow,
        title: l10n.caseStudy_decisionArchTitle,
        body: l10n.caseStudy_decisionArchBody,
      ),
      _DecisionCard(
        eyebrow: l10n.caseStudy_decisionPaintersEyebrow,
        title: l10n.caseStudy_decisionPaintersTitle,
        body: l10n.caseStudy_decisionPaintersBody,
      ),
      _DecisionCard(
        eyebrow: l10n.caseStudy_decisionStateEyebrow,
        title: l10n.caseStudy_decisionStateTitle,
        body: l10n.caseStudy_decisionStateBody,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            children: [
              for (var i = 0; i < decisions.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                decisions[i],
              ],
            ],
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < decisions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(child: decisions[i]),
                ],
              ],
            ),
          ),
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.xl,
            desktop: AppSpacing.huge,
          ),
        ),
        const _ClosingTakeaway(),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow,
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosingTakeaway extends StatelessWidget {
  const _ClosingTakeaway();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.12),
            colors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.caseStudy_takeawayEyebrow,
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.caseStudy_takeawayTitle,
            style: tt.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.caseStudy_takeawayBody,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
