import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Secao "Contato" — fechamento da landing como tela "CONTINUE?" de
/// fliperama: um painel escuro com borda neon magenta + glow (sem cards
/// genericos), titulo em fonte pixel, e o email como link tipografico
/// grande que dispara o `mailto:` (funil primario). Links secundarios
/// (GitHub · LinkedIn · WhatsApp · currículo PDF) em linha.
///
/// Mesma estrutura/acessibilidade da branch editorial, revestida na
/// identidade Arcade.
class ContactSection extends StatefulWidget {
  const ContactSection({
    required this.email,
    this.whatsappNumber,
    this.linkedinUrl,
    this.githubUrl,
    this.resumeUrl,
    this.onOpenUri,
    super.key,
  });

  /// Email de destino — canal primario e destino do `mailto:`.
  final String email;

  /// E.164 sem `+` (ex.: `5571999990000`). Canal alternativo.
  final String? whatsappNumber;
  final String? linkedinUrl;
  final String? githubUrl;

  /// URL do currículo em PDF (resolvida pelo shell conforme o idioma
  /// atual — PT ou EN). Abre num link secundario "Baixar currículo".
  final String? resumeUrl;

  /// Disparado pelos links. O shell sabe como executar
  /// (url_launcher / window.open).
  final ValueChanged<Uri>? onOpenUri;

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection>
    with SingleTickerProviderStateMixin {
  /// Pisca do eyebrow "INSERT COIN".
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _blink
        ..stop()
        ..value = 1;
    } else if (!_blink.isAnimating) {
      _blink.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  void _open(Uri uri) => widget.onOpenUri?.call(uri);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final panelPadding = context.responsive<double>(
      mobile: AppSpacing.xl,
      desktop: 56,
    );
    final titlePixel = context.responsive<double>(mobile: 5, desktop: 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(panelPadding),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            border: Border.all(color: colors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.35),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _blink,
                child: PixelText(
                  '~ INSERT COIN',
                  color: colors.accent,
                  pixelSize: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                label: '${l10n.contact_title} ${l10n.contact_titleAccent}',
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: PixelText(
                    context.isMobile
                        ? '${l10n.contact_title}\n${l10n.contact_titleAccent}'
                              .toUpperCase()
                        : '${l10n.contact_title} ${l10n.contact_titleAccent}'
                              .toUpperCase(),
                    color: colors.primary,
                    glowColor: colors.primary,
                    glowBlur: 12,
                    pixelSize: titlePixel,
                    lineSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  l10n.contact_subtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _FocusableLink(
                key: const Key('contact-cta-email'),
                semanticsLabel: l10n.contact_ctaEmail,
                onTap: () => _open(Uri(scheme: 'mailto', path: widget.email)),
                builder: ({required highlighted}) {
                  final ink = highlighted ? colors.onSurface : colors.accent;
                  return Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: highlighted
                              ? colors.accent
                              : colors.accent.withValues(alpha: 0.5),
                          width: highlighted ? 2 : 1,
                        ),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.email,
                        style: context
                            .responsive(
                              mobile: textTheme.headlineSmall,
                              desktop: textTheme.headlineMedium,
                            )
                            ?.copyWith(color: ink),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SecondaryLinks(
                githubUrl: widget.githubUrl,
                linkedinUrl: widget.linkedinUrl,
                whatsappNumber: widget.whatsappNumber,
                resumeUrl: widget.resumeUrl,
                onOpen: _open,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha de links secundarios em texto puro: GitHub · LinkedIn ·
/// WhatsApp, onSurfaceMuted subindo pro ciano no hover/focus.
class _SecondaryLinks extends StatelessWidget {
  const _SecondaryLinks({
    required this.githubUrl,
    required this.linkedinUrl,
    required this.whatsappNumber,
    required this.resumeUrl,
    required this.onOpen,
  });

  final String? githubUrl;
  final String? linkedinUrl;
  final String? whatsappNumber;
  final String? resumeUrl;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    Widget link({required Key key, required String label, required Uri uri}) {
      return _FocusableLink(
        key: key,
        semanticsLabel: label,
        onTap: () => onOpen(uri),
        builder: ({required highlighted}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: highlighted ? colors.accent : colors.onSurfaceMuted,
            ),
          ),
        ),
      );
    }

    final links = <Widget>[
      if (githubUrl != null)
        link(
          key: const Key('contact-cta-github'),
          label: l10n.contact_ctaGithub,
          uri: Uri.parse(githubUrl!),
        ),
      if (linkedinUrl != null)
        link(
          key: const Key('contact-cta-linkedin'),
          label: l10n.contact_ctaLinkedin,
          uri: Uri.parse(linkedinUrl!),
        ),
      if (whatsappNumber != null)
        link(
          key: const Key('contact-cta-whatsapp'),
          label: l10n.contact_ctaWhatsapp,
          uri: Uri.https('wa.me', '/$whatsappNumber'),
        ),
      if (resumeUrl != null)
        link(
          key: const Key('contact-cta-resume'),
          label: l10n.contact_ctaResume,
          uri: Uri.parse(resumeUrl!),
        ),
    ];
    if (links.isEmpty) return const SizedBox.shrink();

    final separator = Text(
      '·',
      style: textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceMuted.withValues(alpha: 0.6),
      ),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xxs,
      children: [
        for (var i = 0; i < links.length; i++) ...[
          if (i > 0) separator,
          links[i],
        ],
      ],
    );
  }
}

/// Link de texto acessivel: hover e foco por teclado compartilham o
/// mesmo highlight, Enter/Espaco ativam via [ActivateIntent]. O visual
/// fica por conta do [builder], que recebe o estado consolidado.
class _FocusableLink extends StatefulWidget {
  const _FocusableLink({
    required this.semanticsLabel,
    required this.onTap,
    required this.builder,
    super.key,
  });

  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget Function({required bool highlighted}) builder;

  @override
  State<_FocusableLink> createState() => _FocusableLinkState();
}

class _FocusableLinkState extends State<_FocusableLink> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;

    return Semantics(
      link: true,
      label: widget.semanticsLabel,
      onTap: onTap,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
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
          child: widget.builder(highlighted: _hovered || _focused),
        ),
      ),
    );
  }
}
