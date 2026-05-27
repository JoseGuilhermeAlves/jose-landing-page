import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:feature_games/src/router/games_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Cyberpunk raycaster — Wolfenstein-style 3D rendered entirely via
/// CustomPainter with neon-lit walls, floor grid casting, scanlines
/// and HUD overlay. WASD/arrows to move, mouse/touch to look.
class RaycasterPlayground extends StatefulWidget {
  const RaycasterPlayground({super.key});

  @override
  State<RaycasterPlayground> createState() => _RaycasterPlaygroundState();
}

class _RaycasterPlaygroundState extends State<RaycasterPlayground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final _focusNode = FocusNode();
  final _keys = <LogicalKeyboardKey>{};

  double _px = 2.5;
  double _py = 2.5;
  double _angle = 0;
  double _time = 0;

  double _lastPointerX = 0;
  bool _pointerDown = false;

  static const double _moveSpeed = 2.4;
  static const double _rotSpeed = 1.8;
  static const double _mouseSensitivity = 0.003;
  static const double _playerRadius = 0.2;
  static const double _fov = pi / 3;

  static const List<List<int>> _map = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 2, 2, 0, 1, 0, 0, 3, 3, 3, 0, 0, 0, 1],
    [1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 1],
    [1, 1, 1, 0, 0, 0, 2, 0, 0, 0, 4, 4, 0, 4, 0, 1],
    [1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 1],
    [1, 0, 3, 3, 0, 0, 0, 0, 0, 3, 0, 0, 2, 2, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
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

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_gameLoop);
    _ticker.forward();
  }

  @override
  void dispose() {
    _ticker
      ..removeListener(_gameLoop)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DateTime _lastFrame = DateTime.now();

  void _gameLoop() {
    final now = DateTime.now();
    final dt =
        (now.difference(_lastFrame).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastFrame = now;

    var dx = 0.0;
    var dy = 0.0;
    var rot = 0.0;

    if (_keys.contains(LogicalKeyboardKey.keyW) ||
        _keys.contains(LogicalKeyboardKey.arrowUp)) {
      dx += cos(_angle) * _moveSpeed * dt;
      dy += sin(_angle) * _moveSpeed * dt;
    }
    if (_keys.contains(LogicalKeyboardKey.keyS) ||
        _keys.contains(LogicalKeyboardKey.arrowDown)) {
      dx -= cos(_angle) * _moveSpeed * dt;
      dy -= sin(_angle) * _moveSpeed * dt;
    }
    if (_keys.contains(LogicalKeyboardKey.keyA)) {
      dx += cos(_angle - pi / 2) * _moveSpeed * dt;
      dy += sin(_angle - pi / 2) * _moveSpeed * dt;
    }
    if (_keys.contains(LogicalKeyboardKey.keyD)) {
      dx += cos(_angle + pi / 2) * _moveSpeed * dt;
      dy += sin(_angle + pi / 2) * _moveSpeed * dt;
    }
    if (_keys.contains(LogicalKeyboardKey.arrowLeft)) {
      rot -= _rotSpeed * dt;
    }
    if (_keys.contains(LogicalKeyboardKey.arrowRight)) {
      rot += _rotSpeed * dt;
    }

    setState(() {
      _time += dt;
      if (dx != 0 || dy != 0 || rot != 0) {
        _angle += rot;
        final nx = _px + dx;
        final ny = _py + dy;
        if (!_isWall(nx, _py)) _px = nx;
        if (!_isWall(_px, ny)) _py = ny;
      }
    });
  }

  bool _isWall(double x, double y) {
    const r = _playerRadius;
    for (final ox in [-r, r]) {
      for (final oy in [-r, r]) {
        final mx = (x + ox).floor();
        final my = (y + oy).floor();
        if (mx < 0 || my < 0 || mx >= _map[0].length || my >= _map.length) {
          return true;
        }
        if (_map[my][mx] != 0) return true;
      }
    }
    return false;
  }

  void _onKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _keys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keys.remove(event.logicalKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar para Labs',
          onPressed: () => context.go(GamesRoutePaths.index),
        ),
        title: Text('Raycaster Maze', style: textTheme.titleLarge),
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          onPanStart: (d) {
            _pointerDown = true;
            _lastPointerX = d.globalPosition.dx;
          },
          onPanUpdate: (d) {
            if (!_pointerDown) return;
            final delta = d.globalPosition.dx - _lastPointerX;
            _lastPointerX = d.globalPosition.dx;
            setState(() => _angle += delta * _mouseSensitivity);
          },
          onPanEnd: (_) => _pointerDown = false,
          child: MouseRegion(
            onHover: (event) {
              if (_pointerDown) return;
              setState(() => _angle += event.delta.dx * _mouseSensitivity);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    willChange: true,
                    painter: _RaycasterPainter(
                      playerX: _px,
                      playerY: _py,
                      playerAngle: _angle,
                      time: _time,
                      map: _map,
                      wallColors: _wallColors,
                      neonColors: _neonColors,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                // HUD crosshair + scanline overlay.
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _HudPainter(time: _time),
                    child: const SizedBox.expand(),
                  ),
                ),
                // Minimap overlay.
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(140, 140),
                      painter: _MinimapPainter(
                        playerX: _px,
                        playerY: _py,
                        playerAngle: _angle,
                        map: _map,
                        wallColors: _wallColors,
                        neonColors: _neonColors,
                        fov: _fov,
                      ),
                    ),
                  ),
                ),
                // Controls hint.
                Positioned(
                  left: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0A0A0F),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: const Color(0xFF7132F5).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'WASD ou setas para mover\nMouse para olhar',
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF9497A9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Raycaster painter — DDA with cyberpunk lighting.
// ---------------------------------------------------------------------------

