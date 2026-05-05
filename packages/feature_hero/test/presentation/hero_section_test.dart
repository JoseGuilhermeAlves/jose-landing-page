import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(
    Widget child, {
    Size size = const Size(1280, 800),
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );
  }

  group('HeroSection', () {
    testWidgets('renderiza headline e subheadline canonicos', (tester) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.textContaining('Aplicativos Flutter'), findsOneWidget);
      expect(find.textContaining('7+ anos'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('expoe a headline como Semantics(header: true)',
        (tester) async {
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

    testWidgets('renderiza dois CTAs: WhatsApp (primario) + Ver projetos',
        (tester) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Falar no WhatsApp'), findsOneWidget);
      expect(find.text('Ver projetos'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTA do WhatsApp dispara onContactPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(HeroSection(onContactPressed: () => taps++)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.text('Falar no WhatsApp'));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTA "Ver projetos" dispara onSeeProjectsPressed',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(HeroSection(onSeeProjectsPressed: () => taps++)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.text('Ver projetos'));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CTAs ficam desabilitados quando callbacks nao sao providos',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap(const HeroSection()));
        await tester.pump(const Duration(milliseconds: 16));

        // Sem onPressed, AppButton vira Semantics.isEnabled = false.
        expect(
          tester.getSemantics(find.bySemanticsLabel('Falar no WhatsApp')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            label: 'Falar no WhatsApp',
          ),
        );
      } finally {
        handle.dispose();
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renderiza ParticleField no fundo (animacao §5.1)',
        (tester) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ParticleField), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('layout mobile (largura < 600) empilha CTAs verticalmente',
        (tester) async {
      await tester.pumpWidget(
        wrap(const HeroSection(), size: const Size(360, 720)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final whatsappRect = tester.getRect(find.text('Falar no WhatsApp'));
      final projectsRect = tester.getRect(find.text('Ver projetos'));

      // Em mobile, "Ver projetos" fica abaixo do WhatsApp.
      expect(projectsRect.top, greaterThan(whatsappRect.bottom - 1));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('layout desktop (largura >= 900) coloca CTAs lado a lado',
        (tester) async {
      await tester.pumpWidget(wrap(const HeroSection()));
      await tester.pump(const Duration(milliseconds: 16));

      final whatsappRect = tester.getRect(find.text('Falar no WhatsApp'));
      final projectsRect = tester.getRect(find.text('Ver projetos'));

      // Em desktop, ambos compartilham aproximadamente a mesma linha.
      expect(
        (whatsappRect.center.dy - projectsRect.center.dy).abs(),
        lessThan(8),
      );
      // E o "Ver projetos" fica a direita do WhatsApp.
      expect(projectsRect.left, greaterThan(whatsappRect.right - 1));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
