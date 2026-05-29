import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:feature_about/src/presentation/balloon_popup.dart';
import 'package:feature_about/src/presentation/painters/domain_planet_painter.dart';
import 'package:flutter/material.dart';

/// Mapa de dominios em forma de **constelacao interativa**. Substitui
/// o `DomainsGrid` (cards estaticos). Cada dominio agora e um
/// **planeta unico** (paleta + pattern + ring opcional) posicionado
/// num plano normalizado 0..1; metodologia compartilhada vira
/// aresta. Tap em um planeta abre um **balao popup** ancorado ao
/// planeta — nao usa Dialog/rota nova.
///
/// Atras: `ConstellationPainter` do pacote `animations` renderiza
/// constelacoes ambient (Cruzeiro do Sul, Orion, Triangulo) com
/// twinkle leve — atmosfera de "mapa estelar de carreira". Os
/// planetas dos dominios sao desenhados em camada propria por cima.
class DomainConstellation extends StatefulWidget {
  const DomainConstellation({required this.domains, super.key});

  final List<DomainHighlight> domains;

  /// Posicoes normalizadas (0..1) por id de dominio.
  static const Map<String, Offset> _positions = {
    'fintech': Offset(0.82, 0.22),
    'public_services': Offset(0.18, 0.18),
    'platform': Offset(0.32, 0.58),
    'sanitation': Offset(0.70, 0.62),
    'retail': Offset(0.50, 0.88),
  };

  /// Arestas entre dominios — metodologia/contexto compartilhado.
  static const List<(String, String)> _edges = [
    ('retail', 'platform'),
    ('retail', 'sanitation'),
    ('platform', 'public_services'),
    ('platform', 'fintech'),
    ('sanitation', 'fintech'),
  ];