const _fogColor = Color(0xFF0D0816);
const _ceilingTop = Color(0xFF050510);
const _ceilingHorizon = Color(0xFF1A0A2E);
const _floorHorizon = Color(0xFF0A1218);
const _floorBottom = Color(0xFF050508);
const _gridColor = Color(0xFF7132F5);

class _RaycasterPainter extends CustomPainter {
  _RaycasterPainter({
    required this.playerX,
    required this.playerY,
    required this.playerAngle,
    required this.time,
    required this.map,
    required this.wallColors,
    required this.neonColors,
  });

  final double playerX;
  final double playerY;
  final double playerAngle;
  final double time;
  final List<List<int>> map;
  final Map<int, Color> wallColors;
  final Map<int, Color> neonColors;

  static const double _fov = _RaycasterPlaygroundState._fov;

  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width.toInt();
    final h = size.height;
    final halfH = h / 2;

    // --- Gradient ceiling ---
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_ceilingTop, _ceilingHorizon],
    ).createShader(Rect.fromLTWH(0, 0, size.width, halfH));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, halfH), _paint);

    // --- Gradient floor ---
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_floorHorizon, _floorBottom],
    ).createShader(Rect.fromLTWH(0, halfH, size.width, halfH));
    canvas.drawRect(Rect.fromLTWH(0, halfH, size.width, halfH), _paint);
    _paint.shader = null;

    // --- Floor grid lines (horizontal perspective lines) ---
    _paint
      ..color = _gridColor.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var row = 0; row < 20; row++) {
      final t = row / 20.0;
      final y = halfH + (halfH * t * t);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }

    // --- Cast rays ---
    final tanHalfFov = tan(_fov / 2);

    for (var x = 0; x < w; x++) {
      final cameraX = 2.0 * x / w - 1;
      final rayAngle = playerAngle + atan(cameraX * tanHalfFov);
      final rayDirX = cos(rayAngle);
      final rayDirY = sin(rayAngle);

      var mapX = playerX.floor();
      var mapY = playerY.floor();

      final deltaDistX = rayDirX == 0 ? 1e30 : (1.0 / rayDirX).abs();
      final deltaDistY = rayDirY == 0 ? 1e30 : (1.0 / rayDirY).abs();

      int stepX;
      int stepY;
      double sideDistX;
      double sideDistY;

      if (rayDirX < 0) {
        stepX = -1;
        sideDistX = (playerX - mapX) * deltaDistX;
      } else {
        stepX = 1;
        sideDistX = (mapX + 1.0 - playerX) * deltaDistX;
      }
      if (rayDirY < 0) {
        stepY = -1;
        sideDistY = (playerY - mapY) * deltaDistY;
      } else {
        stepY = 1;
        sideDistY = (mapY + 1.0 - playerY) * deltaDistY;
      }

      var hit = 0;
      var side = 0;

      while (hit == 0) {
        if (sideDistX < sideDistY) {
          sideDistX += deltaDistX;
          mapX += stepX;
          side = 0;
        } else {
          sideDistY += deltaDistY;
          mapY += stepY;
          side = 1;
        }
        if (mapY >= 0 &&
            mapY < map.length &&
            mapX >= 0 &&
            mapX < map[0].length) {
          hit = map[mapY][mapX];
        } else {
          hit = 1;
        }
      }

      final perpDist = side == 0
          ? (mapX - playerX + (1 - stepX) / 2) / rayDirX
          : (mapY - playerY + (1 - stepY) / 2) / rayDirY;

      final wallH = (h / perpDist.clamp(0.01, 100)).clamp(0.0, h * 2);
      final wallTop = halfH - wallH / 2;
      final wallBottom = wallTop + wallH;

      // Wall hit position along surface (0..1) for texture variation.
      double wallX;
      if (side == 0) {
        wallX = playerY + perpDist * rayDirY;
      } else {
        wallX = playerX + perpDist * rayDirX;
      }
      wallX -= wallX.floor();

      // Distance fog blending toward purple.
      final fogFactor = (perpDist / 12.0).clamp(0.0, 0.85);
      final shade = (1.0 / (1.0 + perpDist * 0.12)).clamp(0.1, 1.0);
      final sideMul = side == 1 ? 0.65 : 1.0;

      final baseColor = wallColors[hit] ?? const Color(0xFF7132F5);
      final fogR = (_fogColor.r * 255).round();
      final fogG = (_fogColor.g * 255).round();
      final fogB = (_fogColor.b * 255).round();
      final r = _lerpInt(
        (baseColor.r * shade * sideMul).round(),
        fogR,
        fogFactor,
      );
      final g = _lerpInt(
        (baseColor.g * shade * sideMul).round(),
        fogG,
        fogFactor,
      );
      final b = _lerpInt(
        (baseColor.b * shade * sideMul).round(),
        fogB,
        fogFactor,
      );

      // Main wall column.
      _paint
        ..color = Color.fromARGB(255, r, g, b)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x.toDouble(), wallTop),
        Offset(x.toDouble(), wallBottom),
        _paint,
      );

      // Neon trim — bright line at wall top and bottom edges.
      final neon = neonColors[hit] ?? const Color(0xFFB484FF);
      final neonAlpha = ((1.0 - fogFactor) * 0.9).clamp(0.0, 1.0);
      if (neonAlpha > 0.05) {
        _paint.color = neon.withValues(alpha: neonAlpha);
        // Top trim (2px).
        canvas.drawLine(
          Offset(x.toDouble(), wallTop),
          Offset(x.toDouble(), wallTop + 2),
          _paint,
        );
        // Bottom trim (2px).
        canvas.drawLine(
          Offset(x.toDouble(), wallBottom - 2),
          Offset(x.toDouble(), wallBottom),
          _paint,
        );
        // Vertical seam glow at tile edges.
        if (wallX < 0.03 || wallX > 0.97) {
          _paint.color = neon.withValues(alpha: neonAlpha * 0.4);
          canvas.drawLine(
            Offset(x.toDouble(), wallTop),
            Offset(x.toDouble(), wallBottom),
            _paint,
          );
        }
      }

      // Floor glow beneath close walls — neon light spill.
      if (perpDist < 4.0 && wallBottom < h) {
        final glowAlpha = ((1.0 - perpDist / 4.0) * 0.15).clamp(0.0, 0.15);
        _paint.color = neon.withValues(alpha: glowAlpha);
        final glowExtent = (20.0 * (1.0 - perpDist / 4.0)).clamp(0.0, 20.0);
        canvas.drawLine(
          Offset(x.toDouble(), wallBottom),
          Offset(x.toDouble(), wallBottom + glowExtent),
          _paint,
        );
      }

      // Vertical floor grid lines (perspective).
      if (x % 60 == 0) {
        _paint.color = _gridColor.withValues(alpha: 0.04);
        canvas.drawLine(
          Offset(x.toDouble(), halfH),
          Offset(x.toDouble(), h),
          _paint,
        );
      }
    }
  }

  int _lerpInt(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

  @override
  bool shouldRepaint(_RaycasterPainter old) =>
      playerX != old.playerX ||
      playerY != old.playerY ||
      playerAngle != old.playerAngle ||
      time != old.time;
}

