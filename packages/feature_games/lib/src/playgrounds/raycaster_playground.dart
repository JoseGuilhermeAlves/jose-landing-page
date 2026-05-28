import 'dart:math';
import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Game types
// ---------------------------------------------------------------------------

enum _GamePhase { playing, dead, victory }

class _Enemy {
  _Enemy({
    required this.x,
    required this.y,
    this.health = 50,
    this.maxHealth = 50,
    this.speed = 1.2,
    this.damage = 10,
    this.attackCooldown = 1.0,
  });

  double x;
  double y;
  int health;
  final int maxHealth;
  final double speed;
  final int damage;
  final double attackCooldown;
  double lastAttackTime = -10;
  double lastHitTime = -10;
  double deathTime = -1;
  bool get alive => health > 0;
  double get healthFrac => (health / maxHealth).clamp(0.0, 1.0);
}

class _Particle {
  _Particle(this.x, this.y, this.vx, this.vy, this.color, this.birth);
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double birth;
  static const double lifespan = 0.6;
}

// Sentinel silhouette: (relativeY 0=top 1=bottom, halfWidth 0..0.5).
const _sentinelProfile = <(double, double)>[
  (0.00, 0.03),
  (0.06, 0.06),
  (0.10, 0.04),
  (0.13, 0.18),
  (0.20, 0.22),
  (0.26, 0.14),
  (0.30, 0.42),
  (0.38, 0.48),
  (0.50, 0.45),
  (0.60, 0.40),
  (0.66, 0.28),
  (0.72, 0.22),
  (0.78, 0.24),
  (0.88, 0.18),
  (0.95, 0.20),
  (1.00, 0.10),
];

double _spriteHalfWidth(double relY) {
  if (relY <= 0) return _sentinelProfile.first.$2;
  if (relY >= 1) return _sentinelProfile.last.$2;
  for (var i = 1; i < _sentinelProfile.length; i++) {
    final (y1, w1) = _sentinelProfile[i];
    if (relY <= y1) {
      final (y0, w0) = _sentinelProfile[i - 1];
      final t = (relY - y0) / (y1 - y0);
      return w0 + (w1 - w0) * t;
    }
  }
  return _sentinelProfile.last.$2;
}

