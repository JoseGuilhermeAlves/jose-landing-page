import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_hero/feature_hero.dart';
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

  // Hero agora exibe foto a esquerda em desktop — surface size default
  // do flutter_test (800x600) nao acomoda foto + CTAs lado a lado, o que
  // empurra botoes pra fora do viewport e quebra taps. Helper aumenta
  // surface por teste e registra reset.
  Future<void> useDesktopSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('HeroSection', () {
    testWidgets('renderiza headline e subheadline canonicos', (tester) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // Headline em duas linhas com os dois fatos mais fortes: tempo de
      // stack e artefato em producao. A linha de escopo (backend e
      // integracao) aparece logo abaixo da bio.
      expect(find.text('Seis anos de Flutter.'), findsOneWidget);
      expect(
        find.text('Cinco apps de varejo em produção.'),
        findsOneWidget,
      );
      expect(find.textContaining('Backend permanece com o time'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('expoe a headline como Semantics(header: true)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap(const HeroSection()));
        await tester.pump(const Duration(milliseconds: 16));

        // Procura qualquer node Semantics com flag de header.
        final headerSemantics = find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.header ?? false),
        );
        expect(headerSemantics, findsWidgets);
      } finally {
        handle.dispose();
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renderiza dois CTAs: Ver projetos (primario) + Falar comigo', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Ver projetos'), findsOneWidget);
      expect(find.text('Falar comigo'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTA "Falar comigo" dispara onContactPressed', (tester) async {
      await useDesktopSurface(tester);
      var taps = 0;
      await tester.pumpWidget(
        wrap(HeroSection(onContactPressed: () => taps++)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.text('Falar comigo'));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTA "Ver projetos" dispara onSeeProjectsPressed', (
      tester,
    ) async {
      await useDesktopSurface(tester);
      var taps = 0;
      await tester.pumpWidget(
        wrap(HeroSection(onSeeProjectsPressed: () => taps++)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.text('Ver projetos'));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTAs ficam desabilitados quando callbacks nao sao providos', (
      tester,
    ) async {
      await useDesktopSurface(tester);
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap(const HeroSection()));
        await tester.pump(const Duration(milliseconds: 16));

        // Sem onPressed, AppButton vira Semantics.isEnabled = false.
        expect(
          tester.getSemantics(find.bySemanticsLabel('Falar comigo')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            label: 'Falar comigo',
          ),
        );
      } finally {
        handle.dispose();
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renderiza ParticleField no fundo (animacao §5.1)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ParticleField), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('layout mobile (largura < 600) empilha CTAs verticalmente', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const HeroSection(), size: const Size(360, 720)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final projectsRect = tester.getRect(find.text('Ver projetos'));
      final contactRect = tester.getRect(find.text('Falar comigo'));

      // Em mobile, "Falar comigo" fica abaixo de "Ver projetos".
      expect(contactRect.top, greaterThan(projectsRect.bottom - 1));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('layout desktop renderiza foto a esquerda do texto', (
      tester,
    ) async {
      // Em desktop o hero passa a ser Row com foto a esquerda e
      // texto+CTA a direita — eixo de leitura horizontal substitui
      // o center-aligned anterior.
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrap(const HeroSection(), size: const Size(1600, 900)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final photoFinder = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/foto_recortada.webp',
      );
      expect(photoFinder, findsOneWidget);

      final photoRect = tester.getRect(photoFinder);
      final headlineRect = tester.getRect(
        find.text('Seis anos de Flutter.'),
      );

      // Foto fica a esquerda do headline.
      expect(photoRect.right, lessThan(headlineRect.left + 1));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
