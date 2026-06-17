import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing/presentation/locale_cubit.dart';
import 'package:landing/widgets/home_nav.dart';

/// Largura da coluna de navegacao lateral no desktop. O conteudo da home
/// reserva esse espaco a esquerda.
const double kArcadeSideNavWidth = 232;

/// Menu lateral "STAGE SELECT" — a navegacao da landing Arcade como um
/// menu de fliperama. Coluna fixa a esquerda (desktop) com:
/// wordmark ZeguiDev em pixel no topo, lista de "stages" (secoes) com cursor ▸
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

  /// Mesmas ancoras do scroll-spy — ordem define a numeracao dos stages.
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

class _ArcadeSideNavState extends State<ArcadeSideNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;
  int _hovered = -1;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _blink
        ..stop()
        ..value = 1;
    } else if (!_blink.isAnimating) {
      _blink.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: kArcadeSideNavWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: colors.primary.withValues(alpha: 0.25)),
        ),
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
              Text(
                'STAGE SELECT',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

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
                          blink: _blink,
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

/// Uma linha de "stage" no menu: numero + label, com cursor ▸ piscante e
/// glow neon quando ativa ou em hover.
class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.index,
    required this.anchor,
    required this.active,
    required this.hovered,
    required this.blink,
    required this.onEnter,
    required this.onExit,
  });

  final int index;
  final HomeNavAnchor anchor;
  final bool active;
  final bool hovered;
  final Animation<double> blink;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lit = active || hovered;
    final color = active
        ? colors.accent
        : (hovered ? colors.primary : colors.onSurfaceMuted);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: anchor.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: lit
                    ? FadeTransition(
                        opacity: active
                            ? blink
                            : const AlwaysStoppedAnimation<double>(1),
                        child: PixelText(
                          '~',
                          color: color,
                          glowColor: color,
                          pixelSize: 3,
                        ),
                      )
                    : null,
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: PixelText(
                    anchor.label,
                    color: color,
                    glowColor: lit ? color : null,
                    pixelSize: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botao social compacto em pixel ("GH"/"IN") com borda neon.
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
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: PixelText(widget.label, color: color, pixelSize: 3),
          ),
        ),
      ),
    );
  }
}
