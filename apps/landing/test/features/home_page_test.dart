import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:feature_services/feature_services.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/features/home_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark(), home: child);

  group('HomePage', () {
    testWidgets('compoe HeroSection no topo', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(HeroSection), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe ServicesGrid abaixo do Hero', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      // ServicesGrid esta no tree, mas pode estar fora da viewport
      // inicial — `skipOffstage: false` percorre toda a lista.
      expect(find.byType(ServicesGrid, skipOffstage: false), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe ShowcaseSection abaixo do Services', (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ShowcaseSection, skipOffstage: false), findsOneWidget);

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
