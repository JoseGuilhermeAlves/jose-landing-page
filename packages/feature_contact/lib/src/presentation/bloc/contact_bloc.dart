import 'package:feature_contact/src/presentation/bloc/contact_event.dart';
import 'package:feature_contact/src/presentation/bloc/contact_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do form de contato. Submissao monta um `wa.me/<numero>?text=...`
/// — quem efetivamente abre a URL e o app shell (a feature so produz
/// a Uri).
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc({required this.whatsappNumber})
    : super(const ContactState.initial()) {
    on<ContactNameChanged>(_onNameChanged);
    on<ContactEmailChanged>(_onEmailChanged);
    on<ContactMessageChanged>(_onMessageChanged);
    on<ContactProjectTypeChanged>(_onProjectTypeChanged);
    on<ContactSubmitted>(_onSubmitted);
    on<ContactReset>(_onReset);
  }

  /// Numero E.164 sem `+` nem espacos (ex.: `5571999990000`). Usado na
  /// URI `wa.me/<numero>`.
  final String whatsappNumber;

  void _onNameChanged(ContactNameChanged event, Emitter<ContactState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onEmailChanged(ContactEmailChanged event, Emitter<ContactState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void _onMessageChanged(
    ContactMessageChanged event,
    Emitter<ContactState> emit,
  ) {
    emit(state.copyWith(message: event.message));
  }

  void _onProjectTypeChanged(
    ContactProjectTypeChanged event,
    Emitter<ContactState> emit,
  ) {
    if (event.projectType == null) {
      emit(state.copyWith(clearProjectType: true));
    } else {
      emit(state.copyWith(projectType: event.projectType));
    }
  }

  Future<void> _onSubmitted(
    ContactSubmitted event,
    Emitter<ContactState> emit,
  ) async {
    if (!state.isValid) {
      // Liga validacao inline pra que erros aparecam abaixo dos campos.
      emit(state.copyWith(autoValidate: true));
      return;
    }

    emit(
      state.copyWith(
        submission: const ContactSubmissionSubmitting(),
        autoValidate: true,
      ),
    );

    final uri = _buildWhatsappUri(state);
    emit(state.copyWith(submission: ContactSubmissionSuccess(uri)));
  }

  void _onReset(ContactReset event, Emitter<ContactState> emit) {
    emit(const ContactState.initial());
  }

  Uri _buildWhatsappUri(ContactState s) {
    final type = s.projectType?.label ?? '—';
    final body =
        '''
Ola, Jose! Vim pelo seu site.

Nome: ${s.name.trim()}
Email: ${s.email.trim()}
Tipo: $type

${s.message.trim()}
''';
    return Uri.https('wa.me', '/$whatsappNumber', {'text': body});
  }
}
