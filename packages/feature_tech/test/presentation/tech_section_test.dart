import 'package:design_system/design_system.dart';
import 'package:feature_tech/feature_tech.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 3200)}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox.fromSize(
            size: size,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  group('TechSection', () {
    testWidgets('renderiza eyebrow + headline + subtitle', (tester) async {
      await tester.pumpWidget(wrap(const TechSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // EyebrowBadge uppercase o label antes de pintar.
      expect(find.text('ENGENHARIA'), findsOneWidget);
      expect(find.textContaining('Da particula'), findsWidgets);
      expect(find.textContaining('constelacao'), findsWidgets);
      expect(find.textContaining('Como as camadas'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renderiza um card pra cada decisao do catalogo', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const TechSection()));
      await tester.pump(const Duration(milliseconds: 16));

      for (final d in ArchDecisionsCatalog.all) {
        expect(
          find.byKey(Key('arch-card-${d.id}')),
          findsOneWidget,
          reason: 'card faltando para ${d.id}',
        );
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renderiza um card pra cada painter do catalogo', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const TechSection()));
      await tester.pump(const Duration(milliseconds: 16));

      for (final p in PaintersCatalog.all) {
        expect(
          find.byKey(Key('painter-card-${p.name}')),
          findsOneWidget,
          reason: 'card faltando para ${p.name}',
        );
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mostra header de cada categoria com items do stack', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const TechSection()));
      await tester.pump(const Duration(milliseconds: 16));

      for (final cat in StackCategory.values) {
        final items = StackCatalog.byCategory[cat] ?? const <StackItem>[];
        if (items.isEmpty) continue;
        expect(
          find.text(cat.label.toUpperCase()),
          findsOneWidget,
          reason: 'header da categoria ${cat.label} ausente',
        );
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('botao de GitHub aparece so quando githubUrl e fornecido', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 4200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const TechSection()));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byKey(const Key('tech-github-button')), findsNothing);

      var clicked = '';
      await tester.pumpWidget(
        wrap(
          TechSection(
            githubUrl: 'https://github.com/example/repo',
            onOpenGithub: (url) => clicked = url,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final button = find.byKey(const Key('tech-github-button'));
      expect(button, findsOneWidget);
      await tester.ensureVisible(button);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 16));
      expect(clicked, 'https://github.com/example/repo');

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('arch card revela border ao hover via AnimationController', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const TechSection()));
      await tester.pump(const Duration(milliseconds: 16));

      final cardKey = Key('arch-card-${ArchDecisionsCatalog.all.first.id}');
      final card = find.byKey(cardKey);
      expect(card, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(card));
      // Hover anim precisa de dois pumps — um pro evento, outro pro
      // Ticker arrancar (ver memoria testing_mouseregion_animations).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      // Sem assert de pixel — apenas garantir que nada quebrou em runtime
      // e que o card continua visivel apos enter.
      expect(find.byKey(cardKey), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
