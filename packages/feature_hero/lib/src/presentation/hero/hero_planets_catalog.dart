import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart' show Offset, Color;

/// Catálogo dos corpos celestes do hero: planetas, nebulosas, galáxias,
/// pulsares, cinturões de asteroides e wisps. Cada função entrega a
/// lista pronta pro [CosmosField] consumir, respeitando breakpoint
/// (mobile vs desktop) — desktop espalha mais corpos pra popular wide
/// screens (1920+), mobile mantém set compacto.
///
/// Extraído de `hero_section.dart` (era ~1080 LOC só de listas const);
/// agora vive como módulo dedicado. Mantém a lógica de breakpoint
/// (`isMobile`) intacta.

/// Lista principal de planetas — `colors` é mantido como parâmetro
/// pra futuro tinting paleta-aware (ainda não consumido; placeholder
/// pra extensão sem mudança de assinatura).
List<CosmosPlanet> heroPlanets(
  AppColorScheme colors, {
  required bool isMobile,
}) {
  if (!isMobile) return _heroPlanetsDesktop();
  return const [
    // Grounding anchor mobile — planeta brand-purple posicionado sob
    // o recorte (em mobile a figura stacka full-width no topo da
    // viewport, footprint x ~0.10-0.90, y ~0.05-0.50). canvasAnchor
    // (0.50, 0.52) emerge da base da foto, anel suave + raio menor
    // pra encaixar no aspect mobile.
    CosmosPlanet(
      id: 'grounding-anchor',
      canvasAnchor: Offset(0.50, 0.52),
      radiusPixels: 62,
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
        innerRadiusPixels: 78,
        outerRadiusPixels: 100,
        color: Color(0xCC9D6BFF),
        tiltY: 0.22,
      ),
    ),
    CosmosPlanet(
      id: 'red-giant',
      canvasAnchor: Offset(1.02, -0.08),
      radiusPixels: 150,
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
      id: 'ice-world',
      canvasAnchor: Offset(0.18, 0.25),
      radiusPixels: 32,
      pattern: PlanetPattern.hemispheres,
      seed: 9,
      palette: [
        Color(0xFF010E1A),
        Color(0xFF0A446A),
        Color(0xFF0AC4FF),
        Color(0xFF7FE9FF),
        Color(0xFFE8FBFF),
      ],
      ring: PlanetRing(
        innerRadiusPixels: 44,
        outerRadiusPixels: 62,
        color: Color(0xEE0AE0FF),
        tiltY: 0.28,
      ),
    ),
    CosmosPlanet(
      id: 'magenta-giant',
      canvasAnchor: Offset(0.86, 0.86),
      radiusPixels: 28,
      pattern: PlanetPattern.bands,
      seed: 13,
      palette: [
        Color(0xFF1A0524),
        Color(0xFF5C0F7A),
        Color(0xFFE020F2),
        Color(0xFFFF66F5),
        Color(0xFFFFCFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 40,
        moonRadiusPixels: 4,
        color: Color(0xFFFFFFFF),
        phaseOffset: 0.15,
      ),
    ),
    CosmosPlanet(
      id: 'lime-rocky',
      canvasAnchor: Offset(0.10, 0.82),
      radiusPixels: 14,
      pattern: PlanetPattern.speckled,
      seed: 3,
      palette: [
        Color(0xFF020F08),
        Color(0xFF0A4023),
        Color(0xFF1FFF6E),
        Color(0xFFA5FFC1),
        Color(0xFFE9FFEC),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 24,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFD9),
        phaseOffset: 0.55,
      ),
    ),
    CosmosPlanet(
      id: 'electric-blue',
      canvasAnchor: Offset(0.82, 0.16),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 19,
      palette: [
        Color(0xFF020B26),
        Color(0xFF0A2B70),
        Color(0xFF2D7FFF),
        Color(0xFF7CB8FF),
        Color(0xFFE0EEFF),
      ],
    ),
    CosmosPlanet(
      id: 'violet-rocky',
      canvasAnchor: Offset(0.88, 0.46),
      radiusPixels: 12,
      pattern: PlanetPattern.speckled,
      seed: 17,
      palette: [
        Color(0xFF120428),
        Color(0xFF391066),
        Color(0xFF9D3FFF),
        Color(0xFFD58BFF),
        Color(0xFFF0DCFF),
      ],
    ),
    CosmosPlanet(
      id: 'teal-world',
      canvasAnchor: Offset(0.05, 0.50),
      radiusPixels: 16,
      pattern: PlanetPattern.bands,
      seed: 53,
      palette: [
        Color(0xFF02100E),
        Color(0xFF0A4A3D),
        Color(0xFF1FE5B5),
        Color(0xFFA5FFE5),
        Color(0xFFE9FFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 26,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFF8),
        phaseOffset: 0.3,
      ),
    ),
    CosmosPlanet(
      id: 'amber-dwarf',
      canvasAnchor: Offset(0.04, 0.34),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 61,
      palette: [
        Color(0xFF2A1500),
        Color(0xFF7A4205),
        Color(0xFFFFA82A),
        Color(0xFFFFD58A),
        Color(0xFFFFF1D6),
      ],
    ),
    CosmosPlanet(
      id: 'indigo-rocky',
      canvasAnchor: Offset(0.85, 0.32),
      radiusPixels: 11,
      pattern: PlanetPattern.speckled,
      seed: 73,
      palette: [
        Color(0xFF08081C),
        Color(0xFF1F2280),
        Color(0xFF3F66FF),
        Color(0xFF9BB8FF),
        Color(0xFFE0EBFF),
      ],
    ),
    CosmosPlanet(
      id: 'coral-rose',
      canvasAnchor: Offset(0.03, 0.72),
      radiusPixels: 8,
      pattern: PlanetPattern.bands,
      seed: 83,
      palette: [
        Color(0xFF2A0610),
        Color(0xFF7A1A30),
        Color(0xFFFF4E78),
        Color(0xFFFFA0B8),
        Color(0xFFFFE0E8),
      ],
    ),
  ];
}