  /// Specs visuais por dominio: paleta de 5 cores + pattern + ring
  /// opcional. Cada dominio recebe uma identidade cromatica
  /// distinta, costurada com a paleta da landing.
  static const Map<String, DomainPlanetSpec> _planetSpecs = {
    'fintech': DomainPlanetSpec(
      palette: [
        Color(0xFF020B26),
        Color(0xFF0A2B70),
        Color(0xFF2D7FFF),
        Color(0xFF7CB8FF),
        Color(0xFFE0EEFF),
      ],
      pattern: DomainPlanetPattern.bands,
      seed: 17,
    ),
    'public_services': DomainPlanetSpec(
      palette: [
        Color(0xFF1F1505),
        Color(0xFF6A4A0A),
        Color(0xFFE6C25A),
        Color(0xFFFFE8A5),
        Color(0xFFFFF7DC),
      ],
      pattern: DomainPlanetPattern.speckled,
      seed: 31,
    ),
    'platform': DomainPlanetSpec(
      palette: [
        Color(0xFF120428),
        Color(0xFF391066),
        Color(0xFF9D3FFF),
        Color(0xFFD58BFF),
        Color(0xFFF0DCFF),
      ],
      pattern: DomainPlanetPattern.hemispheres,
      seed: 47,
    ),
    'sanitation': DomainPlanetSpec(
      palette: [
        Color(0xFF02100E),
        Color(0xFF0A4A3D),
        Color(0xFF1FE5B5),
        Color(0xFFA5FFE5),
        Color(0xFFE9FFF8),
      ],
      pattern: DomainPlanetPattern.bands,
      seed: 53,
    ),
    'retail': DomainPlanetSpec(
      palette: [
        Color(0xFF2A0610),
        Color(0xFF7A1A30),
        Color(0xFFFF4E78),
        Color(0xFFFFA0B8),
        Color(0xFFFFE0E8),
      ],
      pattern: DomainPlanetPattern.speckled,
      ring: 0.28,
      seed: 89,
    ),
  };

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
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        // Cena em aspect ratio ~16:9 desktop, ~4:3 mobile pra
        // acomodar planetas + balao sem cortar.
        final height = isMobile ? width * 0.95 : width * 0.55;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Tap em area vazia fecha o balao.
          onTap: () => setState(() => _selectedId = null),
          child: SizedBox(
            width: width,
            height: height,
            child: _Scene(
              domains: widget.domains,
              specs: DomainConstellation._planetSpecs,
              positions: DomainConstellation._positions,
              edges: DomainConstellation._edges,
              selectedId: _selectedId,
              hoverId: _hoverId,
              selectedDomain: _selectedId == null
                  ? null
                  : _domainById(_selectedId!),
              ambient: _ambient,
              onPick: (id) =>
                  setState(() => _selectedId = id == _selectedId ? null : id),
              onHover: (id) => setState(() => _hoverId = id),
            ),
          ),
        );
      },
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({
    required this.domains,
    required this.specs,
    required this.positions,
    required this.edges,
    required this.selectedId,
    required this.hoverId,
    required this.selectedDomain,
    required this.ambient,
    required this.onPick,
    required this.onHover,
  });

  final List<DomainHighlight> domains;
  final Map<String, DomainPlanetSpec> specs;
  final Map<String, Offset> positions;
  final List<(String, String)> edges;
  final String? selectedId;
  final String? hoverId;
  final DomainHighlight? selectedDomain;
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.surface, colors.background],
          ),
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final sceneSize = Size(c.maxWidth, c.maxHeight);
            return Stack(
              children: [
                // Ambient backdrop: constelacoes reais com twinkle leve.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: ambient,
                    builder: (_, _) => CustomPaint(
                      painter: ConstellationPainter(
                        tick: ambient.value,
                        starColor: colors.onSurfaceMuted.withValues(
                          alpha: 0.35,
                        ),
                        linkColor: colors.onSurfaceMuted.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                  ),
                ),
                // Camada de arestas entre planetas.
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: ambient,
                    builder: (_, _) => CustomPaint(
                      painter: _DomainEdgesPainter(
                        positions: positions,
                        edges: edges,
                        activeId: activeId,
                        tick: ambient.value,
                        baseColor: colors.primary,
                      ),
                    ),
                  ),
                ),
                // Planetas clicaveis.
                for (final d in domains) _buildPlanet(context, d, sceneSize),
                // Balao popup do dominio selecionado.
                if (selectedDomain != null)
                  BalloonPopup(
                    key: ValueKey('balloon-${selectedDomain!.id}'),
                    domain: selectedDomain!,
                    planetCenter: _planetCenterFor(selectedId!, sceneSize),
                    sceneSize: sceneSize,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Offset _planetCenterFor(String id, Size sceneSize) {
    final p = positions[id] ?? const Offset(0.5, 0.5);
    return Offset(p.dx * sceneSize.width, p.dy * sceneSize.height);
  }

  Widget _buildPlanet(BuildContext context, DomainHighlight d, Size sceneSize) {
    final pos = positions[d.id] ?? const Offset(0.5, 0.5);
    final isActive = (hoverId ?? selectedId) == d.id;
    final spec = specs[d.id];
    if (spec == null) return const SizedBox.shrink();
    final baseSize = d.isEndToEnd ? 86.0 : 70.0;
    final boxSize = baseSize + (isActive ? 14 : 0);
    final center = Offset(pos.dx * sceneSize.width, pos.dy * sceneSize.height);
    return Positioned(
      left: center.dx - boxSize / 2,
      top: center.dy - boxSize / 2,
      width: boxSize,
      height: boxSize,
      child: MouseRegion(
        onEnter: (_) => onHover(d.id),
        onExit: (_) => onHover(null),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          // Marca tap como handled pra nao propagar e fechar o balao.
          behavior: HitTestBehavior.opaque,
          onTap: () => onPick(d.id),
          child: _DomainPlanet(
            spec: spec,
            isActive: isActive,
            ambient: ambient,
          ),
        ),
      ),
    );
  }
}

class _DomainPlanet extends StatelessWidget {
  const _DomainPlanet({
    required this.spec,
    required this.isActive,
    required this.ambient,
  });

  final DomainPlanetSpec spec;
  final bool isActive;
  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: ambient,
        builder: (_, _) {
          final pulse = 0.8 + 0.2 * math.sin(ambient.value * math.pi * 2);
          return CustomPaint(
            painter: DomainPlanetPainter(
              spec: spec,
              isActive: isActive,
              pulse: pulse,
            ),
          );
        },
      ),
    );
  }
}

class _DomainEdgesPainter extends CustomPainter {
  _DomainEdgesPainter({
    required this.positions,
    required this.edges,
    required this.activeId,
    required this.tick,
    required this.baseColor,
  });

  final Map<String, Offset> positions;
  final List<(String, String)> edges;
  final String? activeId;
  final double tick;
  final Color baseColor;

  Offset _pos(String id, Size size) {
    final p = positions[id] ?? const Offset(0.5, 0.5);
    return Offset(p.dx * size.width, p.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final (a, b) in edges) {
      final isHot = activeId != null && (a == activeId || b == activeId);
      edgePaint
        ..color = baseColor.withValues(alpha: isHot ? 0.55 : 0.18)
        ..strokeWidth = isHot ? 1.4 : 0.8;
      final from = _pos(a, size);
      final to = _pos(b, size);
      canvas.drawLine(from, to, edgePaint);

      // Particula percorrendo a aresta ativa — sugere fluxo de
      // metodologia entre dominios.
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
