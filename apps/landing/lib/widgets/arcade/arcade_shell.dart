import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/arcade/arcade_backdrop.dart';
import 'package:landing/widgets/arcade/crt_overlay.dart';

/// Moldura global da landing Arcade. Empilha, de tras pra frente:
/// 1. [ArcadeBackdrop] — starfield + grid Outrun animado;
/// 2. o conteudo da rota (paginas com Scaffold transparente);
/// 3. [CrtOverlay] — scanlines, vinheta e flicker do tubo.
///
/// Montado no `builder` do MaterialApp.router, entao envolve todas as
/// rotas com a mesma identidade CRT. A abertura "terminal verde" e o
/// loading unico em HTML/CSS no `web/index.html` (some no primeiro frame);
/// nao ha boot screen em Flutter — evita o loading duplicado.
class ArcadeShell extends StatelessWidget {
  const ArcadeShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Positioned.fill(
          child: ArcadeBackdrop(
            background: colors.background,
            gridNear: colors.primary,
            gridFar: colors.accent,
            starColor: colors.onSurface,
          ),
        ),
        Positioned.fill(child: child),
        Positioned.fill(child: CrtOverlay(tint: colors.onSurface)),
      ],
    );
  }
}