List<CosmosPlanet> _heroPlanetsDesktop() {
  return const [
    CosmosPlanet(
      id: 'grounding-anchor',
      canvasAnchor: Offset(0.30, 0.94),
      radiusPixels: 78,
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
        innerRadiusPixels: 96,
        outerRadiusPixels: 122,
        color: Color(0xCC9D6BFF),
        tiltY: 0.20,
      ),
    ),
    CosmosPlanet(
      id: 'red-giant',
      canvasAnchor: Offset(1.02, -0.08),
      radiusPixels: 150,
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
      id: 'ice-world',
      canvasAnchor: Offset(0.12, 0.22),
      radiusPixels: 32,
      pattern: PlanetPattern.hemispheres,
      seed: 9,
      palette: [
        Color(0xFF010E1A),
        Color(0xFF0A446A),
        Color(0xFF0AC4FF),
        Color(0xFF7FE9FF),
        Color(0xFFE8FBFF),
      ],
      ring: PlanetRing(
        innerRadiusPixels: 44,
        outerRadiusPixels: 62,
        color: Color(0xEE0AE0FF),
        tiltY: 0.28,
      ),
    ),
    CosmosPlanet(
      id: 'magenta-giant',
      canvasAnchor: Offset(0.88, 0.86),
      radiusPixels: 28,
      pattern: PlanetPattern.bands,
      seed: 13,
      palette: [
        Color(0xFF1A0524),
        Color(0xFF5C0F7A),
        Color(0xFFE020F2),
        Color(0xFFFF66F5),
        Color(0xFFFFCFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 40,
        moonRadiusPixels: 4,
        color: Color(0xFFFFFFFF),
        phaseOffset: 0.15,
      ),
    ),
    CosmosPlanet(
      id: 'lime-rocky',
      canvasAnchor: Offset(0.05, 0.84),
      radiusPixels: 14,
      pattern: PlanetPattern.speckled,
      seed: 3,
      palette: [
        Color(0xFF020F08),
        Color(0xFF0A4023),
        Color(0xFF1FFF6E),
        Color(0xFFA5FFC1),
        Color(0xFFE9FFEC),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 24,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFD9),
        phaseOffset: 0.55,
      ),
    ),
    CosmosPlanet(
      id: 'electric-blue',
      canvasAnchor: Offset(0.84, 0.14),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 19,
      palette: [
        Color(0xFF020B26),
        Color(0xFF0A2B70),
        Color(0xFF2D7FFF),
        Color(0xFF7CB8FF),
        Color(0xFFE0EEFF),
      ],
    ),
    CosmosPlanet(
      id: 'violet-rocky',
      canvasAnchor: Offset(0.92, 0.46),
      radiusPixels: 12,
      pattern: PlanetPattern.speckled,
      seed: 17,
      palette: [
        Color(0xFF120428),
        Color(0xFF391066),
        Color(0xFF9D3FFF),
        Color(0xFFD58BFF),
        Color(0xFFF0DCFF),
      ],
    ),
    CosmosPlanet(
      id: 'teal-world',
      canvasAnchor: Offset(0.03, 0.48),
      radiusPixels: 16,
      pattern: PlanetPattern.bands,
      seed: 53,
      palette: [
        Color(0xFF02100E),
        Color(0xFF0A4A3D),
        Color(0xFF1FE5B5),
        Color(0xFFA5FFE5),
        Color(0xFFE9FFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 26,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFF8),
        phaseOffset: 0.3,
      ),
    ),
    CosmosPlanet(
      id: 'amber-dwarf',
      canvasAnchor: Offset(0.02, 0.32),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 61,
      palette: [
        Color(0xFF2A1500),
        Color(0xFF7A4205),
        Color(0xFFFFA82A),
        Color(0xFFFFD58A),
        Color(0xFFFFF1D6),
      ],
    ),
    CosmosPlanet(
      id: 'indigo-rocky',
      canvasAnchor: Offset(0.78, 0.44),
      radiusPixels: 11,
      pattern: PlanetPattern.speckled,
      seed: 73,
      palette: [
        Color(0xFF08081C),
        Color(0xFF1F2280),
        Color(0xFF3F66FF),
        Color(0xFF9BB8FF),
        Color(0xFFE0EBFF),
      ],
    ),
    CosmosPlanet(
      id: 'coral-rose',
      canvasAnchor: Offset(0.08, 0.74),
      radiusPixels: 8,
      pattern: PlanetPattern.bands,
      seed: 83,
      palette: [
        Color(0xFF2A0610),
        Color(0xFF7A1A30),
        Color(0xFFFF4E78),
        Color(0xFFFFA0B8),
        Color(0xFFFFE0E8),
      ],
    ),
    CosmosPlanet(
      id: 'cyan-dwarf',
      canvasAnchor: Offset(0.16, 0.10),
      radiusPixels: 7,
      pattern: PlanetPattern.hemispheres,
      seed: 101,
      palette: [
        Color(0xFF021A1F),
        Color(0xFF0A5566),
        Color(0xFF2DE5D8),
        Color(0xFFA5FFF5),
        Color(0xFFE9FFFB),
      ],
    ),
    CosmosPlanet(
      id: 'magenta-dwarf',
      canvasAnchor: Offset(0.18, 0.40),
      radiusPixels: 6,
      pattern: PlanetPattern.speckled,
      seed: 109,
      palette: [
        Color(0xFF24061A),
        Color(0xFF66124A),
        Color(0xFFE040A0),
        Color(0xFFFFA0D5),
        Color(0xFFFFE0F0),
      ],
    ),
    CosmosPlanet(
      id: 'pale-gold',
      canvasAnchor: Offset(0.06, 0.94),
      radiusPixels: 10,
      pattern: PlanetPattern.bands,
      seed: 127,
      palette: [
        Color(0xFF1F1505),
        Color(0xFF6A4A0A),
        Color(0xFFE6C25A),
        Color(0xFFFFE8A5),
        Color(0xFFFFF7DC),
      ],
    ),
    CosmosPlanet(
      id: 'deep-purple',
      canvasAnchor: Offset(0.94, 0.72),
      radiusPixels: 8,
      pattern: PlanetPattern.speckled,
      seed: 137,
      palette: [
        Color(0xFF0A0420),
        Color(0xFF2E1466),
        Color(0xFF6B40E0),
        Color(0xFFB89BFF),
        Color(0xFFE6DCFF),
      ],
    ),
    CosmosPlanet(
      id: 'sun-yellow',
      canvasAnchor: Offset(0.96, 0.28),
      radiusPixels: 7,
      pattern: PlanetPattern.hemispheres,
      seed: 149,
      palette: [
        Color(0xFF2A1F00),
        Color(0xFF7A5A05),
        Color(0xFFFFD22A),
        Color(0xFFFFE88A),
        Color(0xFFFFF8D6),
      ],
    ),
  ];
}

