import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:feature_about/src/presentation/balloon_popup.dart';
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

  /// Criatura espacial por dominio — cada dominio vira um bicho/objeto
  /// distinto (alien, nave, beholder, meteoro, satelite) pra deixar o mapa
  /// variado e divertido. retail (end-to-end) recebe o beholder, o corpo de
  /// maior destaque.
  static const Map<String, SpaceCreature> _creatures = {
    'fintech': SpaceCreature.satellite,
    'public_services': SpaceCreature.alien,
    'platform': SpaceCreature.ufo,
    'sanitation': SpaceCreature.meteor,
    'retail': SpaceCreature.beholder,
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
    // Abre um balao por padrao pra deixar a interacao obvia — prefere o
    // dominio end-to-end (retail, planeta de maior destaque); senao, o
    // primeiro disponivel.
    if (widget.domains.isNotEmpty) {
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
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        // Desktop ~16:9. Mobile mais baixo que largo (era quase quadrado
        // 0.95 e comia tela demais) — mantem planetas + balao legiveis
        // sem virar bloco gigante.
        final height = isMobile ? width * 0.82 : width * 0.55;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Tap em area vazia fecha o balao.
          onTap: () => setState(() => _selectedId = null),
          child: SizedBox(
            width: width,
            height: height,
            child: _Scene(
              domains: widget.domains,
              creatures: DomainConstellation._creatures,
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
    required this.creatures,
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
  final Map<String, SpaceCreature> creatures;
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
    final creature = creatures[d.id];
    if (creature == null) return const SizedBox.shrink();
    // Web (desktop) aumenta os planetas consideravelmente — a cena e
    // ~16:9 e comportava planetas maiores; mobile mantem o tamanho pra
    // nao estourar o quadro mais alto.
    final baseSize =
        (d.isEndToEnd ? 86.0 : 70.0) *
        context.responsive<double>(mobile: 1, desktop: 1.7);
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
            creature: creature,
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
    required this.creature,
    required this.isActive,
    required this.ambient,
  });

  final SpaceCreature creature;
  final bool isActive;
  final AnimationController ambient;

  @override
  Widget build(BuildContext context) {
    final glow = context.colors.primary;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: ambient,
        // Criatura desenhada em CustomPainter; quando ativo/hover, ganha um
        // halo neon pulsante atras — destaque sem deformar.
        child: SpaceCreatureView(creature: creature),
        builder: (context, child) {
          if (!isActive) return child!;
          final pulse = 0.55 + 0.45 * math.sin(ambient.value * math.pi * 2);
          return DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.5 * pulse),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
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
