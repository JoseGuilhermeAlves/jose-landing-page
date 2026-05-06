/// Custom Painters, controllers e widgets de animacao reutilizaveis pelo
/// app. Os painters sao o coracao tecnico do projeto — manter
/// `shouldRepaint` correto, `Paint` cacheado em campos e hints de
/// `isComplex`/`willChange` quando aplicavel.
library;

export 'src/painters/animated_border_painter.dart';
export 'src/painters/animated_timeline_painter.dart';
export 'src/painters/constellation_painter.dart';
export 'src/painters/loading_spinner_painter.dart';
export 'src/painters/morphing_shape_painter.dart';
export 'src/painters/particle_field_painter.dart';
export 'src/painters/ripple_hover_painter.dart';
export 'src/painters/wave_divider_painter.dart';
export 'src/widgets/constellation_field.dart';
export 'src/widgets/loading_spinner.dart';
export 'src/widgets/particle_field.dart';