// ---------------------------------------------------------------------------
// Raycaster playground — cyberpunk FPS.
// ---------------------------------------------------------------------------

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
  int _playerHealth = 100;
  static const int _playerMaxHealth = 100;

  int _ammo = 100;
  static const int _maxAmmo = 100;
  static const int _weaponDamage = 25;
  static const double _fireRate = 0.25;
  static const double _weaponRange = 15;
  double _lastFireTime = -10;
  double _lastDamageTime = -10;
  bool _didHitEnemy = false;

  double _weaponBobPhase = 0;
  bool _isMoving = false;

  late List<_Enemy> _enemies;
  final List<_Particle> _particles = [];
  int _kills = 0;

  _GamePhase _phase = _GamePhase.playing;

  double _lastPointerX = 0;
  bool _pointerDown = false;

  static const double _moveSpeed = 2.4;
  static const double _rotSpeed = 1.8;
  static const double _mouseSensitivity = 0.003;
  static const double _playerRadius = 0.2;
  static const double _fov = pi / 3;
  static const double _enemyDetectRange = 8;
  static const double _enemyAttackRange = 1.5;

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

  static final _rng = Random();

  @override
  void initState() {
    super.initState();
    _enemies = _spawnEnemies();
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

  List<_Enemy> _spawnEnemies() => [
        _Enemy(x: 8.5, y: 2.5),
        _Enemy(x: 13.5, y: 5.5),
        _Enemy(x: 4.5, y: 9.5),
        _Enemy(
          x: 7.5,
          y: 12.5,
          health: 75,
          maxHealth: 75,
          speed: 1.5,
          damage: 15,
        ),
        _Enemy(x: 13.5, y: 11.5),
        _Enemy(
          x: 2.5,
          y: 13.5,
          health: 75,
          maxHealth: 75,
          speed: 1.5,
          attackCooldown: 0.7,
        ),
      ];

  void _restart() {
    setState(() {
      _px = 2.5;
      _py = 2.5;
      _angle = 0;
      _playerHealth = _playerMaxHealth;
      _ammo = _maxAmmo;
      _kills = 0;
      _lastFireTime = -10;
      _lastDamageTime = -10;
      _didHitEnemy = false;
      _enemies = _spawnEnemies();
      _particles.clear();
      _phase = _GamePhase.playing;
    });
  }

  DateTime _lastFrame = DateTime.now();

  void _gameLoop() {
    final now = DateTime.now();
    final dt =
        (now.difference(_lastFrame).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastFrame = now;

    if (_phase != _GamePhase.playing) {
      setState(() => _time += dt);
      return;
    }

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
      _isMoving = dx != 0 || dy != 0;
      if (_isMoving) _weaponBobPhase += dt * 8;

      if (dx != 0 || dy != 0 || rot != 0) {
        _angle += rot;
        final nx = _px + dx;
        final ny = _py + dy;
        if (!_isWall(nx, _py)) _px = nx;
        if (!_isWall(_px, ny)) _py = ny;
      }

      _updateEnemies(dt);
      _updateParticles(dt);
      _checkGamePhase();
    });
  }

  void _updateEnemies(double dt) {
    for (final e in _enemies) {
      if (!e.alive) continue;

      final edx = _px - e.x;
      final edy = _py - e.y;
      final dist = sqrt(edx * edx + edy * edy);

      if (dist > _enemyDetectRange) continue;
      if (!_hasLineOfSight(e.x, e.y, _px, _py)) continue;

      if (dist > _enemyAttackRange) {
        final moveAmt = e.speed * dt;
        final nx = e.x + (edx / dist) * moveAmt;
        final ny = e.y + (edy / dist) * moveAmt;
        if (!_isWallForEnemy(nx, e.y)) e.x = nx;
        if (!_isWallForEnemy(e.x, ny)) e.y = ny;
      }

      if (dist < _enemyAttackRange &&
          _time - e.lastAttackTime > e.attackCooldown) {
        e.lastAttackTime = _time;
        _playerHealth = (_playerHealth - e.damage).clamp(0, _playerMaxHealth);
        _lastDamageTime = _time;
      }
    }
  }

  void _updateParticles(double dt) {
    _particles.removeWhere((p) => _time - p.birth > _Particle.lifespan);
    for (final p in _particles) {
      p
        ..x += p.vx * dt
        ..y += p.vy * dt
        ..vy += 4.0 * dt;
    }
  }

  void _spawnHitParticles(double ex, double ey, Color color) {
    for (var i = 0; i < 6; i++) {
      _particles.add(_Particle(
        ex,
        ey,
        (_rng.nextDouble() - 0.5) * 3,
        (_rng.nextDouble() - 0.5) * 3,
        color,
        _time,
      ));
    }
  }

  bool _hasLineOfSight(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final dist = sqrt(dx * dx + dy * dy);
    final steps = (dist * 4).ceil();
    for (var i = 1; i < steps; i++) {
      final t = i / steps;
      final cx = (x1 + dx * t).floor();
      final cy = (y1 + dy * t).floor();
      if (cy < 0 || cy >= _map.length || cx < 0 || cx >= _map[0].length) {
        return false;
      }
      if (_map[cy][cx] != 0) return false;
    }
    return true;
  }

  void _checkGamePhase() {
    if (_playerHealth <= 0) {
      _phase = _GamePhase.dead;
      return;
    }
    if (_enemies.every((e) => !e.alive)) {
      _phase = _GamePhase.victory;
    }
  }

  void _fire() {
    if (_phase != _GamePhase.playing) return;
    if (_ammo <= 0) return;
    if (_time - _lastFireTime < _fireRate) return;

    setState(() {
      _ammo--;
      _lastFireTime = _time;
      _didHitEnemy = false;

      _Enemy? hitEnemy;
      var hitDist = _weaponRange;

      for (final e in _enemies) {
        if (!e.alive) continue;

        final edx = e.x - _px;
        final edy = e.y - _py;
        final dist = sqrt(edx * edx + edy * edy);
        if (dist > _weaponRange || dist >= hitDist) continue;

        var angleToEnemy = atan2(edy, edx) - _angle;
        while (angleToEnemy > pi) {
          angleToEnemy -= 2 * pi;
        }
        while (angleToEnemy < -pi) {
          angleToEnemy += 2 * pi;
        }

        const enemyHitRadius = 0.45;
        final angularSize = atan2(enemyHitRadius, dist);

        if (angleToEnemy.abs() < angularSize) {
          hitEnemy = e;
          hitDist = dist;
        }
      }

      if (hitEnemy != null) {
        hitEnemy
          ..health -= _weaponDamage
          ..lastHitTime = _time;
        _didHitEnemy = true;
        final hitColor = hitEnemy.alive
            ? const Color(0xFF00FFE5)
            : const Color(0xFFFF6644);
        _spawnHitParticles(hitEnemy.x, hitEnemy.y, hitColor);
        if (!hitEnemy.alive) {
          hitEnemy.deathTime = _time;
          _kills++;
          _spawnHitParticles(hitEnemy.x, hitEnemy.y, const Color(0xFFFF4444));
        }
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

  bool _isWallForEnemy(double x, double y) {
    const r = 0.3;
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
      if (event.logicalKey == LogicalKeyboardKey.space) _fire();
      if (event.logicalKey == LogicalKeyboardKey.keyR &&
          _phase != _GamePhase.playing) {
        _restart();
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).maybePop();
      }
    } else if (event is KeyUpEvent) {
      _keys.remove(event.logicalKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Listener(
          onPointerDown: (event) {
            if (event.kind == PointerDeviceKind.mouse) _fire();
          },
          child: GestureDetector(
            onTap: _fire,
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
                        enemies: _enemies,
                        particles: _particles,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _HudPainter(
                        time: _time,
                        health: _playerHealth,
                        maxHealth: _playerMaxHealth,
                        ammo: _ammo,
                        maxAmmo: _maxAmmo,
                        kills: _kills,
                        totalEnemies: _enemies.length,
                        lastFireTime: _lastFireTime,
                        lastDamageTime: _lastDamageTime,
                        didHitEnemy: _didHitEnemy,
                        weaponBob: _isMoving ? sin(_weaponBobPhase) * 5 : 0,
                        weaponSway:
                            _isMoving ? cos(_weaponBobPhase * 0.5) * 3 : 0,
                        phase: _phase,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(150, 150),
                        painter: _MinimapPainter(
                          playerX: _px,
                          playerY: _py,
                          playerAngle: _angle,
                          map: _map,
                          wallColors: _wallColors,
                          neonColors: _neonColors,
                          fov: _fov,
                          enemies: _enemies,
                          time: _time,
                        ),
                      ),
                    ),
                  ),
                  // Back button overlay.
                  Positioned(
                    left: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF9497A9),
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0A0A0F).withValues(alpha: 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: const Color(0xFF7132F5)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      tooltip: 'Voltar (ESC)',
                      onPressed: () => Navigator.of(context).maybePop(),
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
                          color:
                              const Color(0xFF7132F5).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'WASD mover · Mouse olhar\n'
                        'Clique/Espaço atirar · R reiniciar',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

const _fogColor = Color(0xFF0D0816);
const _ceilingTop = Color(0xFF050510);
const _ceilingHorizon = Color(0xFF1A0A2E);
const _floorHorizon = Color(0xFF0A1218);
const _floorBottom = Color(0xFF050508);
const _gridColor = Color(0xFF7132F5);

// ---------------------------------------------------------------------------
// Raycaster painter — DDA walls + textured panels + sprite enemies + particles.
// ---------------------------------------------------------------------------

class _RaycasterPainter extends CustomPainter {
  _RaycasterPainter({
    required this.playerX,
    required this.playerY,
    required this.playerAngle,
    required this.time,
    required this.map,
    required this.wallColors,
    required this.neonColors,
    required this.enemies,
    required this.particles,
  });

  final double playerX;
  final double playerY;
  final double playerAngle;
  final double time;
  final List<List<int>> map;
  final Map<int, Color> wallColors;
  final Map<int, Color> neonColors;
  final List<_Enemy> enemies;
  final List<_Particle> particles;

  static const double _fov = _RaycasterPlaygroundState._fov;

  final _paint = Paint();

  static Float64List _zBuffer = Float64List(0);
  static int _lastW = 0;

  static final List<int> _sortedIndices = [];
  static final List<double> _sortedDist = [];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width.toInt();
    final h = size.height;
    final halfH = h / 2;

    if (_lastW != w) {
      _zBuffer = Float64List(w);
      _lastW = w;
    }

    _drawCeilingFloor(canvas, size, halfH);
    _drawFloorGrid(canvas, size, halfH, w);
    _castWalls(canvas, w, h, halfH);
    _drawEnemySprites(canvas, w.toDouble(), h, halfH);
    _drawParticles(canvas, w.toDouble(), h, halfH);
  }

  void _drawCeilingFloor(Canvas canvas, Size size, double halfH) {
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_ceilingTop, _ceilingHorizon],
    ).createShader(Rect.fromLTWH(0, 0, size.width, halfH));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, halfH), _paint);

    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_floorHorizon, _floorBottom],
    ).createShader(Rect.fromLTWH(0, halfH, size.width, halfH));
    canvas.drawRect(Rect.fromLTWH(0, halfH, size.width, halfH), _paint);
    _paint.shader = null;
  }

  void _drawFloorGrid(Canvas canvas, Size size, double halfH, int w) {
    _paint
      ..color = _gridColor.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var row = 0; row < 24; row++) {
      final t = row / 24.0;
      final y = halfH + (halfH * t * t);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }
    for (var x = 0; x < w; x += 50) {
      _paint.color = _gridColor.withValues(alpha: 0.04);
      canvas.drawLine(
        Offset(x.toDouble(), halfH),
        Offset(x.toDouble(), halfH * 2),
        _paint,
      );
    }
  }

  void _castWalls(Canvas canvas, int w, double h, double halfH) {
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

      _zBuffer[x] = perpDist;

      final wallH = (h / perpDist.clamp(0.01, 100)).clamp(0.0, h * 2);
      final wallTop = halfH - wallH / 2;
      final wallBottom = wallTop + wallH;

      double wallX;
      if (side == 0) {
        wallX = playerY + perpDist * rayDirY;
      } else {
        wallX = playerX + perpDist * rayDirX;
      }
      wallX -= wallX.floor();

      final fogFactor = (perpDist / 14.0).clamp(0.0, 0.88);
      final shade = (1.0 / (1.0 + perpDist * 0.1)).clamp(0.08, 1.0);
      final sideMul = side == 1 ? 0.6 : 1.0;

      final baseColor = wallColors[hit] ?? const Color(0xFF7132F5);
      final fogR = (_fogColor.r * 255).round();
      final fogG = (_fogColor.g * 255).round();
      final fogB = (_fogColor.b * 255).round();

      // Procedural wall texture variation.
      var texMul = 1.0;

      // Horizontal panel grooves.
      if (wallX > 0.48 && wallX < 0.52) texMul *= 0.7;
      if (wallX < 0.02 || wallX > 0.98) texMul *= 0.6;

      // Vertical panel bands (based on screen-space wall height).
      final relY = (wallTop + wallH * 0.25 - halfH).abs() / wallH;
      if (relY < 0.02 || (relY > 0.48 && relY < 0.52)) texMul *= 0.75;

      // Wall type-specific detail.
      if (hit == 2) {
        // Brick pattern.
        final brickRow = (wallX * 4).floor();
        final brickFrac = wallX * 4 - brickRow;
        if (brickFrac < 0.06 || brickFrac > 0.94) texMul *= 0.6;
      } else if (hit == 3) {
        // Tech circuit lines.
        final circuit = sin(wallX * 12 * pi) * 0.5 + 0.5;
        texMul *= 0.85 + circuit * 0.15;
      } else if (hit == 4) {
        // Rust/damage variation.
        final rust = sin(wallX * 7.3 + mapX * 3.1) * 0.5 + 0.5;
        texMul *= 0.8 + rust * 0.2;
      }

      final effShade = shade * sideMul * texMul;
      final r = _lerpInt(
        (baseColor.r * effShade).round().clamp(0, 255),
        fogR,
        fogFactor,
      );
      final g = _lerpInt(
        (baseColor.g * effShade).round().clamp(0, 255),
        fogG,
        fogFactor,
      );
      final b = _lerpInt(
        (baseColor.b * effShade).round().clamp(0, 255),
        fogB,
        fogFactor,
      );

      _paint
        ..color = Color.fromARGB(255, r, g, b)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x.toDouble(), wallTop),
        Offset(x.toDouble(), wallBottom),
        _paint,
      );

      // Neon trim.
      final neon = neonColors[hit] ?? const Color(0xFFB484FF);
      final neonAlpha = ((1.0 - fogFactor) * 0.9).clamp(0.0, 1.0);
      if (neonAlpha > 0.05) {
        _paint.color = neon.withValues(alpha: neonAlpha);
        canvas
          ..drawLine(
            Offset(x.toDouble(), wallTop),
            Offset(x.toDouble(), wallTop + 2),
            _paint,
          )
          ..drawLine(
            Offset(x.toDouble(), wallBottom - 2),
            Offset(x.toDouble(), wallBottom),
            _paint,
          );
        // Mid-wall horizontal accent.
        if (perpDist < 6) {
          final midY = halfH;
          _paint.color = neon.withValues(alpha: neonAlpha * 0.25);
          canvas.drawLine(
            Offset(x.toDouble(), midY - 1),
            Offset(x.toDouble(), midY + 1),
            _paint,
          );
        }
        // Vertical seam.
        if (wallX < 0.03 || wallX > 0.97) {
          _paint.color = neon.withValues(alpha: neonAlpha * 0.5);
          canvas.drawLine(
            Offset(x.toDouble(), wallTop),
            Offset(x.toDouble(), wallBottom),
            _paint,
          );
        }
      }

      // Floor glow from nearby neon walls.
      if (perpDist < 5.0 && wallBottom < h) {
        final glowAlpha = ((1.0 - perpDist / 5.0) * 0.18).clamp(0.0, 0.18);
        _paint.color = neon.withValues(alpha: glowAlpha);
        final glowExtent = (25.0 * (1.0 - perpDist / 5.0)).clamp(0.0, 25.0);
        canvas.drawLine(
          Offset(x.toDouble(), wallBottom),
          Offset(x.toDouble(), wallBottom + glowExtent),
          _paint,
        );
      }
    }
  }

  void _drawEnemySprites(Canvas canvas, double w, double h, double halfH) {
    final dirX = cos(playerAngle);
    final dirY = sin(playerAngle);
    final tanHalf = tan(_fov / 2);
    final planeX = -dirY * tanHalf;
    final planeY = dirX * tanHalf;
    final invDet = 1.0 / (planeX * dirY - dirX * planeY);

    _sortedIndices.clear();
    _sortedDist.clear();
    for (var i = 0; i < enemies.length; i++) {
      final e = enemies[i];
      if (e.alive || (e.deathTime > 0 && time - e.deathTime < 0.8)) {
        final dx = e.x - playerX;
        final dy = e.y - playerY;
        _sortedDist.add(dx * dx + dy * dy);
        _sortedIndices.add(i);
      }
    }

    // Insertion sort far→near.
    for (var i = 1; i < _sortedIndices.length; i++) {
      final key = _sortedIndices[i];
      final keyD = _sortedDist[i];
      var j = i - 1;
      while (j >= 0 && _sortedDist[j] < keyD) {
        _sortedIndices[j + 1] = _sortedIndices[j];
        _sortedDist[j + 1] = _sortedDist[j];
        j--;
      }
      _sortedIndices[j + 1] = key;
      _sortedDist[j + 1] = keyD;
    }

    final wInt = w.toInt();

    for (final idx in _sortedIndices) {
      final e = enemies[idx];
      final spX = e.x - playerX;
      final spY = e.y - playerY;

      final transformX = invDet * (dirY * spX - dirX * spY);
      final transformY = invDet * (-planeY * spX + planeX * spY);

      if (transformY <= 0.1) continue;

      final spriteScreenX = (w / 2) * (1 + transformX / transformY);
      final spriteH = (h / transformY).abs();
      final spriteW = spriteH * 0.6;

      // Death: collapse downward + fade.
      var scaleMulY = 1.0;
      var scaleMulX = 1.0;
      var alphaMul = 1.0;
      var vertShift = 0.0;
      if (!e.alive && e.deathTime > 0) {
        final t = ((time - e.deathTime) / 0.8).clamp(0.0, 1.0);
        scaleMulY = 1.0 - t * 0.8;
        scaleMulX = 1.0 + t * 0.3;
        alphaMul = 1.0 - t;
        vertShift = t * spriteH * 0.3;
      }

      // Hit flash.
      final hitFlash =
          e.lastHitTime > 0 && (time - e.lastHitTime) < 0.12;

      final adjH = spriteH * scaleMulY;
      final adjW = spriteW * scaleMulX;
      final centerY = halfH + vertShift;

      final drawStartX = (spriteScreenX - adjW / 2).floor();
      final drawEndX = (spriteScreenX + adjW / 2).ceil();

      final fogFactor = (transformY / 14.0).clamp(0.0, 0.88);
      final damageLerp = 1.0 - e.healthFrac;

      // Body color lerps toward red when damaged.
      final bodyR = _lerpInt(0, 255, damageLerp);
      final bodyG = _lerpInt(212, 68, damageLerp);
      final bodyB = _lerpInt(192, 68, damageLerp);
      final bodyBase = Color.fromARGB(255, bodyR, bodyG, bodyB);

      final neonR = _lerpInt(0, 255, damageLerp);
      final neonG = _lerpInt(255, 100, damageLerp);
      final neonB = _lerpInt(229, 100, damageLerp);
      final neonBase = Color.fromARGB(255, neonR, neonG, neonB);

      // Draw sentinel silhouette column by column.
      for (var stripe = drawStartX; stripe < drawEndX; stripe++) {
        if (stripe < 0 || stripe >= wInt) continue;
        if (transformY >= _zBuffer[stripe]) continue;

        final stripX = (stripe - spriteScreenX + adjW / 2) / adjW;

        // Walk the profile to find visible Y range for this column.
        double? colTopRel;
        double? colBottomRel;
        const step = 0.02;
        for (var ry = 0.0; ry <= 1.0; ry += step) {
          final hw = _spriteHalfWidth(ry);
          final left = 0.5 - hw;
          final right = 0.5 + hw;
          if (stripX >= left && stripX <= right) {
            colTopRel ??= ry;
            colBottomRel = ry;
          }
        }
        if (colTopRel == null || colBottomRel == null) continue;

        final colTop = centerY - adjH / 2 + adjH * colTopRel;
        final colBottom = centerY - adjH / 2 + adjH * colBottomRel;
        if (colBottom - colTop < 1) continue;

        // Color zones based on relY.
        final midRel = (colTopRel + colBottomRel) / 2;
        final isHead = midRel < 0.25;
        final isCore = midRel > 0.35 && midRel < 0.55;

        Color baseCol;
        if (hitFlash) {
          baseCol = const Color(0xFFFFFFFF);
        } else if (isCore) {
          final pulse = 0.7 + 0.3 * sin(time * 6 + idx * 1.5);
          baseCol = Color.lerp(bodyBase, neonBase, pulse)!;
        } else if (isHead) {
          baseCol = Color.lerp(bodyBase, const Color(0xFF1A1528), 0.3)!;
        } else {
          baseCol = bodyBase;
        }

        final bodyAlpha =
            ((1.0 - fogFactor) * 0.9 * alphaMul).clamp(0.0, 1.0);
        _paint
          ..color = baseCol.withValues(alpha: bodyAlpha)
          ..strokeWidth = 1;
        canvas.drawLine(
          Offset(stripe.toDouble(), colTop),
          Offset(stripe.toDouble(), colBottom),
          _paint,
        );

        // Neon outline at silhouette edges.
        final neonAlpha =
            ((1.0 - fogFactor) * alphaMul).clamp(0.0, 1.0);
        if (neonAlpha > 0.05 && !hitFlash) {
          _paint.color = neonBase.withValues(alpha: neonAlpha * 0.8);
          canvas
            ..drawLine(
              Offset(stripe.toDouble(), colTop),
              Offset(stripe.toDouble(), colTop + 2),
              _paint,
            )
            ..drawLine(
              Offset(stripe.toDouble(), colBottom - 2),
              Offset(stripe.toDouble(), colBottom),
              _paint,
            );
        }
      }

      // Eye / core glow.
      final screenXClamped = spriteScreenX.floor().clamp(0, wInt - 1);
      if (spriteScreenX > -adjW &&
          spriteScreenX < w + adjW &&
          transformY < _zBuffer[screenXClamped]) {
        final coreAlpha = ((1.0 - fogFactor) * alphaMul).clamp(0.0, 1.0);

        // Head eyes (two dots).
        final eyeY = centerY - adjH * 0.32;
        final eyeSpread = adjW * 0.12;

        if (hitFlash) {
          _paint.color = Color.fromRGBO(255, 255, 255, coreAlpha);
        } else {
          final eyePulse = 0.6 + 0.4 * sin(time * 5 + idx * 2.0);
          _paint.color = Color.fromRGBO(255, 80, 80, coreAlpha * eyePulse);
        }
        canvas
          ..drawCircle(
            Offset(spriteScreenX - eyeSpread, eyeY),
            adjH * 0.025 + 1,
            _paint,
          )
          ..drawCircle(
            Offset(spriteScreenX + eyeSpread, eyeY),
            adjH * 0.025 + 1,
            _paint,
          );

        // Core energy glow (torso).
        if (e.alive) {
          final corePulse = 0.4 + 0.6 * sin(time * 4 + idx.toDouble());
          _paint.color =
              neonBase.withValues(alpha: coreAlpha * corePulse * 0.35);
          canvas.drawCircle(
            Offset(spriteScreenX, centerY + adjH * 0.05),
            adjH * 0.12,
            _paint,
          );
          _paint.color =
              Color.fromRGBO(255, 255, 255, coreAlpha * corePulse * 0.5);
          canvas.drawCircle(
            Offset(spriteScreenX, centerY + adjH * 0.05),
            adjH * 0.04,
            _paint,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas, double w, double h, double halfH) {
    if (particles.isEmpty) return;

    final dirX = cos(playerAngle);
    final dirY = sin(playerAngle);
    final tanHalf = tan(_fov / 2);
    final planeX = -dirY * tanHalf;
    final planeY = dirX * tanHalf;
    final invDet = 1.0 / (planeX * dirY - dirX * planeY);

    for (final p in particles) {
      final age = time - p.birth;
      if (age > _Particle.lifespan) continue;

      final spX = p.x - playerX;
      final spY = p.y - playerY;
      final tY = invDet * (-planeY * spX + planeX * spY);
      if (tY <= 0.1) continue;

      final tX = invDet * (dirY * spX - dirX * spY);
      final sx = (w / 2) * (1 + tX / tY);
      final sy = halfH + (p.vy * 10) / tY;

      final pSize = (4.0 / tY).clamp(1.0, 8.0);
      final alpha = (1.0 - age / _Particle.lifespan).clamp(0.0, 1.0);

      _paint.color = p.color.withValues(alpha: alpha * 0.9);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(sx, sy), width: pSize, height: pSize),
        _paint,
      );
    }
  }

  int _lerpInt(int a, int b, double t) =>
      (a + (b - a) * t).round().clamp(0, 255);

  @override
  bool shouldRepaint(_RaycasterPainter old) =>
      playerX != old.playerX ||
      playerY != old.playerY ||
      playerAngle != old.playerAngle ||
      time != old.time;
}

// ---------------------------------------------------------------------------
// HUD painter — weapon, crosshair, health, ammo, kills, overlays.
// ---------------------------------------------------------------------------

class _HudPainter extends CustomPainter {
  _HudPainter({
    required this.time,
    required this.health,
    required this.maxHealth,
    required this.ammo,
    required this.maxAmmo,
    required this.kills,
    required this.totalEnemies,
    required this.lastFireTime,
    required this.lastDamageTime,
    required this.didHitEnemy,
    required this.weaponBob,
    required this.weaponSway,
    required this.phase,
  });

  final double time;
  final int health;
  final int maxHealth;
  final int ammo;
  final int maxAmmo;
  final int kills;
  final int totalEnemies;
  final double lastFireTime;
  final double lastDamageTime;
  final bool didHitEnemy;
  final double weaponBob;
  final double weaponSway;
  final _GamePhase phase;

  final _paint = Paint();
  final _gunPath = Path();
  final _detailPath = Path();
  final _healthText = TextPainter(textDirection: TextDirection.ltr);
  final _ammoText = TextPainter(textDirection: TextDirection.ltr);
  final _killsText = TextPainter(textDirection: TextDirection.ltr);
  final _statusText = TextPainter(textDirection: TextDirection.ltr);
  final _subtitleText = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    _drawScanlines(canvas, w, h);
    _drawVignette(canvas, w, h);
    _drawDamageFlash(canvas, w, h);

    if (phase == _GamePhase.playing) {
      _drawCrosshair(canvas, cx, cy);
    }

    _drawWeapon(canvas, w, h);
    _drawHealthBar(canvas, w);
    _drawAmmoCounter(canvas, w, h);
    _drawKillCounter(canvas, w);

    if (phase != _GamePhase.playing) {
      _drawGameOverlay(canvas, w, h);
    }
  }

  void _drawScanlines(Canvas canvas, double w, double h) {
    _paint
      ..color = const Color(0x0A000000)
      ..strokeWidth = 1;
    for (var y = 0.0; y < h; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(w, y), _paint);
    }
  }

  void _drawVignette(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    _paint
      ..shader = const RadialGradient(
        colors: [Color(0x00000000), Color(0x00000000), Color(0x70000000)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..strokeWidth = 0;
    canvas.drawRect(rect, _paint);
    _paint.shader = null;
  }

  void _drawDamageFlash(Canvas canvas, double w, double h) {
    final elapsed = time - lastDamageTime;
    if (elapsed < 0.5) {
      final alpha = (1.0 - elapsed / 0.5) * 0.4;
      _paint.color = Color.fromRGBO(255, 20, 20, alpha);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _paint);

      // Directional red bars on edges.
      _paint.color = Color.fromRGBO(200, 0, 0, alpha * 0.6);
      canvas
        ..drawRect(Rect.fromLTWH(0, 0, 40, h), _paint)
        ..drawRect(Rect.fromLTWH(w - 40, 0, 40, h), _paint);
    }
  }

  void _drawCrosshair(Canvas canvas, double cx, double cy) {
    final pulse = 0.7 + 0.3 * sin(time * 3);
    final timeSinceFire = time - lastFireTime;
    final isRecentFire = timeSinceFire < 0.15;

    Color color;
    double gap;
    double arm;
    double strokeW;

    if (isRecentFire && didHitEnemy) {
      // Hit marker: white X-shape that expands.
      final expand = timeSinceFire / 0.15;
      color = Color.fromRGBO(255, 255, 255, 1.0 - expand * 0.5);
      gap = 4 + expand * 4;
      arm = 16 + expand * 6;
      strokeW = 2.5;

      _paint
        ..color = color
        ..strokeWidth = strokeW;
      // Diagonal hit marker.
      canvas
        ..drawLine(
          Offset(cx - arm * 0.7, cy - arm * 0.7),
          Offset(cx - gap * 0.7, cy - gap * 0.7),
          _paint,
        )
        ..drawLine(
          Offset(cx + arm * 0.7, cy - arm * 0.7),
          Offset(cx + gap * 0.7, cy - gap * 0.7),
          _paint,
        )
        ..drawLine(
          Offset(cx - arm * 0.7, cy + arm * 0.7),
          Offset(cx - gap * 0.7, cy + gap * 0.7),
          _paint,
        )
        ..drawLine(
          Offset(cx + arm * 0.7, cy + arm * 0.7),
          Offset(cx + gap * 0.7, cy + gap * 0.7),
          _paint,
        );
    } else if (isRecentFire) {
      // Fire flash: crosshair expands briefly.
      final expand = timeSinceFire / 0.15;
      color = Color.fromRGBO(180, 132, 255, pulse);
      gap = 6 + expand * 6;
      arm = 14 + expand * 4;
      strokeW = 2;
    } else {
      color = Color.fromRGBO(113, 50, 245, pulse);
      gap = 6;
      arm = 14;
      strokeW = 1.5;
    }

    _paint
      ..color = color
      ..strokeWidth = strokeW;
    canvas
      ..drawLine(Offset(cx - arm, cy), Offset(cx - gap, cy), _paint)
      ..drawLine(Offset(cx + gap, cy), Offset(cx + arm, cy), _paint)
      ..drawLine(Offset(cx, cy - arm), Offset(cx, cy - gap), _paint)
      ..drawLine(Offset(cx, cy + gap), Offset(cx, cy + arm), _paint);

    _paint.color = color.withValues(alpha: pulse * 0.6);
    canvas.drawCircle(Offset(cx, cy), 1.5, _paint);
  }

  void _drawWeapon(Canvas canvas, double w, double h) {
    final gunCx = w / 2 + 60 + weaponSway;
    final timeSinceFire = time - lastFireTime;
    final kickBack =
        timeSinceFire < 0.1 ? (1.0 - timeSinceFire / 0.1) * 25.0 : 0.0;
    final baseY = h + kickBack - weaponBob;

    // Muzzle flash — multi-layered.
    if (timeSinceFire < 0.1) {
      final flashT = timeSinceFire / 0.1;
      final flashAlpha = 1.0 - flashT;

      // Screen-wide glow.
      _paint.color = Color.fromRGBO(180, 130, 255, flashAlpha * 0.08);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _paint);

      // Outer flash.
      _paint.color = Color.fromRGBO(255, 160, 50, flashAlpha * 0.6);
      canvas.drawCircle(
        Offset(gunCx, baseY - 155),
        35 * flashAlpha,
        _paint,
      );
      // Mid flash.
      _paint.color = Color.fromRGBO(255, 220, 130, flashAlpha * 0.7);
      canvas.drawCircle(
        Offset(gunCx, baseY - 155),
        18 * flashAlpha,
        _paint,
      );
      // Core flash.
      _paint.color = Color.fromRGBO(255, 255, 240, flashAlpha * 0.8);
      canvas.drawCircle(
        Offset(gunCx, baseY - 155),
        8 * flashAlpha,
        _paint,
      );
    }

    // Gun body — angular energy rifle shape.
    _gunPath
      ..reset()
      // Grip base.
      ..moveTo(gunCx - 22, baseY)
      ..lineTo(gunCx - 28, baseY - 20)
      // Trigger guard.
      ..lineTo(gunCx - 30, baseY - 45)
      ..lineTo(gunCx - 26, baseY - 55)
      // Receiver.
      ..lineTo(gunCx - 22, baseY - 80)
      ..lineTo(gunCx - 18, baseY - 100)
      // Barrel.
      ..lineTo(gunCx - 10, baseY - 130)
      ..lineTo(gunCx - 6, baseY - 150)
      ..lineTo(gunCx + 6, baseY - 150)
      ..lineTo(gunCx + 10, baseY - 130)
      // Right side receiver.
      ..lineTo(gunCx + 18, baseY - 100)
      ..lineTo(gunCx + 22, baseY - 80)
      ..lineTo(gunCx + 26, baseY - 55)
      ..lineTo(gunCx + 30, baseY - 45)
      ..lineTo(gunCx + 28, baseY - 20)
      ..lineTo(gunCx + 22, baseY)
      ..close();

    // Gun fill — dark with subtle gradient feel.
    _paint
      ..color = const Color(0xFF12101E)
      ..style = PaintingStyle.fill;
    canvas.drawPath(_gunPath, _paint);

    // Gun inner panel (slightly lighter).
    _detailPath
      ..reset()
      ..moveTo(gunCx - 16, baseY - 50)
      ..lineTo(gunCx - 14, baseY - 95)
      ..lineTo(gunCx + 14, baseY - 95)
      ..lineTo(gunCx + 16, baseY - 50)
      ..close();
    _paint.color = const Color(0xFF1E1A2E);
    canvas.drawPath(_detailPath, _paint);

    // Neon trim outline.
    _paint
      ..color = const Color(0xFFB484FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(_gunPath, _paint);
    _paint.style = PaintingStyle.fill;

    // Energy coils (glowing lines on barrel).
    final coilPulse = 0.5 + 0.5 * sin(time * 8);
    _paint
      ..color = Color.fromRGBO(113, 50, 245, 0.4 + coilPulse * 0.3)
      ..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      final cy = baseY - 105 - i * 12.0;
      canvas.drawLine(
        Offset(gunCx - 12 + i * 1.0, cy),
        Offset(gunCx + 12 - i * 1.0, cy),
        _paint,
      );
    }

    // Barrel core glow.
    final barrelPulse = 0.5 + 0.5 * sin(time * 6);
    _paint.color = Color.fromRGBO(180, 132, 255, barrelPulse * 0.8);
    canvas.drawCircle(Offset(gunCx, baseY - 150), 4, _paint);
    _paint.color = Color.fromRGBO(255, 255, 255, barrelPulse * 0.4);
    canvas.drawCircle(Offset(gunCx, baseY - 150), 2, _paint);

    // Grip detail.
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.2)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final gy = baseY - 10 - i * 8.0;
      canvas.drawLine(
        Offset(gunCx - 15, gy),
        Offset(gunCx + 15, gy),
        _paint,
      );
    }

    // Side rails.
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    canvas
      ..drawLine(
        Offset(gunCx - 20, baseY - 55),
        Offset(gunCx - 16, baseY - 95),
        _paint,
      )
      ..drawLine(
        Offset(gunCx + 20, baseY - 55),
        Offset(gunCx + 16, baseY - 95),
        _paint,
      );
  }

  void _drawHealthBar(Canvas canvas, double w) {
    const left = 20.0;
    const top = 20.0;
    const barW = 180.0;
    const barH = 14.0;

    // Background.
    _paint.color = const Color(0xBB0A0A0F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(left - 3, top - 3, barW + 6, barH + 6),
        const Radius.circular(4),
      ),
      _paint,
    );

    // Border.
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(left - 3, top - 3, barW + 6, barH + 6),
        const Radius.circular(4),
      ),
      _paint,
    );
    _paint.style = PaintingStyle.fill;

    final frac = (health / maxHealth).clamp(0.0, 1.0);
    Color barColor;
    if (frac > 0.5) {
      barColor = Color.lerp(
        const Color(0xFFFFAA00),
        const Color(0xFF00FF88),
        (frac - 0.5) * 2,
      )!;
    } else {
      barColor = Color.lerp(
        const Color(0xFFFF2244),
        const Color(0xFFFFAA00),
        frac * 2,
      )!;
    }

    // Fill glow behind bar.
    _paint.color = barColor.withValues(alpha: 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barW * frac, barH),
        const Radius.circular(3),
      ),
      _paint,
    );

    // Fill.
    _paint.color = barColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barW * frac, barH),
        const Radius.circular(3),
      ),
      _paint,
    );

    // Low health pulse.
    if (frac < 0.3) {
      final pulse = sin(time * 6) * 0.5 + 0.5;
      _paint.color = barColor.withValues(alpha: pulse * 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(left - 3, top - 3, barW + 6, barH + 6),
          const Radius.circular(4),
        ),
        _paint,
      );
    }

    // Health number.
    _healthText
      ..text = TextSpan(
        text: '$health',
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      )
      ..layout()
      ..paint(canvas, const Offset(left + barW + 10, top - 1));
  }

  void _drawAmmoCounter(Canvas canvas, double w, double h) {
    final cx = w / 2 + 60;
    final y = h - 28;

    final ammoColor = ammo > 30
        ? const Color(0xFF00FFE5)
        : ammo > 10
            ? const Color(0xFFFFAA00)
            : const Color(0xFFFF2244);

    // Ammo pips (small rectangles representing magazine).
    const pipW = 3.0;
    const pipH = 8.0;
    const pipGap = 2.0;
    final totalPips = (ammo / 5).ceil().clamp(0, 20);
    final pipsStartX = cx - (totalPips * (pipW + pipGap)) / 2;
    for (var i = 0; i < totalPips; i++) {
      _paint.color = ammoColor.withValues(alpha: 0.7);
      canvas.drawRect(
        Rect.fromLTWH(
          pipsStartX + i * (pipW + pipGap),
          y - pipH - 4,
          pipW,
          pipH,
        ),
        _paint,
      );
    }

    _ammoText
      ..text = TextSpan(
        text: '$ammo',
        style: TextStyle(
          color: ammoColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      )
      ..layout()
      ..paint(canvas, Offset(cx - _ammoText.width / 2, y));
  }

  void _drawKillCounter(Canvas canvas, double w) {
    _killsText
      ..text = TextSpan(
        text: 'KILLS $kills/$totalEnemies',
        style: const TextStyle(
          color: Color(0xFFFF9A76),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          letterSpacing: 1,
        ),
      )
      ..layout()
      ..paint(canvas, Offset(w - _killsText.width - 20, 22));
  }

  void _drawGameOverlay(Canvas canvas, double w, double h) {
    _paint.color = const Color(0xCC000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _paint);

    final isDead = phase == _GamePhase.dead;

    // Glitch lines for dead state.
    if (isDead) {
      _paint
        ..color = const Color(0xFFFF2244).withValues(alpha: 0.1)
        ..strokeWidth = 2;
      for (var i = 0; i < 8; i++) {
        final gy = h * 0.2 + i * h * 0.08;
        final offset = sin(time * 10 + i) * 30;
        canvas.drawLine(
          Offset(offset, gy),
          Offset(w + offset, gy),
          _paint,
        );
      }
    }

    _statusText
      ..text = TextSpan(
        text: isDead ? 'SISTEMA OFFLINE' : 'ZONA LIMPA',
        style: TextStyle(
          color: isDead ? const Color(0xFFFF2244) : const Color(0xFF00FF88),
          fontSize: 42,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          letterSpacing: 6,
        ),
      )
      ..layout()
      ..paint(
        canvas,
        Offset((w - _statusText.width) / 2, h / 2 - 50),
      );

    _subtitleText
      ..text = TextSpan(
        text: isDead
            ? 'Pressione R para reiniciar'
            : '$kills inimigos eliminados · R para jogar novamente',
        style: const TextStyle(
          color: Color(0xFF9497A9),
          fontSize: 15,
          fontFamily: 'monospace',
          letterSpacing: 1,
        ),
      )
      ..layout()
      ..paint(
        canvas,
        Offset((w - _subtitleText.width) / 2, h / 2 + 10),
      );
  }

  @override
  bool shouldRepaint(_HudPainter old) =>
      (time - old.time).abs() > 0.03 ||
      health != old.health ||
      ammo != old.ammo ||
      kills != old.kills ||
      phase != old.phase;
}

