import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Topo da landing. Composicao em camadas:
/// 1. glow radial sutil atras do texto (depth);
/// 2. ParticleField como background (custom painter §5.1) — particulas
///    com alpha reduzido pra nao competir com headline;
/// 3. fade-out gradient no rodape — particulas escorregam pro
///    background da proxima secao em vez de cortar abrupto;
/// 4. conteudo centralizado: eyebrow chip, headline em 2 linhas (a
///    segunda em gradient brand), subhead, CTAs e trust strip.
///
/// Layout responsivo: tudo center-aligned em desktop, start-aligned
/// em mobile.
class HeroSection extends StatelessWidget {
  const HeroSection({
    this.onContactPressed,
    this.onSeeProjectsPressed,
    super.key,
  });

  /// Disparado pelo CTA primario "Falar no WhatsApp". Espera-se que o
  /// shell abra `wa.me/...` (PROJECT.md §4.1).
  final VoidCallback? onContactPressed;

  /// Disparado pelo CTA secundario "Ver projetos". Espera-se que o
  /// shell scrolle ate a secao de showcase.
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final headlineStyle = (isMobile
            ? textTheme.displaySmall
            : textTheme.displayMedium)
        ?.copyWith(
      color: colors.onSurface,
      height: 1.05,
      letterSpacing: -1.2,
    );

    final crossAxisAlignment =
        isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = isMobile ? TextAlign.start : TextAlign.center;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
        vertical: AppSpacing.huge,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            const EyebrowBadge(label: 'Disponivel pra freelas'),
            SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
            Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Front end mobile com Flutter.',
                    style: headlineStyle,
                    textAlign: textAlign,
                  ),
                  GradientText(
                    text: 'Do MVP ao app em producao.',
                    gradient: AppGradients.brand(colors),
                    style: headlineStyle,
                    textAlign: textAlign,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                '7+ anos construindo o front end de apps mobile (e web '
                'quando faz sentido) — atuando do varejo B2B a produto '
                'fintech em escala.',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: textAlign,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _CtaRow(
              isMobile: isMobile,
              onContactPressed: onContactPressed,
              onSeeProjectsPressed: onSeeProjectsPressed,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _TrustStrip(isMobile: isMobile),
          ],
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Glow radial atras do headline — sumindo pras bordas.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.glow(
                  colors.primary,
                  opacity: 0.16,
                  radius: 0.55,
                ),
              ),
            ),
          ),
        ),
        // ParticleField com alphas reduzidos pra nao competir com texto.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: ParticleField(
              particleCount: 48,
              particleColor: colors.primary.withValues(alpha: 0.55),
              linkColor: colors.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Fade-out no rodape — particulas escorregam pro background.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 160,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, colors.background],
                ),
              ),
            ),
          ),
        ),
        // Conteudo.
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: content,
          ),
        ),
      ],
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.isMobile,
    required this.onContactPressed,
    required this.onSeeProjectsPressed,
  });

  final bool isMobile;
  final VoidCallback? onContactPressed;
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final whatsapp = AppButton(
      label: 'Falar no WhatsApp',
      onPressed: onContactPressed,
      size: AppButtonSize.large,
      icon: Icons.chat_bubble_outline,
      expand: isMobile,
    );

    final projects = AppButton(
      label: 'Ver projetos',
      onPressed: onSeeProjectsPressed,
      size: AppButtonSize.large,
      variant: AppButtonVariant.secondary,
      icon: Icons.arrow_forward,
      expand: isMobile,
    );

    if (isMobile) {
      // SizedBox.expand-width converte a constraint frouxa do Column pai
      // em tight, condicao necessaria para `crossAxisAlignment.stretch`
      // e para `expand:true` do AppButton funcionarem sem overflow.
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            whatsapp,
            const SizedBox(height: AppSpacing.md),
            projects,
          ],
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [whatsapp, projects],
    );
  }
}

/// Strip de prova social abaixo dos CTAs. Cada chip e vertical
/// (valor em destaque, label uppercase abaixo) — formato compacto
/// que cabe ate em viewport mobile estreito sem overflow.
class _TrustStrip extends StatelessWidget {
  const _TrustStrip({required this.isMobile});
  final bool isMobile;

  static const List<_TrustStat> _stats = [
    _TrustStat(value: '7+', label: 'anos de Flutter'),
    _TrustStat(value: '5+', label: 'dominios atuados'),
    _TrustStat(value: 'Mobile · Web', label: 'plataformas-alvo'),
  ];

  @override
  Widget build(BuildContext context) {
    final crossAxisAlign =
        isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center;

    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.lg,
      alignment: isMobile ? WrapAlignment.start : WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (final stat in _stats)
          _TrustStatChip(stat: stat, crossAxisAlignment: crossAxisAlign),
      ],
    );
  }
}

class _TrustStat {
  const _TrustStat({required this.value, required this.label});
  final String value;
  final String label;
}

class _TrustStatChip extends StatelessWidget {
  const _TrustStatChip({
    required this.stat,
    required this.crossAxisAlignment,
  });
  final _TrustStat stat;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          stat.value,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