List<CosmosNebula> heroNebulas({required bool isMobile}) {
  final leftX = isMobile ? 0.12 : 0.06;
  final rightX = isMobile ? 0.88 : 0.92;
  return [
    const CosmosNebula(
      canvasAnchor: Offset(0.86, 0.06),
      radiusPixels: 110,
      color: Color(0xFFFF1F8B),
      density: 0.78,
      seed: 4,
    ),
    CosmosNebula(
      canvasAnchor: Offset(leftX, 0.20),
      radiusPixels: 70,
      color: const Color(0xFF0AC4FF),
      density: 0.62,
      seed: 1,
    ),
    CosmosNebula(
      canvasAnchor: Offset(rightX, 0.50),
      radiusPixels: 60,
      color: const Color(0xFF9D3FFF),
      seed: 6,
    ),
    CosmosNebula(
      canvasAnchor: Offset(isMobile ? 0.10 : 0.04, 0.88),
      radiusPixels: 64,
      color: const Color(0xFFE020F2),
      density: 0.60,
      seed: 5,
    ),
  ];
}

List<CosmosGalaxy> heroGalaxies({required bool isMobile}) {
  if (!isMobile) {
    return const [
      CosmosGalaxy(
        canvasAnchor: Offset(0.92, 0.88),
        radiusPixels: 160,
        coreColor: Color(0xFFFFE8C2),
        armColor: Color(0xFF9D3FFF),
        armCount: 4,
        tiltY: 0.38,
        rotation: -0.7,
        dustCount: 320,
        seed: 41,
      ),
      CosmosGalaxy(
        canvasAnchor: Offset(0.10, 0.18),
        radiusPixels: 90,
        coreColor: Color(0xFFE8FBFF),
        armColor: Color(0xFFFF1F8B),
        tiltY: 0.55,
        rotation: 1.2,
        dustCount: 200,
        seed: 67,
      ),
      CosmosGalaxy(
        canvasAnchor: Offset(0.30, 0.92),
        radiusPixels: 110,
        coreColor: Color(0xFFFFE8C2),
        armColor: Color(0xFF9D3FFF),
        armCount: 4,
        tiltY: 0.42,
        rotation: 0.4,
        dustCount: 240,
        seed: 89,
      ),
    ];
  }
  return const [
    CosmosGalaxy(
      canvasAnchor: Offset(0.88, 0.88),
      radiusPixels: 160,
      coreColor: Color(0xFFFFE8C2),
      armColor: Color(0xFF9D3FFF),
      armCount: 4,
      tiltY: 0.38,
      rotation: -0.7,
      dustCount: 320,
      seed: 41,
    ),
    CosmosGalaxy(
      canvasAnchor: Offset(0.15, 0.19),
      radiusPixels: 90,
      coreColor: Color(0xFFE8FBFF),
      armColor: Color(0xFFFF1F8B),
      tiltY: 0.55,
      rotation: 1.2,
      dustCount: 200,
      seed: 67,
    ),
  ];
}

