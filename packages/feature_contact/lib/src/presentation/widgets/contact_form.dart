import 'package:design_system/design_system.dart';
import 'package:feature_contact/src/domain/project_type.dart';
import 'package:feature_contact/src/presentation/bloc/contact_bloc.dart';
import 'package:feature_contact/src/presentation/bloc/contact_event.dart';
import 'package:feature_contact/src/presentation/bloc/contact_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Form do contato. Espera um [ContactBloc] disponivel via
/// [BlocProvider] no contexto. Em sucesso, dispara [onSubmissionSuccess]
/// com a Uri pronta — o app shell decide como abrir.
class ContactForm extends StatefulWidget {
  const ContactForm({this.onSubmissionSuccess, super.key});

  final ValueChanged<Uri>? onSubmissionSuccess;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() => context.read<ContactBloc>().add(const ContactSubmitted());

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<ContactBloc, ContactState>(
      listenWhen: (prev, curr) => prev.submission != curr.submission,
      listener: (context, state) {
        final s = state.submission;
        if (s is ContactSubmissionSuccess) {
          widget.onSubmissionSuccess?.call(s.target);
        }
      },
      builder: (context, state) {
        final submitting = state.submission is ContactSubmissionSubmitting;
        final bloc = context.read<ContactBloc>();
        final l10n = context.l10n;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('contact-form-name'),
              controller: _name,
              enabled: !submitting,
              style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
              onChanged: (v) => bloc.add(ContactNameChanged(v)),
              decoration: _decoration(
                colors: colors,
                label: l10n.contact_formName,
                error: state.nameError,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('contact-form-email'),
              controller: _email,
              enabled: !submitting,
              keyboardType: TextInputType.emailAddress,
              style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
              onChanged: (v) => bloc.add(ContactEmailChanged(v)),
              decoration: _decoration(
                colors: colors,
                label: l10n.contact_formEmail,
                error: state.emailError,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<ProjectType>(
              key: const Key('contact-form-project-type'),
              initialValue: state.projectType,
              isExpanded: true,
              style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
              dropdownColor: colors.surface,
              decoration: _decoration(
                colors: colors,
                label: l10n.contact_formProjectType,
                error: state.projectTypeError,
              ),
              items: [
                for (final t in ProjectType.values)
                  DropdownMenuItem(
                    value: t,
                    child: Text(t.localizedLabel(l10n)),
                  ),
              ],
              onChanged: submitting
                  ? null
                  : (t) => bloc.add(ContactProjectTypeChanged(t)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const Key('contact-form-message'),
              controller: _message,
              enabled: !submitting,
              minLines: 3,
              maxLines: 5,
              style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
              onChanged: (v) => bloc.add(ContactMessageChanged(v)),
              decoration: _decoration(
                colors: colors,
                label: l10n.contact_formMessage,
                error: state.messageError,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              key: const Key('contact-form-submit'),
              label: submitting
                  ? l10n.contact_formSubmitting
                  : l10n.contact_formSubmit,
              onPressed: submitting ? null : _submit,
              icon: Icons.chat_bubble_outline,
              size: AppButtonSize.large,
              expand: true,
            ),
            if (state.submission is ContactSubmissionFailure) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                (state.submission as ContactSubmissionFailure).reason,
                style: textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ],
          ],
        );
      },
    );
  }

  InputDecoration _decoration({
    required AppColorScheme colors,
    required String label,
    String? error,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: error,
      filled: true,
      fillColor: colors.surface,
      labelStyle: TextStyle(color: colors.onSurfaceMuted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }
}
