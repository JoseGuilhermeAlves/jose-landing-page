import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:feature_games/games_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Teaser do `/games` na home. Mostra preview ao vivo do raycaster
/// cyberpunk com raycast simplificado renderizado direto no card —
/// sem precisar clicar. CTA leva para a experiencia completa.
class GamesTeaserSection extends StatefulWidget {
  const GamesTeaserSection({super.key});

  @override
  State<GamesTeaserSection> createState() => _GamesTeaserSectionState();
}

class _GamesTeaserSectionState extends State<GamesTeaserSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;

    final copyBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          eyebrow: 'Experiencia interativa',
          title: 'Raycaster 3D,',
          titleAccent: 'em tempo real.',
          subtitle:
              'Engine 3D estilo Wolfenstein renderizada inteiramente via '
              'CustomPainter — DDA raycasting, iluminacao neon, '
              'minimap e controles WASD. Tudo em Dart, sem plugins.',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const Key('games-teaser-cta'),
          label: 'Jogar agora',
          icon: Icons.play_arrow,
          size: AppButtonSize.large,
          onPressed: () => context.go(GamesRoutePaths.index),
        ),
      ],
    );

    final previewBlock = _RaycasterPreview(controller: _controller);

    final inner = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copyBlock,
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(height: 260, child: previewBlock),
            ],
          )
        : Row(
            children: [
              Expanded(flex: 3, child: copyBlock),
              const SizedBox(width: AppSpacing.huge),
              Expanded(
                flex: 2,
                child: SizedBox(height: 340, child: previewBlock),
              ),
            ],
          );

    return Container(
      key: const Key('games-teaser-section'),
      padding: EdgeInsets.all(isMobile ? AppSpacing.xl : AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: inner,
    );
  }
}

/// Preview animado: raycaster simplificado que auto-rota pela cena.
/// Renderiza um minimap + vista 3D side-by-side numa unica pintura leve.
class _RaycasterPreview extends StatelessWidget {
  const _RaycasterPreview({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF050510)),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _TeaserRaycasterPainter(repaint: controller),
                willChange: true,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xCC0A0A0F),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'WASD + Mouse  —  CustomPainter 60 Hz',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF9497A9),
                  fontSize: 10,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Raycaster simplificado pro teaser — auto-rota pela cena. Usa o
/// mesmo algoritmo DDA do jogo real mas com mapa 8x8 reduzido e
/// resolucao mais baixa (step de 2px) pra manter o frame budget leve
/// mesmo rodando na home junto de todo o resto.
class _TeaserRaycasterPainter extends CustomPainter {
  _TeaserRaycasterPainter({required Listenable repaint}) : super(repaint: repaint);