// ---------------------------------------------------------------------------
// HUD painter — crosshair, scanlines, vignette.
// ---------------------------------------------------------------------------

class _HudPainter extends CustomPainter {
  _HudPainter({required this.time});

  final double time;
  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Scanlines.
    _paint
      ..color = const Color(0x08000000)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }

    // Vignette — dark corners.
    final vignetteRect = Rect.fromLTWH(0, 0, size.width, size.height);
    _paint
      ..shader = RadialGradient(
        colors: [
          const Color(0x00000000),
          const Color(0x00000000),
          const Color(0x60000000),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(vignetteRect)
      ..strokeWidth = 0;
    canvas.drawRect(vignetteRect, _paint);
    _paint.shader = null;

    // Crosshair — neon purple, pulsing.
    final pulse = 0.7 + 0.3 * sin(time * 3);
    _paint
      ..color = Color.fromRGBO(113, 50, 245, pulse)
      ..strokeWidth = 1.5;
    const gap = 6.0;
    const arm = 14.0;
    // Horizontal arms.
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx - gap, cy), _paint);
    canvas.drawLine(Offset(cx + gap, cy), Offset(cx + arm, cy), _paint);
    // Vertical arms.
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy - gap), _paint);
    canvas.drawLine(Offset(cx, cy + gap), Offset(cx, cy + arm), _paint);
    // Center dot.
    _paint.color = Color.fromRGBO(113, 50, 245, pulse * 0.6);
    canvas.drawCircle(Offset(cx, cy), 1.5, _paint);
  }

  @override
  bool shouldRepaint(_HudPainter old) => (time - old.time).abs() > 0.03;
}

