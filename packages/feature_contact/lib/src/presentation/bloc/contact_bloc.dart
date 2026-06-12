import 'package:feature_contact/src/presentation/bloc/contact_event.dart';
import 'package:feature_contact/src/presentation/bloc/contact_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do form de contato. Submissao monta um `mailto:` com subject e
/// body pre-preenchidos — quem efetivamente abre a URI e o app shell
/// (a feature so produz a Uri). Email e o canal primario do funil
/// recrutador/tech lead; o form coleta o email do remetente e ele entra
/// no corpo da mensagem.
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc({required this.email}) : super(const ContactState.initial()) {
    on<ContactNameChanged>(_onNameChanged);
    on<ContactEmailChanged>(_onEmailChanged);
    on<ContactMessageChanged>(_onMessageChanged);
    on<ContactProjectTypeChanged>(_onProjectTypeChanged);
    on<ContactSubmitted>(_onSubmitted);
    on<ContactReset>(_onReset);
  }

  /// Endereco de destino do `mailto:` (email do Jose).
  final String email;

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

    final uri = _buildMailtoUri(state);
    emit(state.copyWith(submission: ContactSubmissionSuccess(uri)));
  }

  void _onReset(ContactReset event, Emitter<ContactState> emit) {
    emit(const ContactState.initial());
  }

  Uri _buildMailtoUri(ContactState s) {
    final type = s.projectType?.label ?? '—';
    final subject = 'Contato via site — ${s.name.trim()}';
    final body =
        '''
Nome: ${s.name.trim()}
Email: ${s.email.trim()}
Tipo: $type

${s.message.trim()}
''';
    // Montagem manual em vez de `Uri(queryParameters:)` — o construtor
    // codifica espaco como `+`, que clientes de email exibem literal.
    // `Uri.encodeComponent` usa `%20`, interpretado corretamente.
    return Uri.parse(
      'mailto:$email'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
  }
}
