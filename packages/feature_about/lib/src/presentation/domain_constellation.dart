import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:flutter/material.dart';

/// Mapa de dominios em forma de **constelacao interativa**. Substitui
/// o `DomainsGrid` (cards estaticos). Cada dominio e um no luminoso
/// posicionado num plano 0..1; metodologia que se sobrepoe entre
/// dominios vira aresta. Hover/tap destaca o no, escurece os outros
/// e revela uma nota lateral com o blurb.
///
/// Atras: `ConstellationPainter` (do pacote `animations`) renderiza
/// constelacoes ambient (Cruzeiro do Sul, Orion, Triangulo) com
/// twinkle leve — atmosfera de "mapa estelar de carreira". Os nos
/// dos dominios sao desenhados em camada propria por cima.
class DomainConstellation extends StatefulWidget {
  const DomainConstellation({required this.domains, super.key});

  final List<DomainHighlight> domains;

  /// Posicoes normalizadas (0..1) por id de dominio. Layout pensado
  /// pro catalogo atual — fintech canto sup. direito (atual), varejo
  /// embaixo no centro (origem), demais distribuidos.
  static const Map<String, Offset> _positions = {
    'fintech': Offset(0.80, 0.22),
    'public_services': Offset(0.20, 0.18),
    'platform': Offset(0.32, 0.58),
    'sanitation': Offset(0.70, 0.62),
    'retail': Offset(0.50, 0.90),
  };

  /// Arestas entre dominios — metodologia/contexto compartilhado.
  static const List<(String, String)> _edges = [
    ('retail', 'platform'),
    ('retail', 'sanitation'),
    ('platform', 'public_services'),
    ('platform', 'fintech'),
    ('sanitation', 'fintech'),
  ];

  @override
  State<DomainConstellation> createState() => _DomainConstellationState();
}

class _DomainConstellationState extends State<DomainConstellation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient;
  String? _selectedId;
  String? _hoverId;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    if (widget.domains.isNotEmpty) {
      // Default focus em 'retail' — origin da carreira, end-to-end.
      _selectedId = widget.domains
          .firstWhere(
            (d) => d.id == 'retail',
            orElse: () => widget.domains.first,
          )
          .id;
    }
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  DomainHighlight? _domainById(String id) {
    for (final d in widget.domains) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.domains.isEmpty) return const SizedBox.shrink();
    final isMobile = context.isMobile;
    final selected = _selectedId == null ? null : _domainById(_selectedId!);
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final sceneHeight = isMobile ? width * 0.85 : width * 0.42;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: sceneHeight,
              child: _Scene(
                domains: widget.domains,
                selectedId: _selectedId,
                hoverId: _hoverId,
                ambient: _ambient,
                onPick: (id) => setState(() => _selectedId = id),
                onHover: (id) => setState(() => _hoverId = id),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SidePanel(domain: selected, isMobile: isMobile),
          ],
        );
      },
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({
    required this.domains,
    required this.selectedId,
    required this.hoverId,
    required this.ambient,
    required this.onPick,
    required this.onHover,
  });

  final List<DomainHighlight> domains;
  final String? selectedId;
  final String? hoverId;
  final AnimationController ambient;
  final ValueChanged<String> onPick;
  final ValueChanged<String?> onHover;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeId = hoverId ?? selectedId;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Stack(
          children: [
            // Ambient backdrop: constelacoes reais com twinkle leve.
            Positioned.fill(
              child: AnimatedBuilder(
                animation: ambient,
                builder: (_, _) => CustomPaint(
                  painter: ConstellationPainter(
                    tick: ambient.value,
                    starColor: colors.onSurfaceMuted.withValues(alpha: 0.35),
                    linkColor: colors.onSurfaceMuted.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            // Camada de arestas dos dominios.
            Positioned.fill(
              child: AnimatedBuilder(
                animation: ambient,
                builder: (_, _) => CustomPaint(
                  painter: _DomainEdgesPainter(
                    domains: domains,
                    activeId: activeId,
                    tick: ambient.value,
                    baseColor: colors.primary,
                  ),
                ),
              ),
            ),
            // Nos clicaveis.
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                return Stack(
                  children: [
                    for (final d in domains) _buildNode(context, d, w, h),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(
    BuildContext context,
    DomainHighlight d,
    double w,
    double h,
  ) {
    final pos = DomainConstellation._positions[d.id] ?? const Offset(0.5, 0.5);
    final isActive = (hoverId ?? selectedId) == d.id;
    final isEndToEnd = d.isEndToEnd;
    final baseSize = isEndToEnd ? 72.0 : 60.0;
    final boxSize = baseSize + (isActive ? 12 : 0);
    return Positioned(
      left: pos.dx * w - boxSize / 2,
      top: pos.dy * h - boxSize / 2,
      width: boxSize,
      height: boxSize,
      child: MouseRegion(
        onEnter: (_) => onHover(d.id),
        onExit: (_) => onHover(null),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onPick(d.id),
          child: _DomainNode(domain: d, isActive: isActive, ambient: ambient),
        ),
      ),
    );
  }
}

class _DomainNode extends StatelessWidget {
  const _DomainNode({
    required this.domain,
    required this.isActive,
    required this.ambient,
  });

  final DomainHighlight domain;
  final bool isActive;
  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: ambient,
      builder: (_, _) {
        // Pulse leve no ambient pra dar vida sem distrair.
        final pulse = 0.85 + 0.15 * math.sin(ambient.value * math.pi * 2);
        return CustomPaint(
          painter: _DomainNodePainter(
            icon: domain.icon,
            color: colors.primary,
            accent: colors.accent,
            mutedColor: colors.onSurfaceMuted,
            surfaceColor: colors.surface,
            isActive: isActive,
            isEndToEnd: domain.isEndToEnd,
            pulse: pulse,
          ),
        );
      },
    );
  }
}

class _DomainNodePainter extends CustomPainter {
  _DomainNodePainter({
    required this.icon,
    required this.color,
    required this.accent,
    required this.mutedColor,
    required this.surfaceColor,
    required this.isActive,
    required this.isEndToEnd,
    required this.pulse,
  });

  final IconData icon;
  final Color color;
  final Color accent;
  final Color mutedColor;
  final Color surfaceColor;
  final bool isActive;
  final bool isEndToEnd;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 6;

    // Glow externo quando ativo.
    if (isActive) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, radius + 8, glowPaint);
    }

    // Anel externo (apenas end-to-end ganha dois aneis).
    if (isEndToEnd) {
      final outerRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: isActive ? 0.7 : 0.45);
      canvas.drawCircle(center, radius + 3, outerRingPaint);
    }

    // Disco central com gradient brand.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 1.6 : 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: isActive ? 1.0 : 0.55),
          accent.withValues(alpha: isActive ? 0.85 : 0.45),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final discPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isActive
          ? color.withValues(alpha: 0.16)
          : surfaceColor.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, discPaint);
    canvas.drawCircle(center, radius, ringPaint);

    // Icone centralizado.
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: radius * 1.05,
          color: isActive ? color : mutedColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DomainNodePainter old) =>
      old.isActive != isActive ||
      old.pulse != pulse ||
      old.color != color ||
      old.accent != accent ||
      old.mutedColor != mutedColor;
}