  static const List<List<int>> _map = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 3, 0, 1],
    [1, 0, 2, 2, 0, 0, 0, 1],
    [1, 0, 2, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 4, 0, 1],
    [1, 0, 0, 0, 4, 4, 0, 1],
    [1, 0, 3, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
  ];

  static const _wallColors = <int, Color>{
    1: Color(0xFF7132F5),
    2: Color(0xFF5741D8),
    3: Color(0xFF00D4C0),
    4: Color(0xFFFF7043),
  };

  static const _neonColors = <int, Color>{
    1: Color(0xFFB484FF),
    2: Color(0xFF9B7AFF),
    3: Color(0xFF00FFE5),
    4: Color(0xFFFF9A76),
  };

  static const _fov = pi / 3;
  static const _fogColor = Color(0xFF0D0816);

  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = (DateTime.now().millisecondsSinceEpoch % 30000) / 30000.0;
    final angle = t * 2 * pi;

    // Auto-orbit around center of map.
    const cx = 4.0;
    const cy = 4.0;
    const radius = 2.2;
    final px = cx + cos(angle * 0.7) * radius;
    final py = cy + sin(angle * 0.7) * radius;
    final lookAngle = atan2(cy - py, cx - px) + sin(angle * 1.3) * 0.4;

    final w = size.width.toInt();
    final h = size.height;
    final halfH = h / 2;

    // Gradient ceiling.
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF050510), Color(0xFF1A0A2E)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, halfH));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, halfH), _paint);

    // Gradient floor.
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A1218), Color(0xFF050508)],
    ).createShader(Rect.fromLTWH(0, halfH, size.width, halfH));
    canvas.drawRect(Rect.fromLTWH(0, halfH, size.width, halfH), _paint);
    _paint.shader = null;

    // Floor grid.
    _paint.color = const Color(0xFF7132F5).withValues(alpha: 0.05);
    for (var row = 0; row < 12; row++) {
      final gy = halfH + (halfH * (row / 12.0) * (row / 12.0));
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), _paint);
    }

    // Raycast at lower resolution (step 2) for perf.
    final tanHalfFov = tan(_fov / 2);
    for (var x = 0; x < w; x += 2) {
      final cameraX = 2.0 * x / w - 1;
      final rayAngle = lookAngle + atan(cameraX * tanHalfFov);
      final rayDirX = cos(rayAngle);
      final rayDirY = sin(rayAngle);

      var mapX = px.floor();
      var mapY = py.floor();

      final ddx = rayDirX == 0 ? 1e30 : (1.0 / rayDirX).abs();
      final ddy = rayDirY == 0 ? 1e30 : (1.0 / rayDirY).abs();

      int stepX;
      int stepY;
      double sdx;
      double sdy;

      if (rayDirX < 0) {
        stepX = -1;
        sdx = (px - mapX) * ddx;
      } else {
        stepX = 1;
        sdx = (mapX + 1.0 - px) * ddx;
      }
      if (rayDirY < 0) {
        stepY = -1;
        sdy = (py - mapY) * ddy;
      } else {
        stepY = 1;
        sdy = (mapY + 1.0 - py) * ddy;
      }

      var hit = 0;
      var side = 0;
      var steps = 0;

      while (hit == 0 && steps < 20) {
        if (sdx < sdy) {
          sdx += ddx;
          mapX += stepX;
          side = 0;
        } else {
          sdy += ddy;
          mapY += stepY;
          side = 1;
        }
        steps++;
        if (mapY >= 0 && mapY < _map.length && mapX >= 0 && mapX < _map[0].length) {
          hit = _map[mapY][mapX];
        } else {
          hit = 1;
        }
      }

      final perpDist = side == 0
          ? (mapX - px + (1 - stepX) / 2) / rayDirX
          : (mapY - py + (1 - stepY) / 2) / rayDirY;

      final wallH = (h / perpDist.clamp(0.01, 50)).clamp(0.0, h * 2);
      final wallTop = halfH - wallH / 2;
      final wallBottom = wallTop + wallH;

      final fogFactor = (perpDist / 8.0).clamp(0.0, 0.85);
      final shade = (1.0 / (1.0 + perpDist * 0.18)).clamp(0.1, 1.0);
      final sideMul = side == 1 ? 0.65 : 1.0;

      final baseColor = _wallColors[hit] ?? const Color(0xFF7132F5);
      final fogR = (_fogColor.r * 255).round();
      final fogG = (_fogColor.g * 255).round();
      final fogB = (_fogColor.b * 255).round();
      final r = _lerp((baseColor.r * shade * sideMul).round(), fogR, fogFactor);
      final g = _lerp((baseColor.g * shade * sideMul).round(), fogG, fogFactor);
      final b = _lerp((baseColor.b * shade * sideMul).round(), fogB, fogFactor);

      _paint
        ..color = Color.fromARGB(255, r, g, b)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(x.toDouble(), wallTop),
        Offset(x.toDouble(), wallBottom),
        _paint,
      );

      // Neon trim.
      final neon = _neonColors[hit] ?? const Color(0xFFB484FF);
      final neonAlpha = ((1.0 - fogFactor) * 0.8).clamp(0.0, 1.0);
      if (neonAlpha > 0.05) {
        _paint.color = neon.withValues(alpha: neonAlpha);
        canvas.drawLine(
          Offset(x.toDouble(), wallTop),
          Offset(x.toDouble(), wallTop + 2),
          _paint,
        );
        canvas.drawLine(
          Offset(x.toDouble(), wallBottom - 2),
          Offset(x.toDouble(), wallBottom),
          _paint,
        );
      }
    }

    // Scanlines.
    _paint
      ..color = const Color(0x06000000)
      ..strokeWidth = 1;
    for (var y = 0.0; y < h; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }
  }

  int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

  @override
  bool shouldRepaint(_TeaserRaycasterPainter old) => true;
}
