import 'package:design_system/design_system.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(900, 1200)}) {
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

  Widget pumpForm({ValueChanged<Uri>? onSuccess}) {
    return wrap(
      BlocProvider(
        create: (_) => ContactBloc(whatsappNumber: '5571999990000'),
        child: ContactForm(onSubmissionSuccess: onSuccess),
      ),
    );
  }

  group('ContactForm', () {
    testWidgets('renderiza campos canonicos: nome, email, mensagem, dropdown', (
      tester,
    ) async {
      await tester.pumpWidget(pumpForm());
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('contact-form-name')), findsOneWidget);
      expect(find.byKey(const Key('contact-form-email')), findsOneWidget);
      expect(find.byKey(const Key('contact-form-message')), findsOneWidget);
      expect(
        find.byKey(const Key('contact-form-project-type')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('contact-form-submit')), findsOneWidget);
    });

    testWidgets(
      'submit em form vazio mostra erros inline mas nao chama onSuccess',
      (tester) async {
        var successes = 0;
        await tester.pumpWidget(pumpForm(onSuccess: (_) => successes++));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.tap(find.byKey(const Key('contact-form-submit')));
        await tester.pump();

        expect(find.text('Informe seu nome.'), findsOneWidget);
        expect(find.text('Informe seu email.'), findsOneWidget);
        expect(successes, 0);
      },
    );

    testWidgets(
      'preencher e submeter chama onSubmissionSuccess com Uri wa.me',
      (tester) async {
        Uri? captured;
        await tester.pumpWidget(pumpForm(onSuccess: (uri) => captured = uri));
        await tester.pump(const Duration(milliseconds: 16));

        await tester.enterText(
          find.byKey(const Key('contact-form-name')),
          'Cliente Teste',
        );
        await tester.enterText(
          find.byKey(const Key('contact-form-email')),
          'cliente@teste.com',
        );
        await tester.enterText(
          find.byKey(const Key('contact-form-message')),
          'Mensagem suficientemente longa pra passar.',
        );

        // Seleciona o projectType abrindo o dropdown e tocando na opcao.
        await tester.tap(find.byKey(const Key('contact-form-project-type')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectType.newApp.label).last);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('contact-form-submit')));
        await tester.pumpAndSettle();

        expect(captured, isNotNull);
        expect(captured!.toString(), contains('wa.me/5571999990000'));
      },
    );
  });
}