class _DomainEdgesPainter extends CustomPainter {
  _DomainEdgesPainter({
    required this.domains,
    required this.activeId,
    required this.tick,
    required this.baseColor,
  });

  final List<DomainHighlight> domains;
  final String? activeId;
  final double tick;
  final Color baseColor;

  Offset _pos(String id, Size size) {
    final p = DomainConstellation._positions[id] ?? const Offset(0.5, 0.5);
    return Offset(p.dx * size.width, p.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final (a, b) in DomainConstellation._edges) {
      final isHot = activeId != null && (a == activeId || b == activeId);
      edgePaint
        ..color = baseColor.withValues(alpha: isHot ? 0.55 : 0.18)
        ..strokeWidth = isHot ? 1.4 : 0.8;
      final from = _pos(a, size);
      final to = _pos(b, size);
      canvas.drawLine(from, to, edgePaint);

      // Particula percorrendo a aresta quando hot — sugere fluxo de
      // metodologia.
      if (isHot) {
        final t = (tick * 0.8) % 1;
        final mid = Offset.lerp(from, to, t)!;
        final particlePaint = Paint()
          ..color = baseColor.withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
        canvas.drawCircle(mid, 2.6, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DomainEdgesPainter old) =>
      old.activeId != activeId ||
      old.tick != tick ||
      old.baseColor != baseColor;
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.domain, this.isMobile = false});

  final DomainHighlight? domain;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    if (domain == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          'Toque um nó pra abrir.',
          style: tt.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
        ),
      );
    }
    final d = domain!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(d.id),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surface, colors.primary.withValues(alpha: 0.06)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(d.icon, color: colors.primary, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    d.label,
                    style: tt.titleLarge?.copyWith(color: colors.onSurface),
                  ),
                ),
              ],
            ),
            if (d.isEndToEnd) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.16),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'front end inteiro',
                  style: tt.labelSmall?.copyWith(
                    color: colors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              d.blurb,
              style: tt.bodyMedium?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
