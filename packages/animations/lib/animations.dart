/// Custom Painters, controllers e widgets de animacao reutilizaveis pelo
/// app. Os painters sao o coracao tecnico do projeto — manter
/// `shouldRepaint` correto, `Paint` cacheado em campos e hints de
/// `isComplex`/`willChange` quando aplicavel.
library;

export 'src/painters/animated_border_painter.dart';
export 'src/painters/animated_timeline_painter.dart';
export 'src/painters/arcade_backdrop_painter.dart';
export 'src/painters/constellation_painter.dart';
export 'src/painters/cosmos_painter.dart';
export 'src/painters/crt_painter.dart';
export 'src/painters/loading_spinner_painter.dart';
export 'src/painters/morphing_shape_painter.dart';
export 'src/painters/particle_field_painter.dart';
export 'src/painters/ripple_hover_painter.dart';
export 'src/painters/wave_divider_painter.dart';
export 'src/widgets/constellation_field.dart';
export 'src/widgets/celestial_planet.dart';
export 'src/widgets/cosmos_field.dart';
export 'src/widgets/loading_spinner.dart';
export 'src/widgets/particle_field.dart';
export 'src/widgets/soul_eater_moon.dart';
export 'src/widgets/soul_eater_sun.dart';
export 'src/widgets/space_creature.dart';
