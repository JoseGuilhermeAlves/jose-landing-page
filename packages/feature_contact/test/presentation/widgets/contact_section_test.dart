import 'package:design_system/design_system.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 1600)}) {
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

  group('ContactSection', () {
    testWidgets('renderiza headline + ContactForm', (tester) async {
      await tester.pumpWidget(
        wrap(const ContactSection(whatsappNumber: '5571999990000')),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ContactForm), findsOneWidget);
      // headline da secao (copy de PROJECT.md §4.5 — convida o cliente
      // a abrir conversa)
      expect(find.textContaining('conversar'), findsWidgets);
    });

    testWidgets('expoe links alternativos: WhatsApp, email, LinkedIn, GitHub', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ContactSection(
            whatsappNumber: '5571999990000',
            email: 'contato@example.com',
            linkedinUrl: 'https://linkedin.com/in/jose',
            githubUrl: 'https://github.com/jose',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('contact-cta-whatsapp')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-email')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-linkedin')), findsOneWidget);
      expect(find.byKey(const Key('contact-cta-github')), findsOneWidget);
    });

    testWidgets('Semantics(header: true) na headline', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          wrap(const ContactSection(whatsappNumber: '5571999990000')),
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
