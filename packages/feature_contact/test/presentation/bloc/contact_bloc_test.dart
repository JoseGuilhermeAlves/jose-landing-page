import 'package:bloc_test/bloc_test.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// WhatsApp number do Jose. Numero ficticio aqui — em produto vem
  /// de uma constante do shell.
  const whatsappNumber = '5571999990000';

  ContactBloc makeBloc() => ContactBloc(whatsappNumber: whatsappNumber);

  group('ContactBloc', () {
    test('estado inicial e ContactState.initial()', () {
      expect(makeBloc().state, const ContactState.initial());
    });

    blocTest<ContactBloc, ContactState>(
      'ContactNameChanged atualiza name preservando outros campos',
      build: makeBloc,
      act: (bloc) => bloc.add(const ContactNameChanged('Jose')),
      expect: () => [const ContactState(name: 'Jose', email: '', message: '')],
    );

    blocTest<ContactBloc, ContactState>(
      'ContactEmailChanged atualiza email',
      build: makeBloc,
      act: (bloc) => bloc.add(const ContactEmailChanged('a@b.com')),
      expect: () => [
        const ContactState(name: '', email: 'a@b.com', message: ''),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'ContactMessageChanged atualiza message',
      build: makeBloc,
      act: (bloc) => bloc.add(const ContactMessageChanged('oi mundo')),
      expect: () => [
        const ContactState(name: '', email: '', message: 'oi mundo'),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'ContactProjectTypeChanged seleciona e aceita null pra desmarcar',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const ContactProjectTypeChanged(ProjectType.consulting))
        ..add(const ContactProjectTypeChanged(null)),
      expect: () => [
        const ContactState(
          name: '',
          email: '',
          message: '',
          projectType: ProjectType.consulting,
        ),
        const ContactState(name: '', email: '', message: ''),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'submit com form invalido: ativa autoValidate, nao submete',
      build: makeBloc,
      act: (bloc) => bloc.add(const ContactSubmitted()),
      expect: () => [
        const ContactState(
          name: '',
          email: '',
          message: '',
          autoValidate: true,
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'submit com form valido emite Submitting -> Success com wa.me URI',
      build: makeBloc,
      seed: () => const ContactState(
        name: 'Cliente Teste',
        email: 'cliente@teste.com',
        message: 'Quero conversar sobre app novo de delivery.',
        projectType: ProjectType.newApp,
      ),
      act: (bloc) => bloc.add(const ContactSubmitted()),
      expect: () => [
        isA<ContactState>().having(
          (s) => s.submission,
          'submission',
          isA<ContactSubmissionSubmitting>(),
        ),
        isA<ContactState>().having(
          (s) => s.submission,
          'submission',
          isA<ContactSubmissionSuccess>().having(
            (sub) => sub.target.toString(),
            'target',
            allOf(contains('wa.me/$whatsappNumber'), contains('text=')),
          ),
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'wa.me URI inclui nome, email, tipo e mensagem (encoded)',
      build: makeBloc,
      seed: () => const ContactState(
        name: 'Cliente & Cia',
        email: 'cliente@teste.com',
        message: 'Mensagem com acentos: cao & gato.',
        projectType: ProjectType.consulting,
      ),
      act: (bloc) => bloc.add(const ContactSubmitted()),
      verify: (bloc) {
        final sub = bloc.state.submission;
        expect(sub, isA<ContactSubmissionSuccess>());
        final uri = (sub as ContactSubmissionSuccess).target;
        final decoded = Uri.decodeComponent(uri.queryParameters['text'] ?? '');
        expect(decoded, contains('Cliente & Cia'));
        expect(decoded, contains('cliente@teste.com'));
        expect(decoded, contains('cao & gato'));
        expect(decoded, contains(ProjectType.consulting.label));
      },
    );

    blocTest<ContactBloc, ContactState>(
      'apos sucesso, ContactReset volta ao estado inicial',
      build: makeBloc,
      seed: () => ContactState(
        name: 'a',
        email: 'a@b.com',
        message: 'mensagem grande aqui',
        projectType: ProjectType.newApp,
        submission: ContactSubmissionSuccess(Uri.parse('https://wa.me/x')),
      ),
      act: (bloc) => bloc.add(const ContactReset()),
      expect: () => [const ContactState.initial()],
    );
  });
}
