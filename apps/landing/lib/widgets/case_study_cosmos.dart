import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';

/// Specs const dos corpos celestes desenhados no case study. Separa a
/// DATA (paletas, ancoras, seeds) da arvore de widgets — mesmo padrao
/// de `hero_planets_catalog.dart`. Os `CosmosField` em
/// `case_study_section.dart` apenas referenciam estas listas.
abstract final class CaseStudyCosmos {
  /// Cena principal do bloco hero: planeta com anel + lua, planeta
  /// speckled vermelho e planeta hemispheres gelado.
  static const List<CosmosPlanet> heroPlanets = [
    CosmosPlanet(
      id: 'case-study-hero',
      canvasAnchor: Offset(0.50, 0.45),
      radiusPixels: 48,
      pattern: PlanetPattern.bands,
      seed: 42,
      palette: [
        Color(0xFF0A0420),
        Color(0xFF2E1466),
        Color(0xFF6B40E0),
        Color(0xFFB89BFF),
        Color(0xFFE6DCFF),
      ],
      ring: PlanetRing(
        innerRadiusPixels: 62,
        outerRadiusPixels: 82,
        color: Color(0xCC9D6BFF),
        tiltY: 0.22,
      ),
      moon: PlanetMoon(
        orbitRadiusPixels: 70,
        moonRadiusPixels: 6,
        color: Color(0xFFE6DCFF),
        phaseOffset: 0.3,
      ),
    ),
    CosmosPlanet(
      id: 'case-study-small',
      canvasAnchor: Offset(0.22, 0.70),
      radiusPixels: 18,
      pattern: PlanetPattern.speckled,
      seed: 7,
      palette: [
        Color(0xFF1A0008),
        Color(0xFF7A0E2A),
        Color(0xFFFF1F44),
        Color(0xFFFF6679),
        Color(0xFFFFDADE),
      ],
    ),
    CosmosPlanet(
      id: 'case-study-ice',
      canvasAnchor: Offset(0.80, 0.25),
      radiusPixels: 14,
      pattern: PlanetPattern.hemispheres,
      seed: 11,
      palette: [
        Color(0xFF010E1A),
        Color(0xFF0A446A),
        Color(0xFF0AC4FF),
        Color(0xFF7FE9FF),
        Color(0xFFE8FBFF),
      ],
    ),
  ];

  static const List<CosmosNebula> heroNebulas = [
    CosmosNebula(
      canvasAnchor: Offset(0.75, 0.60),
      radiusPixels: 70,
      color: Color(0xFFFF2D95),
      density: 0.5,
      seed: 3,
    ),
  ];

  static const List<CosmosPulsar> heroPulsars = [
    CosmosPulsar(
      canvasAnchor: Offset(0.15, 0.30),
      coreColor: Color(0xFF0AC4FF),
      beamColor: Color(0xFF0AC4FF),
      beamLengthPixels: 35,
      beamWidthRadians: 0.08,
      phaseOffset: 0.2,
      seed: 5,
    ),
  ];

  /// Card "planeta em 6 camadas" — um planeta com anel destacando as
  /// camadas de pintura.
  static const List<CosmosPlanet> layersPlanets = [
    CosmosPlanet(
      id: 'layers-demo',
      canvasAnchor: Offset(0.50, 0.50),
      radiusPixels: 42,
      pattern: PlanetPattern.bands,
      seed: 211,
      palette: [
        Color(0xFF0A0420),
        Color(0xFF2E1466),
        Color(0xFF6B40E0),
        Color(0xFFB89BFF),
        Color(0xFFE6DCFF),
      ],
      ring: PlanetRing(
        innerRadiusPixels: 56,
        outerRadiusPixels: 74,
        color: Color(0xCC9D6BFF),
        tiltY: 0.22,
      ),
    ),
  ];

  /// Card "galaxia espiral".
  static const List<CosmosGalaxy> spiralGalaxies = [
    CosmosGalaxy(
      canvasAnchor: Offset(0.50, 0.50),
      radiusPixels: 60,
      coreColor: Color(0xFFFFE0B2),
      armColor: Color(0xFF9D6BFF),
      armCount: 3,
      tiltY: 0.55,
      rotation: 0.3,
      dustCount: 200,
      seed: 42,
    ),
  ];
}
