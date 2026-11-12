import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Gabinete de fliperama que emoldura o preview de um mock. A "tela"
/// renderiza a **home real** do mock (escalada, nao interativa); tap em
/// qualquer parte do gabinete abre o demo completo (responsabilidade do host).
///
/// Redesign 2026-11 — silhueta de gabinete de verdade, toda em Canvas
/// ([_CabinetBodyPainter]): laterais com recorte (capuz sobre a tela, painel
/// de controle projetado), friso neon (T-molding) contornando o perfil na cor
/// da marca, marquee retroiluminado, deck com joystick e botoes, porta de
/// fichas com dois slots acesos. Abaixo do gabinete, uma legenda legivel
/// (nicho + descricao + acao) — o gabinete atrai, a legenda explica.
class ArcadeCabinet extends StatefulWidget {
  const ArcadeCabinet({
    required this.label,
    required this.preview,
    required this.onTap,
    this.niche,
    this.description,
    this.actionLabel,
    this.neon,
    this.enabled = true,
    super.key,
  });

  /// Nome da marca exibido no marquee (ex.: AURORA, SOLAR).
  final String label;

  /// Home real do mock — renderizada na tela do gabinete.
  final Widget preview;

  final VoidCallback onTap;

  /// Nicho (ex.: "Delivery") — legenda abaixo do gabinete.
  final String? niche;

  /// Descricao curta do mock — legenda abaixo do gabinete.
  final String? description;

  /// Rotulo da acao (ex.: "Abrir demo").
  final String? actionLabel;

  /// Cor do friso neon/marquee. Default: `colors.primary`.
  final Color? neon;

  /// Quando false, gabinete fica "OUT OF ORDER" (template sem demo).
  final bool enabled;

  @override
  State<ArcadeCabinet> createState() => _ArcadeCabinetState();
}

class _ArcadeCabinetState extends State<ArcadeCabinet> {
  bool _hovered = false;

  /// Tamanho logico usado pra renderizar a home antes de encaixar na tela.
  static const Size _phone = Size(820, 1500);

  /// Recuo lateral da tela em relacao ao corpo (espessura das laterais).
  static const double _side = 18;
  static const double _marqueeH = 54;
  static const double _deckH = 58;
  static const double _doorH = 50;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final neon = widget.neon ?? colors.primary;
    final lit = _hovered && widget.enabled;

    final cabinet = AnimatedSlide(
      duration: AppDuration.fast,
      curve: Curves.easeOut,
      offset: Offset(0, lit ? -0.012 : 0),
      child: CustomPaint(
        painter: _CabinetBodyPainter(
          body: colors.surface,
          bodyShade: colors.surfaceMuted,
          neon: neon,
          lit: lit,
          marqueeH: _marqueeH,
          deckH: _deckH,
          doorH: _doorH,
          side: _side,
          stick: colors.onSurfaceMuted,
          buttonA: colors.primary,
          buttonB: colors.accent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _marqueeH,
              child: Center(
                child: PixelText(
                  widget.label,
                  color: lit ? Colors.white : neon,
                  glowColor: neon,
                  glowBlur: lit ? 14 : 8,
                  pixelSize: 3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _side + 6),
              child: _Screen(
                enabled: widget.enabled,
                hovered: lit,
                neon: neon,
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
            ),
            const SizedBox(height: _deckH + _doorH),
          ],
        ),
      ),
    );

    final caption = (widget.niche == null && widget.description == null)
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.niche != null)
                  Text(
                    widget.niche!.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: neon,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                if (widget.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.description!,
                    style: tt.bodySmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.5,
                    ),
                  ),
                ],
                if (widget.actionLabel != null && widget.enabled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.actionLabel!,
                        style: tt.labelMedium?.copyWith(
                          color: lit ? colors.onSurface : colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AnimatedSlide(
                        duration: AppDuration.fast,
                        offset: Offset(lit ? 0.25 : 0, 0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: lit ? colors.onSurface : colors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );

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
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? widget.onTap : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [cabinet, ?caption],
          ),
        ),
      ),
    );
  }
}

/// Tela do gabinete: bezel preto + home do mock + reflexo de vidro. No hover
/// surge "PLAY"; desabilitado mostra "OUT OF ORDER".
class _Screen extends StatelessWidget {
  const _Screen({
    required this.child,
    required this.enabled,
    required this.hovered,
    required this.neon,
  });

  final Widget child;
  final bool enabled;
  final bool hovered;
  final Color neon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(width: 7),
          boxShadow: [
            BoxShadow(
              color: neon.withValues(alpha: hovered ? 0.35 : 0.12),
              blurRadius: hovered ? 28 : 16,
            ),
          ],
        ),
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
              const IgnorePointer(child: _Glass()),
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: AppDuration.fast,
                  opacity: enabled && hovered ? 1 : 0,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: PixelText(
                        'PLAY',
                        color: Colors.white,
                        glowColor: neon,
                        glowBlur: 12,
                        pixelSize: 5,
                      ),
                    ),
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

