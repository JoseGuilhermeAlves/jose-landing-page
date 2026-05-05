import 'package:equatable/equatable.dart';
import 'package:feature_contact/src/domain/project_type.dart';
import 'package:flutter/foundation.dart';

/// Estado do form de contato. Imutavel + Equatable.
///
/// `autoValidate` controla se as mensagens de erro aparecem inline.
/// Mantemos isso `false` ate o usuario tentar submeter pela primeira
/// vez — feedback de erro antes de digitar gera ansiedade.
@immutable
class ContactState extends Equatable {
  const ContactState({
    required this.name,
    required this.email,
    required this.message,
    this.projectType,
    this.autoValidate = false,
    this.submission = const ContactSubmissionInitial(),
  });

  const ContactState.initial()
      : name = '',
        email = '',
        message = '',
        projectType = null,
        autoValidate = false,
        submission = const ContactSubmissionInitial();

  final String name;
  final String email;
  final String message;
  final ProjectType? projectType;
  final bool autoValidate;
  final ContactSubmission submission;

  /// Validacao por campo. Retornam null quando OK, string com mensagem
  /// quando invalido. Mensagens so aparecem quando `autoValidate` e true.
  String? get nameError {
    if (!autoValidate) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Informe seu nome.';
    if (trimmed.length < 2) return 'Nome muito curto.';
    return null;
  }

  String? get emailError {
    if (!autoValidate) return null;
    final trimmed = email.trim();
    if (trimmed.isEmpty) return 'Informe seu email.';
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Email invalido.';
    }
    return null;
  }

  String? get messageError {
    if (!autoValidate) return null;
    final trimmed = message.trim();
    if (trimmed.length < 10) {
      return 'Conte um pouquinho a mais — pelo menos 10 caracteres.';
    }
    return null;
  }

  String? get projectTypeError {
    if (!autoValidate) return null;
    if (projectType == null) return 'Escolha o tipo de projeto.';
    return null;
  }

  /// Form valido = todos os campos sem erro **considerando** os
  /// criterios de validacao (independente de `autoValidate`).
  bool get isValid {
    final t = copyWith(autoValidate: true);
    return t.nameError == null &&
        t.emailError == null &&
        t.messageError == null &&
        t.projectTypeError == null;
  }

  ContactState copyWith({
    String? name,
    String? email,
    String? message,
    ProjectType? projectType,
    bool clearProjectType = false,
    bool? autoValidate,
    ContactSubmission? submission,
  }) {
    return ContactState(
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      projectType: clearProjectType ? null : (projectType ?? this.projectType),
      autoValidate: autoValidate ?? this.autoValidate,
      submission: submission ?? this.submission,
    );
  }

  @override
  List<Object?> get props =>
      [name, email, message, projectType, autoValidate, submission];

  // Padrao simples — pega "x@y.z" (sem cobrir todos os RFCs, mas
  // suficiente pra um landing page).
  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
  );
}

/// Status da submissao do form. Sealed pra forcar `switch` exaustivo.
sealed class ContactSubmission extends Equatable {
  const ContactSubmission();

  @override
  List<Object?> get props => const [];
}

class ContactSubmissionInitial extends ContactSubmission {
  const ContactSubmissionInitial();
}

class ContactSubmissionSubmitting extends ContactSubmission {
  const ContactSubmissionSubmitting();
}

class ContactSubmissionSuccess extends ContactSubmission {
  const ContactSubmissionSuccess(this.target);

  /// URL pronta pra abrir externamente — geralmente `wa.me/...`.
  final Uri target;

  @override
  List<Object?> get props => [target];
}

class ContactSubmissionFailure extends ContactSubmission {
  const ContactSubmissionFailure(this.reason);
  final String reason;

  @override
  List<Object?> get props => [reason];
}
