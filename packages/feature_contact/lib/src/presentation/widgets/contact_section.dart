import 'package:design_system/design_system.dart';
import 'package:feature_contact/src/presentation/bloc/contact_bloc.dart';
import 'package:feature_contact/src/presentation/widgets/contact_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Secao "Contato" — bloc + form + CTAs diretos. Funil voltado a
/// recrutador/tech lead: Email, LinkedIn e GitHub sao os canais
/// primarios; WhatsApp fica como alternativo. Os callbacks de abertura
/// sobem para o app shell, que decide como abrir cada Uri
/// (url_launcher, `dart:html`, etc.).
class ContactSection extends StatelessWidget {
  const ContactSection({
    required this.email,
    this.whatsappNumber,
    this.linkedinUrl,
    this.githubUrl,
    this.onOpenUri,
    super.key,
  });

  /// Email de destino — canal primario e destino do `mailto:` do form.
  final String email;

  /// E.164 sem `+` (ex.: `5571999990000`). Canal alternativo.
  final String? whatsappNumber;
  final String? linkedinUrl;
  final String? githubUrl;

  /// Disparado pelos CTAs alternativos e pelo form em sucesso. O shell
  /// sabe como executar (url_launcher / window.open).
  final ValueChanged<Uri>? onOpenUri;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final form = BlocProvider(
      create: (_) => ContactBloc(email: email),
      child: ContactForm(onSubmissionSuccess: (uri) => onOpenUri?.call(uri)),
    );

    final ctas = _AlternateCtas(
      whatsappNumber: whatsappNumber,
      email: email,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      onOpenUri: onOpenUri,
    );

    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: l10n.contact_eyebrow,
          title: l10n.contact_title,
          titleAccent: l10n.contact_titleAccent,
          subtitle: l10n.contact_subtitle,
        ),
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.lg,
            desktop: AppSpacing.xxl,
          ),
        ),
        if (isMobile) ...[
          form,
          const SizedBox(height: AppSpacing.lg),
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

  final String? whatsappNumber;
  final String email;
  final String? linkedinUrl;
  final String? githubUrl;
  final ValueChanged<Uri>? onOpenUri;

  void _open(BuildContext context, Uri uri) => onOpenUri?.call(uri);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final l10n = context.l10n;

    // Ordem reflete o funil recrutador/tech lead: Email -> LinkedIn ->
    // GitHub como primarios; WhatsApp por ultimo, como alternativo.
    final tiles = <Widget>[
      _CtaTile(
        key: const Key('contact-cta-email'),
        icon: Icons.mail_outline,
        label: l10n.contact_ctaEmail,
        helper: email,
        onTap: () => _open(context, Uri(scheme: 'mailto', path: email)),
      ),
      if (linkedinUrl != null)
        _CtaTile(
          key: const Key('contact-cta-linkedin'),
          icon: Icons.work_outline,
          label: l10n.contact_ctaLinkedin,
          helper: linkedinUrl!,
          onTap: () => _open(context, Uri.parse(linkedinUrl!)),
        ),
      if (githubUrl != null)
        _CtaTile(
          key: const Key('contact-cta-github'),
          icon: Icons.code,
          label: l10n.contact_ctaGithub,
          helper: githubUrl!,
          onTap: () => _open(context, Uri.parse(githubUrl!)),
        ),
      if (whatsappNumber != null)
        _CtaTile(
          key: const Key('contact-cta-whatsapp'),
          icon: Icons.chat_bubble_outline,
          label: l10n.contact_ctaWhatsapp,
          helper: '+$whatsappNumber',
          onTap: () => _open(context, Uri.https('wa.me', '/$whatsappNumber')),
        ),
    ];

    return Container(
      padding: EdgeInsets.all(context.isMobile ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contact_orDirect,
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

class _CtaTile extends StatefulWidget {
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
  State<_CtaTile> createState() => _CtaTileState();
}

class _CtaTileState extends State<_CtaTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final icon = widget.icon;
    final label = widget.label;
    final helper = widget.helper;
    final onTap = widget.onTap;

    // FocusableActionDetector adiciona foco por Tab e ativacao por
    // Enter/Espaco (ActivateIntent cobre os dois atalhos) — mesmo
    // pattern do AppButton do design_system. Focus ring discreto via
    // boxShadow spread no token primary, visivel so em navegacao por
    // teclado (onShowFocusHighlight filtra foco por toque/clique).
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.55),
                          spreadRadius: 2,
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
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
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            helper,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
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
        ),
      ),
    );
  }
}
