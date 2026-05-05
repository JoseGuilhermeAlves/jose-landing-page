import 'package:feature_labs/feature_labs.dart';
import 'package:feature_labs/labs_route_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaygroundsCatalog', () {
    test('expoe os 7 playgrounds previstos', () {
      final ids = PlaygroundsCatalog.all.map((p) => p.id).toList();
      expect(ids, hasLength(7));
      expect(
        ids,
        containsAll([
          'particles',
          'timeline',
          'border',
          'spinner',
          'morphing',
          'ripple',
          'wave',
        ]),
      );
    });

    test('ids sao unicos', () {
      final ids = PlaygroundsCatalog.all.map((p) => p.id).toSet();
      expect(ids, hasLength(PlaygroundsCatalog.all.length));
    });

    test('cada path comeca com /labs/ e bate com LabsRoutePaths', () {
      const expectedPaths = <String, String>{
        'particles': LabsRoutePaths.particles,
        'timeline': LabsRoutePaths.timeline,
        'border': LabsRoutePaths.border,
        'spinner': LabsRoutePaths.spinner,
        'morphing': LabsRoutePaths.morphing,
        'ripple': LabsRoutePaths.ripple,
        'wave': LabsRoutePaths.wave,
      };

      for (final p in PlaygroundsCatalog.all) {
        expect(p.routePath, startsWith('/labs/'));
        expect(p.routePath, expectedPaths[p.id]);
      }
    });

    test('todos os campos visiveis sao nao-vazios', () {
      for (final p in PlaygroundsCatalog.all) {
        expect(p.label, isNotEmpty);
        expect(p.shortDescription, isNotEmpty);
        expect(p.painterName, isNotEmpty);
      }
    });

    test('catalogo e imutavel', () {
      expect(
        () => PlaygroundsCatalog.all.add(PlaygroundsCatalog.all.first),
        throwsUnsupportedError,
      );
    });
  });

  group('LabsRoutePaths', () {
    test('index e /labs', () {
      expect(LabsRoutePaths.index, '/labs');
    });

    test('todas as sub-paths sao distintas', () {
      final all = {
        LabsRoutePaths.index,
        ...LabsRoutePaths.playgroundPaths,
      };
      expect(all.length, 8);
    });

    test('playgroundPaths bate com os ids do catalogo (em ordem)', () {
      final fromCatalog =
          PlaygroundsCatalog.all.map((p) => p.routePath).toList();
      expect(LabsRoutePaths.playgroundPaths, fromCatalog);
    });
  });
}