// ---------------------------------------------------------------------------
// Minimap painter — top-down view with enemy dots.
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
    required this.enemies,
    required this.time,
  });

  final double playerX;
  final double playerY;
  final double playerAngle;
  final List<List<int>> map;
  final Map<int, Color> wallColors;
  final Map<int, Color> neonColors;
  final double fov;
  final List<_Enemy> enemies;
  final double time;

  final _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final rows = map.length;
    final cols = map[0].length;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Background.
    final bgRect = Offset.zero & size;
    _paint.color = const Color(0xDD0A0A0F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      _paint,
    );
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      _paint,
    );
    _paint.style = PaintingStyle.fill;

    // Walls.
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final cell = map[y][x];
        if (cell == 0) continue;
        final neon = neonColors[cell] ?? const Color(0xFFB484FF);
        _paint.color = neon.withValues(alpha: 0.5);
        canvas.drawRect(
          Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
          _paint,
        );
      }
    }

    // Grid.
    _paint
      ..color = const Color(0xFF7132F5).withValues(alpha: 0.06)
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

    // Enemies.
    for (final e in enemies) {
      final ex = e.x * cellW;
      final ey = e.y * cellH;
      if (e.alive) {
        final pulse = 0.6 + 0.4 * sin(time * 3);
        // Glow ring.
        _paint.color = const Color(0xFFFF4444).withValues(alpha: 0.2);
        canvas.drawCircle(Offset(ex, ey), 5, _paint);
        // Solid dot.
        _paint.color = Color.fromRGBO(255, 60, 60, pulse);
        canvas.drawCircle(Offset(ex, ey), 3, _paint);
      } else if (e.deathTime > 0 && time - e.deathTime < 1.5) {
        final fade = 1.0 - (time - e.deathTime) / 1.5;
        _paint.color = Color.fromRGBO(100, 100, 100, fade * 0.4);
        canvas.drawCircle(Offset(ex, ey), 2, _paint);
      }
    }

    // FOV cone.
    final px = playerX * cellW;
    final py = playerY * cellH;
    const coneLen = 28.0;

    final leftAngle = playerAngle - fov / 2;
    final rightAngle = playerAngle + fov / 2;

    _paint.color = const Color(0xFF7132F5).withValues(alpha: 0.15);

    final path = Path()
      ..moveTo(px, py)
      ..lineTo(px + cos(leftAngle) * coneLen, py + sin(leftAngle) * coneLen)
      ..lineTo(
        px + cos(rightAngle) * coneLen,
        py + sin(rightAngle) * coneLen,
      )
      ..close();
    canvas.drawPath(path, _paint);

    // Player dot.
    _paint.color = const Color(0xFF7132F5).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(px, py), 6, _paint);
    _paint.color = const Color(0xFFB484FF);
    canvas.drawCircle(Offset(px, py), 3, _paint);

    // Direction line.
    _paint
      ..color = const Color(0xFFB484FF).withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(px, py),
      Offset(px + cos(playerAngle) * 12, py + sin(playerAngle) * 12),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_MinimapPainter old) =>
      playerX != old.playerX ||
      playerY != old.playerY ||
      playerAngle != old.playerAngle ||
      (time - old.time).abs() > 0.1;
}
