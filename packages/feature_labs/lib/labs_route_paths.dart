/// Re-export eager-only do `LabsRoutePaths`. Importe esta library (em
/// vez do barrel `feature_labs.dart`) quando precisar das paths
/// constantes — assim o shell mantem o GoRouter configurado sem
/// arrastar o bundle deferido inteiro pro main chunk.
library;

export 'src/router/labs_route_paths.dart';
