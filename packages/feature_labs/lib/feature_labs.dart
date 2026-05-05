/// Feature Labs (PROJECT.md §4.6) — playground tecnico em `/labs`.
/// Exposto via deferred import no shell `apps/landing`: o bundle so
/// desce quando o usuario navega pra ca.
///
/// Constantes de rota (`LabsRoutePaths`) NAO sao re-exportadas aqui de
/// proposito — quem precisa delas em main bundle deve importar
/// `package:feature_labs/labs_route_paths.dart`.
library;

export 'src/data/playgrounds_catalog.dart';
export 'src/domain/playground_descriptor.dart';
export 'src/pages/labs_page.dart';
export 'src/playgrounds/animated_border_playground.dart';
export 'src/playgrounds/animated_timeline_playground.dart';
export 'src/playgrounds/loading_spinner_playground.dart';
export 'src/playgrounds/morphing_shape_playground.dart';
export 'src/playgrounds/particle_field_playground.dart';
export 'src/playgrounds/ripple_hover_playground.dart';
export 'src/playgrounds/wave_divider_playground.dart';
export 'src/sections/architecture_section.dart';
export 'src/widgets/playground_scaffold.dart';
