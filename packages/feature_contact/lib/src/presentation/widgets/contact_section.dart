import 'package:design_system/design_system.dart';
import 'package:feature_contact/src/presentation/bloc/contact_bloc.dart';
import 'package:feature_contact/src/presentation/widgets/contact_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Secao "Contato" — fechamento da landing como tela "CONTINUE?" de
/// fliperama: um painel escuro com borda neon magenta + glow (sem cards
/// genericos), titulo em fonte pixel, e o email como link tipografico
/// grande que dispara o `mailto:` (funil primario). Links secundarios
/// (GitHub · LinkedIn · WhatsApp) em linha; o [ContactForm] estruturado
/// fica colapsado atras de um toggle — caminho secundario.
///
/// Mesma estrutura/acessibilidade da branch editorial, revestida na
/// identidade Arcade. O `ContactBloc` segue dono do `mailto:` montado.
class ContactSection extends StatefulWidget {
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

  /// Disparado pelos links e pelo form em sucesso. O shell sabe como
  /// executar (url_launcher / window.open).
  final ValueChanged<Uri>? onOpenUri;

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection>
    with SingleTickerProviderStateMixin {
  /// Form de mensagem estruturada comeca colapsado — o funil primario
  /// e o link de email direto; o form e secundario.
  bool _formExpanded = false;

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
        // Painel "CONTINUE?" — escuro, borda neon magenta + glow.
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
              // Eyebrow "INSERT COIN" piscante, ciano.
              FadeTransition(
                opacity: _blink,
                child: PixelText(
                  '~ INSERT COIN',
                  color: colors.accent,
                  pixelSize: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Titulo em fonte pixel com glow magenta. PixelText nao
              // quebra sozinho (largura intrinseca = chars x pixelSize),
              // entao no mobile separamos "VAMOS" / "CONVERSAR?" em duas
              // linhas via `\n` pra caber em viewports estreitos; no desktop
              // fica em linha unica. O FittedBox(scaleDown) e a rede de
              // seguranca: se mesmo a linha mais longa estourar (~360px),
              // o titulo encolhe em vez de sangrar pra fora do painel. O
              // label do Semantics mantem o texto corrido (sem `\n`) pro
              // leitor de tela.
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
              // Email gigante clicavel — funil mailto. Ciano com sublinhado;
              // no hover/focus engrossa e sobe pro onSurface pleno.
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
                onOpen: _open,
              ),
            ],
          ),
        ),
        // Form colapsado — caminho secundario, fora do painel.
        const SizedBox(height: AppSpacing.xl),
        BlocProvider(
          create: (_) => ContactBloc(email: widget.email),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FocusableLink(
                key: const Key('contact-form-toggle'),
                semanticsLabel: l10n.contact_formMessage,
                onTap: () => setState(() => _formExpanded = !_formExpanded),
                builder: ({required highlighted}) {
                  final ink = highlighted
                      ? colors.onSurface
                      : colors.onSurfaceMuted;
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 32),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.contact_formMessage,
                          style: textTheme.bodySmall?.copyWith(color: ink),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        AnimatedRotation(
                          turns: _formExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 160),
                          child: Icon(Icons.expand_more, size: 16, color: ink),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (_formExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ContactForm(onSubmissionSuccess: _open),
                  ),
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
    required this.onOpen,
  });

  final String? githubUrl;
  final String? linkedinUrl;
  final String? whatsappNumber;
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
