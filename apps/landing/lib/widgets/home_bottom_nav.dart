import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/home_nav.dart';

/// Altura da `HomeBottomNav` (sem contar a safe area inferior). A
/// `HomePage` reserva esse espaco no fim do scroll pra que o footer nao
/// fique atras da barra.
const double kHomeBottomNavHeight = 64;

/// Barra de navegacao fixa no rodape — o "stage select" da visao mobile,
/// no mesmo vocabulario arcade do `ArcadeSideNav` do desktop: vidro
/// translucido (BackdropFilter) com hairline neon no topo, um item por
/// ancora com label em fonte pixel ([PixelText]) e indicador chunky neon
/// (cantos retos + glow) que acende na secao ativa derivada do scroll
/// (scroll-spy). Ativo em ciano, repouso em muted.
///
/// So e montada em mobile (`context.isMobile`); tablet/desktop usam o
/// `ArcadeSideNav` lateral.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    required this.anchors,
    required this.activeIndex,
    super.key,
  });

  final List<HomeNavAnchor> anchors;

  /// Indice da ancora ativa (secao atualmente no topo do viewport). -1
  /// quando nenhuma esta ativa (ex.: ainda no hero).
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.82),
            // Hairline neon no topo — mesma assinatura do menu lateral arcade.
            border: Border(
              top: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: kHomeBottomNavHeight,
              child: Row(
                children: [
                  for (var i = 0; i < anchors.length; i++)
                    Expanded(
                      child: _BottomNavItem(
                        anchor: anchors[i],
                        active: i == activeIndex,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.anchor, required this.active});

  final HomeNavAnchor anchor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Ativo em ciano neon; repouso em muted (vocabulario do ArcadeSideNav).
    final tint = active ? colors.accent : colors.onSurfaceMuted;

    return Semantics(
      button: true,
      selected: active,
      label: anchor.label,
      child: InkWell(
        key: Key('home-bottom-nav-${anchor.id}'),
        onTap: anchor.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador chunky neon (cantos retos + glow) que acende na ativa.
            AnimatedContainer(
              duration: AppDuration.fast,
              height: 3,
              width: active ? 22 : 0,
              decoration: BoxDecoration(
                color: colors.accent,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Label em fonte pixel — assinatura arcade. FittedBox encolhe
            // labels longos (ex.: ENGENHARIA) pra caber na largura do item.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: PixelText(
                  anchor.label,
                  color: tint,
                  glowColor: active ? colors.accent : null,
                  pixelSize: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
