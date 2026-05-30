import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing/presentation/locale_cubit.dart';

/// Altura padrao do `HomeNav`. Exposta para que a `HomePage` reserve
/// o mesmo espaco no topo do scroll view (pra que o conteudo nao
/// fique atras da barra) e calcule offset correto ao animar para
/// uma ancora.
const double kHomeNavHeight = 68;

/// Ancora navegavel no `HomeNav`. [label] e o texto exibido; [onTap]
/// e o callback que sabe como rolar pra secao correspondente — quem
/// monta o `HomeNav` (a `HomePage`) prepara cada callback usando os
/// `GlobalKey`s das secoes.
@immutable
class HomeNavAnchor {
  const HomeNavAnchor({
    required this.id,
    required this.label,
    required this.onTap,
  });

  final String id;
  final String label;
  final VoidCallback onTap;
}

/// Barra de navegacao fixa no topo da home. Translucida com blur de
/// fundo (BackdropFilter) — pattern Linear/Vercel/Stripe — composta
/// por logo (esquerda), lista de ancoras (centro, >= tablet) e CTA
/// "Falar" (direita).
///
/// Em mobile so o logo e o CTA aparecem; as ancoras seriam apertadas
/// demais. O CTA passa a ser o caminho rapido pra Contact e o logo
/// volta pro topo.
class HomeNav extends StatelessWidget {
  const HomeNav({
    required this.anchors,
    required this.onLogoTap,
    required this.onCtaTap,
    super.key,
  });

  final List<HomeNavAnchor> anchors;
  final VoidCallback onLogoTap;
  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;
    final isCompact = MediaQuery.sizeOf(context).width < 1180;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(color: colors.border.withValues(alpha: 0.6)),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kHomeNavHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
                ),
                child: Row(
                  children: [
                    _Logo(onTap: onLogoTap),
                    if (!isCompact) ...[
                      const Spacer(),
                      _Anchors(anchors: anchors),
                      const Spacer(),
                    ] else
                      const Spacer(),
                    BlocBuilder<LocaleCubit, Locale>(
                      builder: (context, locale) {
                        return LocaleSwitcher(
                          currentLocale: locale,
                          onLocaleChanged: (l) =>
                              context.read<LocaleCubit>().changeLocale(l),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _Cta(onTap: onCtaTap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    // Wordmark "ZeguiDev" puro (sem icone). Sufixo "Dev" em gradient
    // brand pra carregar a identidade visual sem mark separado.
    final baseStyle = textTheme.titleSmall?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );

    return Tooltip(
      message: context.l10n.nav_backToTop,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const Key('home-nav-logo'),
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Zegui', style: baseStyle),
              GradientText(
                text: 'Dev',
                gradient: AppGradients.brand(colors),
                style: baseStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Anchors extends StatelessWidget {
  const _Anchors({required this.anchors});
  final List<HomeNavAnchor> anchors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [for (final a in anchors) _AnchorButton(anchor: a)],
    );
  }
}

class _AnchorButton extends StatefulWidget {
  const _AnchorButton({required this.anchor});
  final HomeNavAnchor anchor;

  @override
  State<_AnchorButton> createState() => _AnchorButtonState();
}

class _AnchorButtonState extends State<_AnchorButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        key: Key('home-nav-anchor-${widget.anchor.id}'),
        onTap: widget.anchor.onTap,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _hovering
                ? colors.surface.withValues(alpha: 0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            widget.anchor.label,
            style: textTheme.labelMedium?.copyWith(
              color: _hovering ? colors.onSurface : colors.onSurfaceMuted,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      key: const Key('home-nav-cta'),
      label: context.l10n.nav_ctaContact,
      onPressed: onTap,
      icon: Icons.mail_outline,
    );
  }
}
