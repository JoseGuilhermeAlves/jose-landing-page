import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Fundo animado da landing Arcade: campo de estrelas em parallax + grid
/// Outrun em perspectiva varrendo na direcao do observador. Desenha por
/// baixo de todo o conteudo (a moldura CRT entra por cima via overlay).
///
/// O painter recebe o controller direto em `super(repaint:)` — o
/// RenderCustomPaint ouve o tick e pula build/layout (regra de painter do
/// CLAUDE.md). Geometria das estrelas e cacheada (gerada uma vez com seed
/// fixa); so as posicoes derivam do tempo em paint().
class ArcadeBackdrop extends StatefulWidget {
  const ArcadeBackdrop({
    required this.background,
    required this.gridNear,
    required this.gridFar,
    required this.starColor,
    super.key,
  });

  /// Fundo do tubo CRT (quase-preto roxo).
  final Color background;

  /// Cor das linhas do grid perto do observador (magenta neon).
  final Color gridNear;

  /// Cor das linhas no horizonte (ciano neon).
  final Color gridFar;

  /// Cor base das estrelas (branco-lavanda).
  final Color starColor;

  @override
  State<ArcadeBackdrop> createState() => _ArcadeBackdropState();
}

class _ArcadeBackdropState extends State<ArcadeBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Loop longo e continuo — a fase do grid e das estrelas deriva do
    // valor 0..1 multiplicado por velocidades diferentes.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Acessibilidade: sem animacao o backdrop fica estatico.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Anima sozinho atras de uma arvore que rola — RepaintBoundary isola
    // o repaint de 60 Hz do scroll.
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: true,
        painter: ArcadeBackdropPainter(
          animation: _controller,
          background: widget.background,
          gridNear: widget.gridNear,
          gridFar: widget.gridFar,
          starColor: widget.starColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}
