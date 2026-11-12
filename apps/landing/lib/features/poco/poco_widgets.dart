import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/trailer/trailer_video_view.dart'
    if (dart.library.js_interop) 'package:landing/widgets/trailer/trailer_video_view_web.dart';

/// Pecas visuais compartilhadas pela landing do Poço (pagina gamificada) e
/// pelo teaser da home: logo, moldura neon, painel HUD, cabecalho de "stage",
/// player do trailer.

/// Logo "POÇO" em pixel-art desenhado no Canvas a partir da `PixelFont`
/// (5x7) — com a cedilha pintada a mao embaixo do C, que a fonte bitmap
/// nao comporta. Glow neon em duas passadas + nucleo solido.
class PocoLogo extends StatelessWidget {
  const PocoLogo({required this.pixelSize, this.color, this.glow, super.key});

  final double pixelSize;
  final Color? color;
  final Color? glow;

  static const String _word = 'POCO';

  /// Avanco de cada letra em pixels-fonte (5 de glifo + 1 de espaco).
  static const int _advance = PixelFont.glyphWidth + 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final w = (_word.length * _advance - 1) * pixelSize;
    // 7 linhas do glifo + 3 da cedilha.
    final h = (PixelFont.glyphHeight + 3) * pixelSize;
    return Semantics(
      label: 'Poço',
      header: true,
      child: CustomPaint(
        size: Size(w, h),
        painter: _PocoLogoPainter(
          pixelSize: pixelSize,
          color: color ?? colors.primary,
          glow: glow ?? colors.primary,
        ),
      ),
    );
  }
}

class _PocoLogoPainter extends CustomPainter {
  _PocoLogoPainter({
    required this.pixelSize,
    required this.color,
    required this.glow,
  });

  final double pixelSize;
  final Color color;
  final Color glow;

  Path _path() {
    final path = Path();
    void px(int col, int row) => path.addRect(
      Rect.fromLTWH(col * pixelSize, row * pixelSize, pixelSize, pixelSize),
    );

    for (var i = 0; i < PocoLogo._word.length; i++) {
      final rows = PixelFont.rowsFor(PocoLogo._word[i]);
      for (var r = 0; r < rows.length; r++) {
        for (var c = 0; c < PixelFont.glyphWidth; c++) {
          if (rows[r] & (1 << (PixelFont.glyphWidth - 1 - c)) != 0) {
            px(i * PocoLogo._advance + c, r);
          }
        }
      }
    }
    // Cedilha sob o C (3a letra): gancho curto de 3 pixels.
    const cx = 2 * PocoLogo._advance;
    px(cx + 2, 7);
    px(cx + 2, 8);
    px(cx + 1, 9);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path();
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = glow.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, pixelSize * 2.2),
      )
      ..drawPath(
        path,
        Paint()
          ..color = glow.withValues(alpha: 0.8)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, pixelSize * 0.6),
      )
      ..drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PocoLogoPainter old) =>
      old.pixelSize != pixelSize || old.color != color || old.glow != glow;
}

/// Moldura 16:9 neon de cantos retos — GIF, trailer, capturas.
class NeonFrame extends StatelessWidget {
  const NeonFrame({
    required this.child,
    this.color,
    this.aspectRatio = 16 / 9,
    super.key,
  });

  final Widget child;
  final Color? color;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: c.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: -6,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRect(child: child),
      ),
    );
  }
}

/// Painel HUD: fundo escuro translucido, borda fina e cantoneiras neon
/// nos quatro cantos (assinatura de interface de jogo).
class HudPanel extends StatelessWidget {
  const HudPanel({
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.lit = false,
    super.key,
  });

  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = color ?? colors.accent;
    return AnimatedContainer(
      duration: AppDuration.fast,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: lit ? 0.92 : 0.72),
        border: Border.all(
          color: lit ? c.withValues(alpha: 0.7) : colors.border,
        ),
        boxShadow: lit
            ? [BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 24)]
            : null,
      ),
      child: CustomPaint(
        foregroundPainter: _CornerBracketsPainter(color: c),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  _CornerBracketsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const l = 12.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, l)
          ..lineTo(0, 0)
          ..lineTo(l, 0),
        p,
      )
      ..drawPath(
        Path()
          ..moveTo(w - l, 0)
          ..lineTo(w, 0)
          ..lineTo(w, l),
        p,
      )
      ..drawPath(
        Path()
          ..moveTo(w, h - l)
          ..lineTo(w, h)
          ..lineTo(w - l, h),
        p,
      )
      ..drawPath(
        Path()
          ..moveTo(l, h)
          ..lineTo(0, h)
          ..lineTo(0, h - l),
        p,
      );
  }

  @override
  bool shouldRepaint(_CornerBracketsPainter old) => old.color != color;
}

/// Cabecalho de secao da pagina gamificada: `STAGE 0X` em pixel + rotulo,
/// titulo em sans com brilho neon (a fonte pixel 5x7 nao tem acentos, e
/// "POCO"/"VOCE" sem diacritico le como descuido) e corpo opcional.
class StageHeading extends StatelessWidget {
  const StageHeading({
    required this.stage,
    required this.eyebrow,
    required this.title,
    this.body,
    super.key,
  });

  final int stage;
  final String eyebrow;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelText(
              'STAGE ${stage.toString().padLeft(2, '0')}',
              color: colors.primary,
              pixelSize: 2,
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(width: 20, height: 1.5, color: colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                eyebrow.toUpperCase(),
                style: tt.labelMedium?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            title,
            style: (isMobile ? tt.headlineLarge : tt.displaySmall)?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: colors.accent.withValues(alpha: 0.45),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              body!,
              style: tt.bodyLarge?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Trailer: poster com botao de play; o `<video>` nativo so e montado no
/// clique (autoplay com som, ja que veio de gesto do usuario).
class PocoTrailerPlayer extends StatefulWidget {
  const PocoTrailerPlayer({
    required this.videoUrl,
    required this.posterAsset,
    super.key,
  });

  final String videoUrl;
  final String posterAsset;

  @override
  State<PocoTrailerPlayer> createState() => _PocoTrailerPlayerState();
}

class _PocoTrailerPlayerState extends State<PocoTrailerPlayer> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final video = Uri.base.resolve(widget.videoUrl).toString();
    // Flutter web publica assets sob `assets/<caminho do asset>`.
    final poster = Uri.base.resolve('assets/${widget.posterAsset}').toString();

    return NeonFrame(
      child: _playing
          ? TrailerVideoView(src: video, poster: poster)
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.posterAsset,
                  fit: BoxFit.cover,
                  semanticLabel: l10n.game_trailerAlt,
                ),
                ColoredBox(color: colors.background.withValues(alpha: 0.35)),
                Center(
                  child: NeonButton(
                    label: l10n.game_trailerPlay,
                    filled: true,
                    pixel: true,
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => setState(() => _playing = true),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Texto piscante estilo "PRESS START" (respeita animacoes reduzidas).
class BlinkingPixelText extends StatefulWidget {
  const BlinkingPixelText(
    this.text, {
    required this.color,
    this.pixelSize = 3,
    super.key,
  });

  final String text;
  final Color color;
  final double pixelSize;

  @override
  State<BlinkingPixelText> createState() => _BlinkingPixelTextState();
}

class _BlinkingPixelTextState extends State<BlinkingPixelText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c
        ..stop()
        ..value = 1;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic),
      child: PixelText(
        widget.text,
        color: widget.color,
        glowColor: widget.color,
        pixelSize: widget.pixelSize,
      ),
    );
  }
}
