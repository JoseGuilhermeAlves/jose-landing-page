import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/arcade/calm_backdrop.dart';
import 'package:landing/widgets/arcade/cosmic_layer.dart';

/// Moldura global da landing. Empilha, de tras pra frente:
/// 1. [CalmBackdrop] — fundo solido, luzes neon difusas e estrelas estaticas;
/// 2. [CosmicLayer] — nebulosas, galaxia distante e planetas nas bordas;
/// 3. o conteudo da rota (paginas com Scaffold transparente).
///
/// Redesign 2026-11: o grid Outrun animado, o boss/portal (arquivados em
/// `archive/final_boss/`) e o overlay CRT sairam do fundo global — competiam
/// com o texto. O grid virou o chao do hero; o CRT ficou so na pagina
/// gamificada do Poço, onde a estetica de fliperama e o proprio assunto.
class ArcadeShell extends StatelessWidget {
  const ArcadeShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Positioned.fill(
          child: CalmBackdrop(
            background: colors.background,
            glowA: colors.primary,
            glowB: colors.accent,
            starColor: colors.onSurface,
          ),
        ),
        const Positioned.fill(child: CosmicLayer()),
        Positioned.fill(child: child),
      ],
    );
  }
}
