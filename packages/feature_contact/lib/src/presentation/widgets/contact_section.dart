import 'package:design_system/design_system.dart';
import 'package:feature_contact/src/presentation/bloc/contact_bloc.dart';
import 'package:feature_contact/src/presentation/widgets/contact_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Secao "Contato" — bloc + form + CTAs alternativos
/// (WhatsApp/email/LinkedIn/GitHub). Os callbacks de abertura sobem
/// para o app shell, que decide como abrir cada Uri (url_launcher,
/// `dart:html`, etc.).
class ContactSection extends StatelessWidget {
  const ContactSection({
    required this.whatsappNumber,
    this.email,
    this.linkedinUrl,
    this.githubUrl,
    this.onOpenUri,
    super.key,
  });

  /// E.164 sem `+` (ex.: `5571999990000`).
  final String whatsappNumber;
  final String? email;
  final String? linkedinUrl;
  final String? githubUrl;

  /// Disparado pelos CTAs alternativos e pelo form em sucesso. O shell
  /// sabe como executar (url_launcher / window.open).
  final ValueChanged<Uri>? onOpenUri;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final form = BlocProvider(
      create: (_) => ContactBloc(whatsappNumber: whatsappNumber),
      child: ContactForm(
        onSubmissionSuccess: (uri) => onOpenUri?.call(uri),
      ),
    );

    final ctas = _AlternateCtas(
      whatsappNumber: whatsappNumber,
      email: email,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      onOpenUri: onOpenUri,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Contato',
          title: 'Vamos',
          titleAccent: 'conversar?',
          subtitle:
              'Manda uma mensagem por aqui ou direto pelos canais '
              'abaixo. Respondo rapido durante a semana.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (isMobile) ...[
          form,
          const SizedBox(height: AppSpacing.xl),
          ctas,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: form),
              const SizedBox(width: AppSpacing.huge),
              Expanded(flex: 2, child: ctas),
            ],
          ),
      ],
    );
  }
}

class _AlternateCtas extends StatelessWidget {
  const _AlternateCtas({
    required this.whatsappNumber,
    required this.email,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.onOpenUri,
  });

  final String whatsappNumber;
  final String? email;
  final String? linkedinUrl;
  final String? githubUrl;
  final ValueChanged<Uri>? onOpenUri;

  void _open(BuildContext context, Uri uri) => onOpenUri?.call(uri);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final tiles = <Widget>[
      _CtaTile(
        key: const Key('contact-cta-whatsapp'),
        icon: Icons.chat_bubble_outline,
        label: 'WhatsApp direto',
        helper: '+$whatsappNumber',
        onTap: () => _open(
          context,
          Uri.https('wa.me', '/$whatsappNumber'),
        ),
      ),
      if (email != null)
        _CtaTile(
          key: const Key('contact-cta-email'),
          icon: Icons.mail_outline,
          label: 'Email',
          helper: email!,
          onTap: () => _open(context, Uri(scheme: 'mailto', path: email)),
        ),
      if (linkedinUrl != null)
        _CtaTile(
          key: const Key('contact-cta-linkedin'),
          icon: Icons.work_outline,
          label: 'LinkedIn',
          helper: linkedinUrl!,
          onTap: () => _open(context, Uri.parse(linkedinUrl!)),
        ),
      if (githubUrl != null)
        _CtaTile(
          key: const Key('contact-cta-github'),
          icon: Icons.code,
          label: 'GitHub',
          helper: githubUrl!,
          onTap: () => _open(context, Uri.parse(githubUrl!)),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ou direto:',
            style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            tiles[i],
          ],
        ],
      ),
    );
  }
}

class _CtaTile extends StatelessWidget {
  const _CtaTile({
    required this.icon,
    required this.label,
    required this.helper,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String helper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: textTheme.labelLarge
                            ?.copyWith(color: colors.onSurface),
                      ),
                      Text(
                        helper,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
