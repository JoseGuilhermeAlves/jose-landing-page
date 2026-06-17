import 'package:design_system/design_system.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 1600)}) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
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

  group('ContactSection', () {
    testWidgets('renderiza titulo, paragrafo e email como link grande', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(PixelText), findsWidgets);
      final emailLink = find.byKey(const Key('contact-cta-email'));
      expect(emailLink, findsOneWidget);
      expect(
        find.descendant(
          of: emailLink,
          matching: find.text('contato@example.com'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('titulo nao estoura a largura num viewport mobile estreito', (
      tester,
    ) async {
      const narrow = Size(360, 1600);
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com'), size: narrow),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final pixelTexts = find.byType(PixelText);
      expect(pixelTexts, findsWidgets);
      for (final element in pixelTexts.evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        expect(
          size.width,
          lessThanOrEqualTo(narrow.width),
          reason:
              'PixelText "${(element.widget as PixelText).text}" '
              'estoura o viewport de ${narrow.width}px',
        );
      }
    });

    testWidgets('email link dispara mailto via onOpenUri', (tester) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        wrap(
          ContactSection(email: 'contato@example.com', onOpenUri: opened.add),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('contact-cta-email')));
      await tester.pump();

      expect(opened, hasLength(1));
      expect(opened.single.scheme, 'mailto');
      expect(opened.single.path, 'contato@example.com');
    });

    testWidgets('links secundarios: GitHub, LinkedIn e WhatsApp em ordem', (
      tester,
    ) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        wrap(
          ContactSection(
            email: 'contato@example.com',
            whatsappNumber: '5571999990000',
            linkedinUrl: 'https://linkedin.com/in/jose',
            githubUrl: 'https://github.com/jose',
            onOpenUri: opened.add,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('contact-cta-github')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-linkedin')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-whatsapp')), findsOneWidget);

      final emailTop = tester
          .getTopLeft(find.byKey(const Key('contact-cta-email')))
          .dy;
      final githubTop = tester
          .getTopLeft(find.byKey(const Key('contact-cta-github')))
          .dy;
      expect(emailTop, lessThan(githubTop));

      Offset topLeftOf(String key) => tester.getTopLeft(find.byKey(Key(key)));
      bool follows(Offset a, Offset b) =>
          b.dy > a.dy || (b.dy == a.dy && b.dx > a.dx);
      final gh = topLeftOf('contact-cta-github');
      final li = topLeftOf('contact-cta-linkedin');
      final wa = topLeftOf('contact-cta-whatsapp');
      expect(follows(gh, li), isTrue);
      expect(follows(li, wa), isTrue);

      await tester.tap(find.byKey(const Key('contact-cta-github')));
      await tester.pump();
      expect(opened.single.toString(), 'https://github.com/jose');
    });

    testWidgets('omite links secundarios sem url configurada', (tester) async {
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('contact-cta-github')), findsNothing);
      expect(find.byKey(const Key('contact-cta-linkedin')), findsNothing);
      expect(find.byKey(const Key('contact-cta-whatsapp')), findsNothing);
    });

    testWidgets('expoe link de download do curriculo quando resumeUrl', (
      tester,
    ) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        wrap(
          ContactSection(
            email: 'contato@example.com',
            resumeUrl: 'cv/jose-guilherme-alves-pt.pdf',
            onOpenUri: opened.add,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final resume = find.byKey(const Key('contact-cta-resume'));
      expect(resume, findsOneWidget);

      await tester.tap(resume);
      await tester.pump();
      expect(opened.single.toString(), 'cv/jose-guilherme-alves-pt.pdf');
    });

    testWidgets('omite link de curriculo sem resumeUrl', (tester) async {
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('contact-cta-resume')), findsNothing);
    });

    testWidgets('email link aceita foco por teclado e ativa com Enter', (
      tester,
    ) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        wrap(
          ContactSection(email: 'contato@example.com', onOpenUri: opened.add),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final textContext = tester.element(
        find
            .descendant(
              of: find.byKey(const Key('contact-cta-email')),
              matching: find.text('contato@example.com'),
            )
            .first,
      );
      final focusNode = Focus.of(textContext)..requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(opened, hasLength(1));
      expect(opened.single.scheme, 'mailto');
    });

    testWidgets('hover no email link sobe ink para onSurface pleno', (
      tester,
    ) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic;
      });

      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      Color colorOfEmailText() {
        final text = tester.widget<Text>(
          find
              .descendant(
                of: find.byKey(const Key('contact-cta-email')),
                matching: find.text('contato@example.com'),
              )
              .first,
        );
        return text.style!.color!;
      }

      const colors = AppColorScheme.light;
      expect(colorOfEmailText(), colors.accent);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(
        tester.getCenter(find.byKey(const Key('contact-cta-email'))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(colorOfEmailText(), colors.onSurface);
    });

    testWidgets('Semantics(header: true) no titulo e link no email', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          wrap(const ContactSection(email: 'contato@example.com')),
        );
        await tester.pump(const Duration(milliseconds: 16));

        final headers = find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.header ?? false),
        );
        expect(headers, findsWidgets);

        final links = find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.link ?? false),
        );
        expect(links, findsWidgets);
      } finally {
        handle.dispose();
      }
    });
  });
}
