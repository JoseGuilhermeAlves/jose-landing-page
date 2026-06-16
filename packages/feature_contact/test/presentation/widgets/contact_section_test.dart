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

      // Titulo da secao em fonte pixel (PixelText, nao Text — "conversar?"
      // vira matriz de pixels).
      expect(find.byType(PixelText), findsWidgets);
      // O proprio endereco e o CTA tipografico.
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
      // Regressao: "Vamos conversar?" em PixelText (largura intrinseca =
      // chars x pixelSize) sangrava pra fora do painel no mobile ~360px.
      // No mobile o titulo quebra em duas linhas e um FittedBox(scaleDown)
      // garante que ate a linha mais longa caiba. Aqui medimos a largura
      // pintada do titulo contra o viewport.
      const narrow = Size(360, 1600);
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com'), size: narrow),
      );
      await tester.pump(const Duration(milliseconds: 16));

      // O titulo e o primeiro PixelText em fonte pixel da secao (o
      // eyebrow "~ INSERT COIN" tambem e PixelText, mas o titulo carrega
      // o glow magenta). Pegamos todos e garantimos que nenhum extrapola.
      final pixelTexts = find.byType(PixelText);
      expect(pixelTexts, findsWidgets);
      for (final element in pixelTexts.evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        expect(
          size.width,
          lessThanOrEqualTo(narrow.width),
          reason: 'PixelText "${(element.widget as PixelText).text}" '
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

      // Email primario fica acima da linha de links secundarios.
      final emailTop = tester
          .getTopLeft(find.byKey(const Key('contact-cta-email')))
          .dy;
      final githubTop = tester
          .getTopLeft(find.byKey(const Key('contact-cta-github')))
          .dy;
      expect(emailTop, lessThan(githubTop));

      // Ordem de leitura GitHub · LinkedIn · WhatsApp — wrap-aware:
      // dentro do painel coral (mais estreito) o Wrap pode quebrar pra
      // outra linha, entao cada link seguinte fica a direita na mesma
      // linha OU numa linha abaixo.
      Offset topLeftOf(String key) => tester.getTopLeft(find.byKey(Key(key)));
      bool follows(Offset a, Offset b) =>
          b.dy > a.dy || (b.dy == a.dy && b.dx > a.dx);
      final gh = topLeftOf('contact-cta-github');
      final li = topLeftOf('contact-cta-linkedin');
      final wa = topLeftOf('contact-cta-whatsapp');
      expect(follows(gh, li), isTrue);
      expect(follows(li, wa), isTrue);

      // Tap em um secundario propaga a Uri correta.
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

    testWidgets('form comeca colapsado e expande pelo toggle', (tester) async {
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      // Funil mailto primeiro — o form e caminho secundario.
      expect(find.byType(ContactForm), findsNothing);

      await tester.tap(find.byKey(const Key('contact-form-toggle')));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ContactForm), findsOneWidget);

      // Colapsa de novo no segundo tap.
      await tester.tap(find.byKey(const Key('contact-form-toggle')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ContactForm), findsNothing);
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

      // Foca direto o FocusableActionDetector do link de email e ativa
      // via Enter — cobre o caminho de teclado sem depender da ordem de
      // tab da arvore inteira. Focus.of num descendant resolve o node
      // interno do detector.
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
      // FocusableActionDetector so mostra hover highlight em modo
      // "traditional" — em teste o default e touch, entao forcamos.
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

      // Painel arcade: email em ciano (accent) que sobe pro onSurface
      // pleno no hover.
      const colors = AppColorScheme.light;
      expect(colorOfEmailText(), colors.accent);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(
        tester.getCenter(find.byKey(const Key('contact-cta-email'))),
      );
      // Dois pumps: um registra o evento, o outro deixa o frame de
      // highlight assentar (ver memoria testing_mouseregion_animations).
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
