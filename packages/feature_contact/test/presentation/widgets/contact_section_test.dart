import 'package:design_system/design_system.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 1600)}) {
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
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  group('ContactSection', () {
    testWidgets('renderiza headline + ContactForm', (tester) async {
      await tester.pumpWidget(
        wrap(const ContactSection(email: 'contato@example.com')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ContactForm), findsOneWidget);
      // headline da secao (copy de PROJECT.md §4.5 — convida o cliente
      // a abrir conversa)
      expect(find.textContaining('conversar'), findsWidgets);
    });

    testWidgets('expoe links diretos: email, LinkedIn, GitHub, WhatsApp', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ContactSection(
            email: 'contato@example.com',
            whatsappNumber: '5571999990000',
            linkedinUrl: 'https://linkedin.com/in/jose',
            githubUrl: 'https://github.com/jose',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('contact-cta-email')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-linkedin')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-github')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-whatsapp')), findsOneWidget);
    });

    testWidgets(
      'funil recrutador: email/LinkedIn/GitHub vem antes do WhatsApp',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const ContactSection(
              email: 'contato@example.com',
              whatsappNumber: '5571999990000',
              linkedinUrl: 'https://linkedin.com/in/jose',
              githubUrl: 'https://github.com/jose',
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));

        double topOf(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;

        final emailTop = topOf('contact-cta-email');
        final linkedinTop = topOf('contact-cta-linkedin');
        final githubTop = topOf('contact-cta-github');
        final whatsappTop = topOf('contact-cta-whatsapp');

        expect(emailTop, lessThan(linkedinTop));
        expect(linkedinTop, lessThan(githubTop));
        expect(githubTop, lessThan(whatsappTop));
      },
    );

    testWidgets('tile aceita foco por Tab e ativa com Enter', (tester) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        wrap(
          ContactSection(email: 'contato@example.com', onOpenUri: opened.add),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      // Foca diretamente o FocusableActionDetector do tile de email e
      // ativa via Enter — cobre o caminho de teclado sem depender da
      // ordem de tab da arvore inteira (form vem antes dos tiles).
      // Focus.of num descendant resolve o node interno do detector.
      final rowContext = tester.element(
        find
            .descendant(
              of: find.byKey(const Key('contact-cta-email')),
              matching: find.byType(Row),
            )
            .first,
      );
      final focusNode = Focus.of(rowContext)..requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(opened, hasLength(1));
      expect(opened.single.scheme, 'mailto');
    });

    testWidgets('Semantics(header: true) na headline', (tester) async {
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
      } finally {
        handle.dispose();
      }
    });
  });
}
