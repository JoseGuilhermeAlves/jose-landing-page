import 'package:design_system/design_system.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:feature_hero/src/presentation/black_hole_portrait.dart';
import 'package:feature_hero/src/presentation/hero_cosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 800)}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
  }

  group('ArcadeHero', () {
    testWidgets('compoe portrait e cosmos do hero', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrap(const ArcadeHero(minHeight: 640)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(BlackHolePortrait), findsOneWidget);
      expect(find.byType(HeroCosmos), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTA "Falar comigo" dispara onContactPressed', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final handle = tester.ensureSemantics();

      var taps = 0;
      await tester.pumpWidget(
        wrap(ArcadeHero(minHeight: 640, onContactPressed: () => taps++)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.bySemanticsLabel('Falar comigo'));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
      handle.dispose();
    });

    testWidgets('CTA "Ver projetos" dispara onSeeProjectsPressed', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1600, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final handle = tester.ensureSemantics();

      var taps = 0;
      await tester.pumpWidget(
        wrap(ArcadeHero(minHeight: 640, onSeeProjectsPressed: () => taps++)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.bySemanticsLabel('Ver projetos'));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
      handle.dispose();
    });
  });
}
