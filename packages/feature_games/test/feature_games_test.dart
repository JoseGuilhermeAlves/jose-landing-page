import 'package:feature_games/games_route_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GamesRoutePaths', () {
    test('index e /games', () {
      expect(GamesRoutePaths.index, '/games');
    });

    test('raycaster e /games/raycaster', () {
      expect(GamesRoutePaths.raycaster, '/games/raycaster');
    });
  });
}
