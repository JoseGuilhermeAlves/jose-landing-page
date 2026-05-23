import 'package:feature_contact/feature_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactState validations', () {
    const initial = ContactState.initial();

    test('estado inicial tem campos vazios e nao auto-valida', () {
      expect(initial.name, isEmpty);
      expect(initial.email, isEmpty);
      expect(initial.message, isEmpty);
      expect(initial.projectType, isNull);
      expect(initial.autoValidate, isFalse);
      expect(initial.submission, isA<ContactSubmissionInitial>());
    });

    test('isValid e false quando nao ha campo preenchido', () {
      expect(initial.isValid, isFalse);
    });

    test('nameError so aparece com autoValidate ativo', () {
      const without = ContactState.initial();
      const withAuto = ContactState(
        name: '',
        email: '',
        message: '',
        autoValidate: true,
      );

      expect(without.nameError, isNull);
      expect(withAuto.nameError, isNotNull);
    });

    test('nameError pega nome vazio e nome muito curto', () {
      expect(
        const ContactState(
          name: '',
          email: '',
          message: '',
          autoValidate: true,
        ).nameError,
        isNotNull,
      );
      expect(
        const ContactState(
          name: 'A',
          email: '',
          message: '',
          autoValidate: true,
        ).nameError,
        isNotNull,
      );
      expect(
        const ContactState(
          name: 'Ana Souza',
          email: '',
          message: '',
          autoValidate: true,
        ).nameError,
        isNull,
      );
    });

    test('emailError pega vazio e formato invalido', () {
      ContactState s(String email) =>
          ContactState(name: '', email: email, message: '', autoValidate: true);
      expect(s('').emailError, isNotNull);
      expect(s('notanemail').emailError, isNotNull);
      expect(s('a@b').emailError, isNotNull);
      expect(s('jose@gmail.com').emailError, isNull);
    });

    test('messageError exige minimo de 10 caracteres', () {
      ContactState s(String msg) =>
          ContactState(name: '', email: '', message: msg, autoValidate: true);
      expect(s('').messageError, isNotNull);
      expect(s('curto').messageError, isNotNull);
      expect(s('mensagem boa').messageError, isNull);
    });

    test('projectTypeError exige selecao', () {
      const a = ContactState(
        name: '',
        email: '',
        message: '',
        autoValidate: true,
      );
      expect(a.projectTypeError, isNotNull);

      final b = a.copyWith(projectType: ProjectType.values.first);
      expect(b.projectTypeError, isNull);
    });

    test('isValid: true so quando todos os campos passam', () {
      final ok = ContactState(
        name: 'Jose Guilherme',
        email: 'jose@example.com',
        message: 'Quero conversar sobre app novo.',
        projectType: ProjectType.values.first,
      );
      expect(ok.isValid, isTrue);

      expect(ok.copyWith(name: '').isValid, isFalse);
      expect(ok.copyWith(email: 'invalid').isValid, isFalse);
      expect(ok.copyWith(message: 'curto').isValid, isFalse);
      expect(ok.copyWith(clearProjectType: true).isValid, isFalse);
    });

    test('valor: dois ContactState identicos sao iguais', () {
      const a = ContactState(name: 'a', email: 'b', message: 'c');
      const b = ContactState(name: 'a', email: 'b', message: 'c');
      expect(a, equals(b));
    });

    test('copyWith preserva campos nao mencionados', () {
      const a = ContactState(name: 'a', email: 'b', message: 'c');
      final b = a.copyWith(email: 'novo');
      expect(b.name, 'a');
      expect(b.email, 'novo');
      expect(b.message, 'c');
    });
  });

  group('ContactSubmission variants', () {
    test('Initial != Submitting != Success != Failure', () {
      final success = ContactSubmissionSuccess(Uri.parse('https://wa.me/123'));
      const failure = ContactSubmissionFailure('boom');

      expect(
        const ContactSubmissionInitial(),
        isNot(equals(const ContactSubmissionSubmitting())),
      );
      expect(success, isNot(equals(failure)));
    });

    test('Success expoe a Uri pra abrir', () {
      final success = ContactSubmissionSuccess(Uri.parse('https://wa.me/55x'));
      expect(success.target.toString(), contains('wa.me'));
    });
  });
}
