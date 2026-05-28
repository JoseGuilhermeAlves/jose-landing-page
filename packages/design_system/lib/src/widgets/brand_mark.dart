import 'package:design_system/src/spacing/app_spacing.dart';
import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_gradients.dart';
import 'package:design_system/src/tokens/app_radius.dart';
import 'package:design_system/src/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

/// Marca monograma "JG" — substitui foto de perfil em nav/bio.
/// Quadrado arredondado (nao circulo) pra reforcar leitura de logo,
/// nao avatar. Opcionalmente acompanha wordmark "ZeguiDev" com
/// destaque em gradient no sufixo "Dev".
class BrandMark extends StatelessWidget {
  const BrandMark({
    this.size = 36,
    this.showWordmark = false,
    this.borderRadius,
    super.key,
  });

  final double size;
  final bool showWordmark;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    // Tamanhos pequenos pedem raio menor pra manter "peso" de logo;
    // tamanhos grandes ganham raio mais generoso.
    final radius =
        borderRadius ??
        BorderRadius.circular(size <= 48 ? AppRadius.md : AppRadius.lg);

    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.brand(colors),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.4),
            blurRadius: size * 0.4,
            spreadRadius: -4,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _JgMonogramPainter(
          color: colors.onPrimary,
          strokeWidth: size * 0.085,
        ),
      ),
    );

    if (!showWordmark) return mark;

    final baseStyle = textTheme.titleSmall?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: AppSpacing.md),
        // Sufixo "Dev" recebe gradient da marca; "Zegui" fica neutro
        // pra nao competir com o monograma.
        Text('Zegui', style: baseStyle),
        GradientText(
          text: 'Dev',
          gradient: AppGradients.brand(colors),
          style: baseStyle,
        ),
      ],
    );
  }
}

/// Desenha "JG" entrelacado: a haste vertical do J coincide com a
/// lateral esquerda do G, fazendo as duas letras lerem como marca
/// unica em vez de dois glyphs justapostos.
class _JgMonogramPainter extends CustomPainter {
  _JgMonogramPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  late final Paint _stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    // Padding interno proporcional — mantem respiro nas bordas em
    // qualquer escala.
    final pad = s * 0.22;
    final left = pad;
    final right = size.width - pad;
    final top = pad;
    final bottom = size.height - pad;
    final height = bottom - top;
    final width = right - left;

    // Eixo compartilhado: vertical onde J encontra G.
    final sharedX = left + width * 0.42;

    // ---- J ----
    // Barra horizontal superior curta (serifa minimalista do J).
    final jTopY = top;
    final jTopLeft = Offset(sharedX - width * 0.18, jTopY);
    final jTopRight = Offset(sharedX + width * 0.04, jTopY);
    // Haste vertical do J, descendo ate proximo da base.
    final jHookStartY = bottom - height * 0.22;

    // Curva inferior do J (gancho voltado pra esquerda).
    final jHook = Path()
      ..moveTo(sharedX, jHookStartY)
      ..quadraticBezierTo(
        sharedX,
        bottom,
        sharedX - width * 0.18,
        bottom,
      )
      ..lineTo(sharedX - width * 0.22, bottom - height * 0.02);

    // ---- G ----
    // G ocupa metade direita; sua lateral esquerda toca a haste do J
    // no eixo sharedX, criando o entrelacamento.
    final gLeft = sharedX;
    final gRight = right;
    final gTop = top + height * 0.08;
    final gBottom = bottom;
    final gRect = Rect.fromLTRB(gLeft, gTop, gRight, gBottom);

    // Arco superior do G — abre na direita pra dar espaco ao crossbar.
    final gPath = Path()
      ..addArc(
        gRect,
        -1.4, // ~-80deg, comeca proximo do topo direito
        -3.6, // varre quase 360 no sentido anti-horario ate o meio direito
      );
    // Crossbar interno do G — traco horizontal curto entrando pela
    // direita, marca registrada da letra.
    final crossY = gTop + (gBottom - gTop) * 0.62;
    final crossStart = Offset(gLeft + width * 0.32, crossY);
    final crossEnd = Offset(gRight, crossY);

    canvas
      ..drawLine(jTopLeft, jTopRight, _stroke)
      ..drawLine(Offset(sharedX, jTopY), Offset(sharedX, jHookStartY), _stroke)
      ..drawPath(jHook, _stroke)
      ..drawPath(gPath, _stroke)
      ..drawLine(crossStart, crossEnd, _stroke)
      // Pequeno acento conectando crossbar ao eixo compartilhado —
      // reforca a leitura "JG" como ligadura.
      ..drawCircle(
        Offset(crossStart.dx - strokeWidth * 0.2, crossY),
        strokeWidth * 0.45,
        _fill,
      );
  }

  @override
  bool shouldRepaint(covariant _JgMonogramPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