// ---------------------------------------------------------------------------
// Minimap painter — top-down view with neon styling.
// ---------------------------------------------------------------------------

class _MinimapPainter extends CustomPainter {
  _MinimapPainter({
    required this.playerX,
    required this.playerY,
    required this.playerAngle,
    required this.map,
    required this.wallColors,
    required this.neonColors,
    required this.fov,
  });

  final double playerX;
  final double playerY;
  final double playerAngle;
  final List<List<int>> map;
  final Map<int, Color> wallColors;
  final Map<int, Color> neonColors;
  final double fov;

  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final rows = map.length;
    final cols = map[0].length;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Background with border glow.
    final bgRect = Offset.zero & size;
    _paint.color = const Color(0xDD0A0A0F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      _paint,
    );
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      _paint,
    );
    _paint.style = PaintingStyle.fill;

    // Walls with neon glow.
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final cell = map[y][x];
        if (cell == 0) continue;
        final neon = neonColors[cell] ?? const Color(0xFFB484FF);
        _paint.color = neon.withValues(alpha: 0.6);
        canvas.drawRect(
          Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
          _paint,
        );
      }
    }

    // Grid lines.
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    for (var y = 0; y <= rows; y++) {
      canvas.drawLine(
        Offset(0, y * cellH),
        Offset(size.width, y * cellH),
        _paint,
      );
    }
    for (var x = 0; x <= cols; x++) {
      canvas.drawLine(
        Offset(x * cellW, 0),
        Offset(x * cellW, size.height),
        _paint,
      );
    }

    // FOV cone.
    final px = playerX * cellW;
    final py = playerY * cellH;
    const coneLen = 24.0;

    final leftAngle = playerAngle - fov / 2;
    final rightAngle = playerAngle + fov / 2;

    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(px, py)
      ..lineTo(px + cos(leftAngle) * coneLen, py + sin(leftAngle) * coneLen)
      ..lineTo(px + cos(rightAngle) * coneLen, py + sin(rightAngle) * coneLen)
      ..close();
    canvas.drawPath(path, _paint);

    // Player dot with glow.
    _paint.color = const Color(0xFF7132F5).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(px, py), 6, _paint);
    _paint.color = const Color(0xFFB484FF);
    canvas.drawCircle(Offset(px, py), 2.5, _paint);
  }

  @override
  bool shouldRepaint(_MinimapPainter old) =>
      playerX != old.playerX ||
      playerY != old.playerY ||
      playerAngle != old.playerAngle;
}
