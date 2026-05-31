import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/widgets/case_study_section.dart';

void main() {
  Widget wrap({required Size size}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox.fromSize(
            size: size,
            child: const SingleChildScrollView(child: CaseStudySection()),
          ),
        ),
      ),
    );
  }

  group('CaseStudySection', () {
    testWidgets('renderiza em viewport mobile sem RenderFlex unbounded', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrap(size: const Size(390, 2400)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
      expect(find.byType(CaseStudySection), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renderiza em viewport desktop sem excecao', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrap(size: const Size(1440, 2400)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
      expect(find.byType(CaseStudySection), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
