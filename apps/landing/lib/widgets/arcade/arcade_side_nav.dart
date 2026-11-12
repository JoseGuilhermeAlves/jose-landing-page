import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing/presentation/locale_cubit.dart';
import 'package:landing/widgets/home_nav.dart';

/// Largura da coluna de navegacao lateral no desktop. O conteudo da home
/// reserva esse espaco a esquerda.
const double kArcadeSideNavWidth = 232;

/// Menu lateral "STAGE SELECT" â€” a navegacao da landing Arcade como um
/// menu de fliperama. Coluna fixa a esquerda (desktop) com:
/// wordmark ZeguiDev em pixel no topo, lista de "stages" (secoes) com cursor â–¸
/// piscante na ativa + glow neon, e sociais no rodape.
///
/// O indicador de secao ativa vem do scroll-spy da home
/// ([activeIndex]); o cursor pisca via um unico controller.
class ArcadeSideNav extends StatefulWidget {
  const ArcadeSideNav({
    required this.anchors,
    required this.activeIndex,
    required this.onLogoTap,
    this.githubUrl,
    this.linkedinUrl,
    this.onOpenSocial,
    super.key,
  });

  /// Mesmas ancoras do scroll-spy â€” ordem define a numeracao dos stages.
  final List<HomeNavAnchor> anchors;

  /// Indice da secao ativa (-1 = topo/hero). Alimentado pelo scroll-spy.
  final ValueListenable<int> activeIndex;

  final VoidCallback onLogoTap;
  final String? githubUrl;
  final String? linkedinUrl;
  final ValueChanged<String>? onOpenSocial;

  @override
  State<ArcadeSideNav> createState() => _ArcadeSideNavState();
}

class _ArcadeSideNavState extends State<ArcadeSideNav> {
  int _hovered = -1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: kArcadeSideNavWidth,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                label: 'ZeguiDev',
                excludeSemantics: true,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onLogoTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PixelText(
                          'ZEGUI',
                          color: colors.onSurface,
                          pixelSize: 3,
                        ),
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
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(height: AppSpacing.md),

              ValueListenableBuilder<int>(
                valueListenable: widget.activeIndex,
                builder: (context, active, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < widget.anchors.length; i++)
                        _StageRow(
                          index: i,
                          anchor: widget.anchors[i],
                          active: i == active,
                          hovered: i == _hovered,
                          onEnter: () => setState(() => _hovered = i),
                          onExit: () => setState(() => _hovered = -1),
                        ),
                    ],
                  );
                },
              ),

              const Spacer(),

              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) => LocaleSwitcher(
                  currentLocale: locale,
                  onLocaleChanged: (l) =>
                      context.read<LocaleCubit>().changeLocale(l),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.githubUrl != null)
                    _SocialDot(
                      label: 'GitHub',
                      onTap: () => widget.onOpenSocial?.call(widget.githubUrl!),
                    ),
                  if (widget.linkedinUrl != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _SocialDot(
                      label: 'LinkedIn',
                      onTap: () =>
                          widget.onOpenSocial?.call(widget.linkedinUrl!),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uma linha de "stage" no menu: numero + label, com cursor â–¸ piscante e
/// glow neon quando ativa ou em hover.
class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.index,
    required this.anchor,
    required this.active,
    required this.hovered,
    required this.onEnter,
    required this.onExit,
  });

  final int index;
  final HomeNavAnchor anchor;
  final bool active;
  final bool hovered;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final color = active
        ? colors.onSurface
        : (hovered ? colors.onSurface : colors.onSurfaceMuted);

    return Semantics(
      button: true,
      selected: active,
      label: anchor.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onEnter(),
        onExit: (_) => onExit(),
        child: GestureDetector(
          onTap: anchor.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm + 2,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: active
                  ? colors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: active ? colors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: PixelText(
                    (index + 1).toString().padLeft(2, '0'),
                    color: active
                        ? colors.primary
                        : colors.onSurfaceMuted.withValues(alpha: 0.55),
                    pixelSize: 1.5,
                  ),
                ),
                Flexible(
                  child: Text(
                    anchor.label,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(
                      color: color,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialDot extends StatefulWidget {
  const _SocialDot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_SocialDot> createState() => _SocialDotState();
}

class _SocialDotState extends State<_SocialDot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _hovered ? colors.accent : colors.onSurfaceMuted;

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: color),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.north_east_rounded, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
