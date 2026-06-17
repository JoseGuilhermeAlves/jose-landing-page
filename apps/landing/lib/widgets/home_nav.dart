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
    this.icon,
  });

  final String id;
  final String label;
  final VoidCallback onTap;

  /// Icone exibido na bottom bar mobile. Ignorado pela nav desktop
  /// (inline) e pelo menu overflow do tablet.
  final IconData? icon;
}

/// Barra de navegacao fixa no topo da home. Translucida com blur de
/// fundo (BackdropFilter) — pattern Linear/Vercel/Stripe — composta
/// por logo (esquerda), lista de ancoras (centro, >= 1180px) e CTA
/// "Falar" (direita).
///
/// Abaixo de 1180px as ancoras inline nao cabem na altura fixa da
/// barra; colapsam num menu overflow (icone a direita) que lista as
/// mesmas secoes. Assim tablet e mobile mantem navegacao in-page em
/// vez de depender so do CTA.
class HomeNav extends StatelessWidget {
  const HomeNav({
    required this.anchors,
    required this.onLogoTap,
    required this.onCtaTap,
    this.githubUrl,
    this.linkedinUrl,
    this.onOpenSocial,
    super.key,
  });

  final List<HomeNavAnchor> anchors;
  final VoidCallback onLogoTap;
  final VoidCallback onCtaTap;

  /// Perfil GitHub — exibido como icone a direita (>= 600px). Funil
  /// tech/recruiter: o avaliador chega no codigo em um clique.
  final String? githubUrl;

  /// Perfil LinkedIn — idem.
  final String? linkedinUrl;

  /// Abre a URL dos icones sociais. O shell decide o launcher.
  final ValueChanged<String>? onOpenSocial;

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
                    if (!isMobile) ...[
                      if (githubUrl != null)
                        _SocialIcon(
                          key: const Key('home-nav-github'),
                          icon: Icons.code,
                          tooltip: 'GitHub',
                          onTap: () => onOpenSocial?.call(githubUrl!),
                        ),
                      if (linkedinUrl != null)
                        _SocialIcon(
                          key: const Key('home-nav-linkedin'),
                          icon: Icons.work_outline,
                          tooltip: 'LinkedIn',
                          onTap: () => onOpenSocial?.call(linkedinUrl!),
                        ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
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
                    if (isCompact && !isMobile && anchors.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      _AnchorsMenu(anchors: anchors),
                    ],
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

    return Tooltip(
      message: context.l10n.nav_backToTop,
      child: Semantics(
        button: true,
        label: 'ZeguiDev',
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: const Key('home-nav-logo'),
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PixelText('ZEGUI', color: colors.onSurface, pixelSize: 3),
                const SizedBox(width: 3),
                PixelText(
                  'DEV',
                  color: colors.primary,
                  glowColor: colors.primary,
                  pixelSize: 3,
                ),
              ],
            ),
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
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final highlighted = _hovering || _focused;

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (v) => setState(() => _hovering = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.anchor.onTap();
            return null;
          },
        ),
      },
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
            color: highlighted
                ? colors.surface.withValues(alpha: 0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: _focused
                  ? colors.primary.withValues(alpha: 0.7)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.anchor.label,
            style: textTheme.labelMedium?.copyWith(
              color: highlighted ? colors.onSurface : colors.onSurfaceMuted,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icone social da nav (GitHub/LinkedIn). `IconButton` ja entrega foco
/// por teclado, ativacao por Enter/Espaco e tooltip — nao precisa de
/// detector custom.
class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: colors.onSurfaceMuted),
      hoverColor: colors.surface.withValues(alpha: 0.8),
      focusColor: colors.primary.withValues(alpha: 0.18),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Menu overflow das ancoras pra viewports compactas (< 1180px), onde
/// a lista inline nao cabe na altura fixa da barra. O `PopupMenuButton`
/// ja traz tooltip localizado ("Mostrar menu") via `MaterialLocalizations`,
/// entao nao precisa de string propria.
class _AnchorsMenu extends StatelessWidget {
  const _AnchorsMenu({required this.anchors});
  final List<HomeNavAnchor> anchors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<HomeNavAnchor>(
      key: const Key('home-nav-menu'),
      icon: Icon(Icons.menu_rounded, color: colors.onSurface),
      color: colors.surface,
      onSelected: (anchor) => anchor.onTap(),
      itemBuilder: (context) => [
        for (final a in anchors)
          PopupMenuItem<HomeNavAnchor>(
            key: Key('home-nav-menu-${a.id}'),
            value: a,
            child: Text(a.label),
          ),
      ],
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: context.l10n.nav_ctaContact,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const Key('home-nav-cta'),
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.16),
              border: Border.all(color: colors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: PixelText(
                context.l10n.nav_ctaContact,
                color: colors.primary,
                glowColor: colors.primary,
                pixelSize: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
