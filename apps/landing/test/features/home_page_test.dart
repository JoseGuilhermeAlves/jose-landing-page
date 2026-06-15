import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/features/home_page.dart';
import 'package:landing/presentation/locale_cubit.dart';
import 'package:landing/widgets/engineering_section.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  // Sem isso o VisibilityDetector (SectionVisibility da home) agenda um
  // Timer de 500ms que fica pendente quando o teste descarta a arvore.
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider(create: (_) => LocaleCubit(), child: child),
  );

  group('HomePage', () {
    testWidgets('compoe ArcadeHero no topo', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ArcadeHero), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe ShowcaseSection abaixo do Hero', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      // ShowcaseSection esta no tree, mas pode estar fora da viewport
      // inicial — `skipOffstage: false` percorre toda a lista.
      expect(find.byType(ShowcaseSection, skipOffstage: false), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe EngineeringSection abaixo do About', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byType(EngineeringSection, skipOffstage: false),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe AboutSection abaixo do Showcase', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(AboutSection, skipOffstage: false), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe ContactSection no fim', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ContactSection, skipOffstage: false), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('expoe Key home-page', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      expect(find.byKey(const Key('home-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