/// Vidro do monitor: vinheta nas bordas + reflexo diagonal sutil.
class _Glass extends StatelessWidget {
  const _Glass();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.95,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
              stops: const [0.68, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0, 0.35, 1],
            ),
          ),
        ),
      ],
    );
  }
}

/// Corpo do gabinete inteiro em Canvas. Perfil (de cima pra baixo):
/// marquee (levemente mais largo) -> capuz -> tela -> painel de controle
/// projetado (mais largo, com chanfro) -> porta de fichas -> rodape.
class _CabinetBodyPainter extends CustomPainter {
  _CabinetBodyPainter({
    required this.body,
    required this.bodyShade,
    required this.neon,
    required this.lit,
    required this.marqueeH,
    required this.deckH,
    required this.doorH,
    required this.side,
    required this.stick,
    required this.buttonA,
    required this.buttonB,
  });

  final Color body;
  final Color bodyShade;
  final Color neon;
  final bool lit;
  final double marqueeH;
  final double deckH;
  final double doorH;
  final double side;
  final Color stick;
  final Color buttonA;
  final Color buttonB;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final deckTop = h - deckH - doorH;
    final doorTop = h - doorH;
    const inset = 8.0; // laterais recuadas na altura da tela

    // Silhueta: marquee e deck usam a largura total; a faixa da tela e
    // recuada (as laterais "abracam" o monitor).
    final outline = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, marqueeH)
      ..lineTo(w - inset, marqueeH + 14)
      ..lineTo(w - inset, deckTop - 6)
      ..lineTo(w, deckTop + 10)
      ..lineTo(w, deckTop + deckH)
      ..lineTo(w - inset, doorTop + 4)
      ..lineTo(w - inset, h)
      ..lineTo(inset, h)
      ..lineTo(inset, doorTop + 4)
      ..lineTo(0, deckTop + deckH)
      ..lineTo(0, deckTop + 10)
      ..lineTo(inset, deckTop - 6)
      ..lineTo(inset, marqueeH + 14)
      ..lineTo(0, marqueeH)
      ..close();

    // Corpo com leve degrade vertical.
    canvas.drawPath(
      outline,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [body, bodyShade],
        ).createShader(Offset.zero & size),
    );

    // Marquee retroiluminado.
    final marquee = Rect.fromLTWH(6, 6, w - 12, marqueeH - 12);
    canvas
      ..drawRect(marquee, Paint()..color = Colors.black)
      ..drawRect(
        marquee,
        Paint()
          ..shader = RadialGradient(
            radius: 1.2,
            colors: [
              neon.withValues(alpha: lit ? 0.38 : 0.22),
              neon.withValues(alpha: 0),
            ],
          ).createShader(marquee),
      );

    // Deck de controle: tampo inclinado (faixa mais clara) + joystick e botoes.
    final deck = Rect.fromLTWH(4, deckTop + 12, w - 8, deckH - 18);
    canvas.drawRect(
      deck,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    final cy = deck.center.dy;
    final stickPaint = Paint()
      ..color = stick
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final sx = w * 0.27;
    canvas
      ..drawOval(
        Rect.fromCenter(center: Offset(sx, cy + 8), width: 26, height: 8),
        Paint()..color = Colors.black,
      )
      ..drawLine(Offset(sx, cy + 7), Offset(sx, cy - 5), stickPaint)
      ..drawCircle(Offset(sx, cy - 8), 6, Paint()..color = buttonA);
    for (var i = 0; i < 3; i++) {
      final c = i == 1 ? buttonB : buttonA;
      final center = Offset(w * 0.56 + i * 22, cy - (i == 1 ? 3 : 0));
      if (lit) {
        canvas.drawCircle(
          center,
          10,
          Paint()
            ..color = c.withValues(alpha: 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      canvas.drawCircle(
        center,
        6.5,
        Paint()..color = c.withValues(alpha: lit ? 1 : 0.75),
      );
    }

    // Porta de fichas: dois slots acesos + grade.
    for (final fx in [0.38, 0.62]) {
      final slot = Rect.fromCenter(
        center: Offset(w * fx, doorTop + doorH * 0.45),
        width: 16,
        height: 20,
      );
      canvas
        ..drawRect(slot, Paint()..color = Colors.black)
        ..drawRect(
          Rect.fromCenter(center: slot.center, width: 3, height: 10),
          Paint()
            ..color = (lit ? const Color(0xFFFFD34D) : const Color(0xFFB8862B)),
        );
    }

    // Friso neon (T-molding) contornando o perfil: glow + nucleo.
    canvas
      ..drawPath(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lit ? 6 : 4
          ..color = neon.withValues(alpha: lit ? 0.45 : 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawPath(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = neon.withValues(alpha: lit ? 1 : 0.6),
      );
  }

  @override
  bool shouldRepaint(_CabinetBodyPainter old) =>
      old.lit != lit ||
      old.neon != neon ||
      old.body != body ||
      old.bodyShade != bodyShade;
}
