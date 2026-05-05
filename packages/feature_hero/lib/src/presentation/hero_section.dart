import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Topo da landing. Layout responsivo:
/// - mobile (< 600px): coluna unica, CTAs empilhados;
/// - tablet+: coluna unica de texto centralizada, CTAs lado-a-lado.
///
/// O fundo usa [ParticleField] (custom painter §5.1) — coracao tecnico
/// do projeto. Callbacks de CTA sobem para o app shell, que decide
/// como abrir WhatsApp / scrollar para a secao de projetos.
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
    );

    final subheadlineStyle = textTheme.titleMedium?.copyWith(
      color: colors.onSurfaceMuted,
      height: 1.4,
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
        vertical: AppSpacing.huge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Semantics(
              header: true,
              child: Text(
                'Aplicativos Flutter de qualidade — do MVP ao app em '
                'producao',
                style: headlineStyle,
                textAlign: isMobile ? TextAlign.start : TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              '7+ anos construindo apps mobile e web — de operacao '
              'varejista a produto fintech em escala.',
              style: subheadlineStyle,
              textAlign: isMobile ? TextAlign.start : TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CtaRow(
            isMobile: isMobile,
            onContactPressed: onContactPressed,
            onSeeProjectsPressed: onSeeProjectsPressed,
          ),
        ],
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fundo animado. `IgnorePointer` deixa o mouse passar para os
        // CTAs sem que o ParticleField roube hover.
        const Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: ParticleField(
              particleCount: 48,
            ),
          ),
        ),
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