List<CosmosPulsar> heroPulsars({required bool isMobile}) {
  if (!isMobile) {
    return const [
      CosmosPulsar(
        canvasAnchor: Offset(0.92, 0.32),
        coreColor: Color(0xFF99FFEC),
        beamColor: Color(0xFF0AC4FF),
        beamLengthPixels: 64,
        seed: 31,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.04, 0.56),
        coreColor: Color(0xFFFFCFF8),
        beamColor: Color(0xFFFF1F8B),
        coreRadiusPixels: 2,
        beamLengthPixels: 50,
        phaseOffset: 0.37,
        seed: 47,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.72, 0.08),
        coreColor: Color(0xFFFFF8C8),
        beamColor: Color(0xFFFFB81F),
        coreRadiusPixels: 2,
        beamLengthPixels: 42,
        phaseOffset: 0.62,
        seed: 53,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.12, 0.92),
        coreColor: Color(0xFFF0DCFF),
        beamColor: Color(0xFF9D3FFF),
        coreRadiusPixels: 2,
        beamLengthPixels: 38,
        phaseOffset: 0.83,
        seed: 71,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.06, 0.16),
        coreColor: Color(0xFFE8FBFF),
        beamColor: Color(0xFF06D4FF),
        coreRadiusPixels: 2,
        beamLengthPixels: 44,
        phaseOffset: 0.21,
        seed: 89,
      ),
    ];
  }
  return const [
    CosmosPulsar(
      canvasAnchor: Offset(0.88, 0.34),
      coreColor: Color(0xFF99FFEC),
      beamColor: Color(0xFF0AC4FF),
      beamLengthPixels: 64,
      seed: 31,
    ),
    CosmosPulsar(
      canvasAnchor: Offset(0.10, 0.58),
      coreColor: Color(0xFFFFCFF8),
      beamColor: Color(0xFFFF1F8B),
      coreRadiusPixels: 2,
      beamLengthPixels: 50,
      phaseOffset: 0.37,
      seed: 47,
    ),
    CosmosPulsar(
      canvasAnchor: Offset(0.72, 0.10),
      coreColor: Color(0xFFFFF8C8),
      beamColor: Color(0xFFFFB81F),
      coreRadiusPixels: 2,
      beamLengthPixels: 42,
      phaseOffset: 0.62,
      seed: 53,
    ),
    CosmosPulsar(
      canvasAnchor: Offset(0.18, 0.90),
      coreColor: Color(0xFFF0DCFF),
      beamColor: Color(0xFF9D3FFF),
      coreRadiusPixels: 2,
      beamLengthPixels: 38,
      phaseOffset: 0.83,
      seed: 71,
    ),
  ];
}

