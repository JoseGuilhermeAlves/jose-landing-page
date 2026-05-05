import 'package:equatable/equatable.dart';
import 'package:feature_contact/src/domain/project_type.dart';

/// Events do form de contato. Sealed pra forcar `switch` exaustivo no
/// handler do bloc.
sealed class ContactEvent extends Equatable {
  const ContactEvent();

  @override
  List<Object?> get props => const [];
}

class ContactNameChanged extends ContactEvent {
  const ContactNameChanged(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

class ContactEmailChanged extends ContactEvent {
  const ContactEmailChanged(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class ContactMessageChanged extends ContactEvent {
  const ContactMessageChanged(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ContactProjectTypeChanged extends ContactEvent {
  const ContactProjectTypeChanged(this.projectType);
  final ProjectType? projectType;

  @override
  List<Object?> get props => [projectType];
}

class ContactSubmitted extends ContactEvent {
  const ContactSubmitted();
}

class ContactReset extends ContactEvent {
  const ContactReset();
}
