import 'package:bloc_test/bloc_test.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Email de destino do mailto. Ficticio aqui — em produto vem de uma
  /// constante do shell (AppConfig.email).
  const email = 'contato@example.com';

  ContactBloc makeBloc() => ContactBloc(email: email);

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
      'submit com form valido emite Submitting -> Success com mailto URI',
      build: makeBloc,
      seed: () => const ContactState(
        name: 'Recrutadora Teste',
        email: 'recrutadora@teste.com',
        message: 'Quero conversar sobre uma vaga Flutter senior.',
        projectType: ProjectType.position,
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
            (sub) => sub.target,
            'target',
            isA<Uri>()
                .having((u) => u.scheme, 'scheme', 'mailto')
                .having((u) => u.path, 'path', email)
                .having(
                  (u) => u.toString(),
                  'toString',
                  allOf(contains('subject='), contains('body=')),
                ),
          ),
        ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'mailto URI inclui nome (no subject), email, tipo e mensagem '
      '(encoded, espacos como %20)',
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
        final subject = uri.queryParameters['subject'] ?? '';
        final body = uri.queryParameters['body'] ?? '';
        expect(subject, contains('Cliente & Cia'));
        expect(body, contains('Cliente & Cia'));
        expect(body, contains('cliente@teste.com'));
        expect(body, contains('cao & gato'));
        expect(body, contains(ProjectType.consulting.label));
        // Espacos devem ser %20 na forma crua (clientes de email exibem
        // `+` literal quando codificado via queryParameters).
        expect(uri.toString(), isNot(contains('+')));
        expect(uri.toString(), contains('%20'));
      },
    );

    blocTest<ContactBloc, ContactState>(
      'apos sucesso, ContactReset volta ao estado inicial',
      build: makeBloc,
      seed: () => ContactState(
        name: 'a',
        email: 'a@b.com',
        message: 'mensagem grande aqui',
        projectType: ProjectType.position,
        submission: ContactSubmissionSuccess(Uri.parse('mailto:x@y.com')),
      ),
      act: (bloc) => bloc.add(const ContactReset()),
      expect: () => [const ContactState.initial()],
    );
  });
}
