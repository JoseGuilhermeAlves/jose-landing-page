import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/home_nav.dart';

/// Altura da `HomeBottomNav` (sem contar a safe area inferior). A
/// `HomePage` reserva esse espaco no fim do scroll pra que o footer nao
/// fique atras da barra.
const double kHomeBottomNavHeight = 64;

/// Barra de navegacao fixa no rodape — substitui o menu hamburger na
/// visao mobile. Mesmo vidro translucido (BackdropFilter) da `HomeNav`
/// do topo, com um item por ancora (icone + label) e destaque na secao
/// ativa derivada do scroll (scroll-spy).
///
/// So e montada em mobile (`context.isMobile`); tablet/desktop mantem a
/// navegacao no topo.
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
            border: Border(
              top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
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
    final textTheme = Theme.of(context).textTheme;
    final tint = active ? colors.primary : colors.onSurfaceMuted;

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
            // Indicador superior fino que acende na secao ativa.
            AnimatedContainer(
              duration: AppDuration.fast,
              height: 2,
              width: active ? 20 : 0,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Icon(anchor.icon ?? Icons.circle_outlined, size: 20, color: tint),
            const SizedBox(height: 2),
            Text(
              anchor.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: tint,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
