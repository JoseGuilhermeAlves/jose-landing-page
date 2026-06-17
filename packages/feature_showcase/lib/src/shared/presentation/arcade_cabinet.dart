import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Frame de fliperama que emoldura o preview de um mock. Em vez de uma
/// animacao decorativa, a "tela" do gabinete renderiza a **home real** do
/// mock (escalada e nao-interativa) — da vontade de "inserir a ficha" e
/// abrir o demo. Estrutura: marquee neon no topo (label da marca), tela
/// com bezel preto, e deck de controle (joystick + botoes) pintado embaixo.
///
/// O preview e o proprio widget de demo do mock, renderizado num tamanho
/// de telefone fixo e encaixado via [FittedBox] + [IgnorePointer]; tap no
/// gabinete inteiro abre o demo fullscreen (responsabilidade do host).
class ArcadeCabinet extends StatefulWidget {
  const ArcadeCabinet({
    required this.label,
    required this.preview,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  /// Nome da marca/mock exibido no marquee (ex.: AURORA, SOLAR).
  final String label;

  /// Home real do mock — renderizada na tela do gabinete.
  final Widget preview;

  final VoidCallback onTap;

  /// Quando false, gabinete fica "OUT OF ORDER" (template sem demo).
  final bool enabled;

  @override
  State<ArcadeCabinet> createState() => _ArcadeCabinetState();
}

class _ArcadeCabinetState extends State<ArcadeCabinet> {
  bool _hovered = false;

  /// Tamanho logico usado pra renderizar a home antes de encaixar na tela
  /// do gabinete. Largura na faixa em que os mocks sao validados (~800) pra
  /// evitar overflow de layouts que nao foram pensados pra larguras muito
  /// estreitas; o FittedBox escala tudo pra moldura.
  static const Size _phone = Size(820, 1500);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lit = _hovered && widget.enabled;

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: lit
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: lit
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.5),
                        blurRadius: 24,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Marquee(label: widget.label, lit: lit),
                const SizedBox(height: AppSpacing.sm),
                _Screen(
                  enabled: widget.enabled,
                  hovered: lit,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _phone.width,
                      height: _phone.height,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(size: _phone),
                        child: IgnorePointer(child: widget.preview),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ControlDeck(lit: lit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Marquee superior: banda escura com o nome em fonte pixel + glow neon.
class _Marquee extends StatelessWidget {
  const _Marquee({required this.label, required this.lit});

  final String label;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      color: colors.background,
      alignment: Alignment.center,
      child: PixelText(
        label,
        color: lit ? colors.accent : colors.primary,
        glowColor: lit ? colors.accent : colors.primary,
        pixelSize: 3,
      ),
    );
  }
}

/// Tela do gabinete: bezel preto + a home do mock dentro. No hover surge
/// um "▶ PLAY" sobreposto; desabilitado mostra "OUT OF ORDER".
class _Screen extends StatelessWidget {
  const _Screen({
    required this.child,
    required this.enabled,
    required this.hovered,
  });

  final Widget child;
  final bool enabled;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        padding: const EdgeInsets.all(6),
        color: Colors.black,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (enabled)
                RepaintBoundary(child: child)
              else
                ColoredBox(
                  color: colors.surfaceMuted,
                  child: Center(
                    child: PixelText(
                      'OUT OF\nORDER',
                      color: colors.onSurfaceMuted,
                      align: TextAlign.center,
                    ),
                  ),
                ),
              // Vinheta leve nas bordas da tela (efeito de tubo).
              const IgnorePointer(child: _ScreenVignette()),
              if (enabled && hovered)
                Container(
                  alignment: Alignment.center,
                  color: Colors.black.withValues(alpha: 0.45),
                  child: PixelText(
                    '~ PLAY',
                    color: colors.accent,
                    glowColor: colors.accent,
                    pixelSize: 5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenVignette extends StatelessWidget {
  const _ScreenVignette();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.9,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
          stops: const [0.7, 1.0],
        ),
      ),
    );
  }
}

/// Deck de controle pintado: joystick + dois botoes redondos.
class _ControlDeck extends StatelessWidget {
  const _ControlDeck({required this.lit});

  final bool lit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 34,
      width: double.infinity,
      child: CustomPaint(
        painter: _ControlDeckPainter(
          stick: colors.onSurfaceMuted,
          buttonA: colors.primary,
          buttonB: colors.accent,
          lit: lit,
        ),
      ),
    );
  }
}

class _ControlDeckPainter extends CustomPainter {
  _ControlDeckPainter({
    required this.stick,
    required this.buttonA,
    required this.buttonB,
    required this.lit,
  });

  final Color stick;
  final Color buttonA;
  final Color buttonB;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = stick;
    final fill = Paint()..color = stick;

    // Joystick a esquerda: base + haste + bola.
    final baseX = size.width * 0.28;
    canvas
      ..drawLine(Offset(baseX, cy + 8), Offset(baseX, cy - 6), stroke)
      ..drawCircle(Offset(baseX, cy - 8), 5, fill)
      ..drawOval(
        Rect.fromCenter(center: Offset(baseX, cy + 10), width: 22, height: 7),
        fill,
      );

    // Dois botoes redondos a direita (acendem no hover).
    final aPaint = Paint()..color = buttonA.withValues(alpha: lit ? 1 : 0.7);
    final bPaint = Paint()..color = buttonB.withValues(alpha: lit ? 1 : 0.7);
    canvas
      ..drawCircle(Offset(size.width * 0.62, cy), 7, aPaint)
      ..drawCircle(Offset(size.width * 0.74, cy - 2), 7, bPaint);
  }

  @override
  bool shouldRepaint(_ControlDeckPainter oldDelegate) =>
      oldDelegate.lit != lit ||
      oldDelegate.stick != stick ||
      oldDelegate.buttonA != buttonA ||
      oldDelegate.buttonB != buttonB;
}