List<CosmosAsteroidBelt> heroAsteroidBelts({required bool isMobile}) {
  if (!isMobile) {
    return const [
      CosmosAsteroidBelt(
        canvasAnchor: Offset(0.10, 0.20),
        radiusPixels: 96,
        rockColor: Color(0xFFB69BD9),
        highlightColor: Color(0xFFFFE8C2),
        tiltY: 0.28,
        rotation: -0.4,
        rockCount: 160,
        arcStart: 0.05,
        arcSweep: 0.72,
        seed: 91,
      ),
      CosmosAsteroidBelt(
        canvasAnchor: Offset(0.90, 0.60),
        radiusPixels: 110,
        rockColor: Color(0xFFE8B5C8),
        highlightColor: Color(0xFFFFCFF8),
        tiltY: 0.36,
        rotation: 0.9,
        rockCount: 180,
        arcStart: 0.15,
        arcSweep: 0.80,
        seed: 119,
      ),
    ];
  }
  return const [
    CosmosAsteroidBelt(
      canvasAnchor: Offset(0.16, 0.22),
      radiusPixels: 96,
      rockColor: Color(0xFFB69BD9),
      highlightColor: Color(0xFFFFE8C2),
      tiltY: 0.28,
      rotation: -0.4,
      rockCount: 160,
      arcStart: 0.05,
      arcSweep: 0.72,
      seed: 91,
    ),
    CosmosAsteroidBelt(
      canvasAnchor: Offset(0.86, 0.62),
      radiusPixels: 110,
      rockColor: Color(0xFFE8B5C8),
      highlightColor: Color(0xFFFFCFF8),
      tiltY: 0.36,
      rotation: 0.9,
      rockCount: 180,
      arcStart: 0.15,
      arcSweep: 0.80,
      seed: 119,
    ),
  ];
}

List<CosmosWisp> heroWisps({required bool isMobile}) {
  if (!isMobile) {
    return const [
      CosmosWisp(
        canvasAnchor: Offset(0.04, 0.40),
        radiusPixels: 130,
        colors: [Color(0xFF0AC4FF), Color(0xFF9D3FFF), Color(0xFFE020F2)],
        blobCount: 6,
        driftPixels: 16,
        density: 0.55,
        seed: 23,
      ),
      CosmosWisp(
        canvasAnchor: Offset(0.14, 0.62),
        radiusPixels: 90,
        colors: [Color(0xFFFF1F8B), Color(0xFFFF66F5), Color(0xFFFFCFF8)],
        density: 0.45,
        seed: 37,
      ),
      CosmosWisp(
        canvasAnchor: Offset(0.94, 0.40),
        radiusPixels: 100,
        colors: [Color(0xFF8B5CF6), Color(0xFF2D7FFF), Color(0xFF7CB8FF)],
        driftPixels: 14,
        density: 0.42,
        seed: 79,
      ),
    ];
  }
  return const [
    CosmosWisp(
      canvasAnchor: Offset(0.08, 0.42),
      radiusPixels: 130,
      colors: [Color(0xFF0AC4FF), Color(0xFF9D3FFF), Color(0xFFE020F2)],
      blobCount: 6,
      driftPixels: 16,
      density: 0.55,
      seed: 23,
    ),
    CosmosWisp(
      canvasAnchor: Offset(0.20, 0.62),
      radiusPixels: 90,
      colors: [Color(0xFFFF1F8B), Color(0xFFFF66F5), Color(0xFFFFCFF8)],
      driftPixels: 12,
      density: 0.45,
      seed: 37,
    ),
  ];
}
