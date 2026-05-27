import 'package:flutter/material.dart';

/// Cor signature por tech — aproximacao das paletas oficiais das marcas.
/// Usada nos cards do bento grid pra dar identidade visual unica a cada
/// tile (em vez de monocromia Kraken-purple). Mantem ancoragem ao tema
/// dark da landing com cores saturadas que se destacam sobre surface
/// dark sem virar neon.
abstract final class TechBrandColors {
  static const Map<String, _Brand> _byName = {
    // Framework
    'Flutter': _Brand(
      primary: Color(0xFF54C5F8),
      glow: Color(0xFF02569B),
    ),
    'Dart': _Brand(
      primary: Color(0xFF00D4C0),
      glow: Color(0xFF0175C2),
    ),
    'Equatable': _Brand(
      primary: Color(0xFF6DD5ED),
      glow: Color(0xFF2193B0),
    ),

    // Estado
    'flutter_bloc': _Brand(
      primary: Color(0xFFEA4C89),
      glow: Color(0xFFB91D5C),
    ),
    'Riverpod': _Brand(
      primary: Color(0xFF0099FF),
      glow: Color(0xFF0553B1),
    ),
    'bloc_test': _Brand(
      primary: Color(0xFFF472B6),
      glow: Color(0xFFBE185D),
    ),

    // Rotas
    'go_router': _Brand(
      primary: Color(0xFF60A5FA),
      glow: Color(0xFF1D4ED8),
    ),

    // Graficos
    'CustomPainter': _Brand(
      primary: Color(0xFFFF7043),
      glow: Color(0xFFBF360C),
    ),
    'Animations': _Brand(
      primary: Color(0xFFFFB74D),
      glow: Color(0xFFE65100),
    ),

    // Persistencia
    'SQLite': _Brand(
      primary: Color(0xFF44A8D8),
      glow: Color(0xFF003B57),
    ),
    'Hive': _Brand(
      primary: Color(0xFFFFCA28),
      glow: Color(0xFFF9A825),
    ),

    // Arquitetura
    'Clean Architecture': _Brand(
      primary: Color(0xFF7C3AED),
      glow: Color(0xFF4C1D95),
    ),
    'SOLID': _Brand(
      primary: Color(0xFFA78BFA),
      glow: Color(0xFF6D28D9),
    ),
    'Monorepo': _Brand(
      primary: Color(0xFF10B981),
      glow: Color(0xFF047857),
    ),
    'Design System': _Brand(
      primary: Color(0xFFF472B6),
      glow: Color(0xFFBE185D),
    ),
    'SDUI': _Brand(
      primary: Color(0xFF06B6D4),
      glow: Color(0xFF0E7490),
    ),
    'Feature-First': _Brand(
      primary: Color(0xFF8B5CF6),
      glow: Color(0xFF5B21B6),
    ),

    // Qualidade
    'very_good_analysis': _Brand(
      primary: Color(0xFFFB923C),
      glow: Color(0xFFC2410C),
    ),
    'flutter_test': _Brand(
      primary: Color(0xFF34D399),
      glow: Color(0xFF047857),
    ),

    // Web
    'Skwasm': _Brand(
      primary: Color(0xFFA78BFA),
      glow: Color(0xFF6D28D9),
    ),
    'PWA': _Brand(
      primary: Color(0xFF818CF8),
      glow: Color(0xFF4338CA),
    ),
    'url_launcher': _Brand(
      primary: Color(0xFF38BDF8),
      glow: Color(0xFF0369A1),
    ),

    // Tooling
    'Melos': _Brand(
      primary: Color(0xFFFACC15),
      glow: Color(0xFFA16207),
    ),
    'GitHub Actions': _Brand(
      primary: Color(0xFFE5E7EB),
      glow: Color(0xFF6B7280),
    ),
    'Fastlane': _Brand(
      primary: Color(0xFF00BCD4),
      glow: Color(0xFF006064),
    ),
  };

  static Color primary(String techName) =>
      _byName[techName]?.primary ?? const Color(0xFF9497A9);

  static Color glow(String techName) =>
      _byName[techName]?.glow ?? const Color(0xFF6B7280);
}

@immutable
class _Brand {
  const _Brand({required this.primary, required this.glow});
  final Color primary;
  final Color glow;
}

/// Cor signature por categoria — usada no chip eyebrow de cada card do
/// bento grid pra criar continuidade visual com as tiles internas.
abstract final class CategoryBrandColors {
  static const Map<String, Color> byCategory = {
    'framework': Color(0xFF54C5F8),
    'state': Color(0xFFEA4C89),
    'routing': Color(0xFF60A5FA),
    'graphics': Color(0xFFFF7043),
    'persistence': Color(0xFF44A8D8),
    'architecture': Color(0xFF7C3AED),
    'quality': Color(0xFFFB923C),
    'web': Color(0xFFA78BFA),
    'tooling': Color(0xFFFACC15),
  };
}
