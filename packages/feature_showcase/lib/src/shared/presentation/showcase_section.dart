import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_demo.dart';
import 'package:feature_showcase/src/finance/presentation/finance_demo.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_demo.dart';
import 'package:feature_showcase/src/shared/data/showcase_catalog.dart';
import 'package:feature_showcase/src/shared/domain/showcase_template.dart';
import 'package:feature_showcase/src/shared/presentation/arcade_cabinet.dart';
import 'package:flutter/material.dart';

/// Secao "O que eu posso construir" — galeria de gabinetes de fliperama.
/// Cada gabinete mostra a **home real** do mock na tela (escalada, nao
/// interativa); tap "insere a ficha" e abre o demo completo fullscreen.
class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({this.onOpenDemo, super.key});

  /// Chamado com o id do template quando o usuario "insere a ficha". O
  /// shell decide como navegar — uma rota go_router, pra que a abertura
  /// do mock entre no historico do navegador (botao voltar fecha o mock
  /// em vez de sair do site). Nulo = fallback pra `Navigator.push`
  /// fullscreen, mantendo a secao utilizavel standalone (e nos testes,
  /// sem router).
  final ValueChanged<String>? onOpenDemo;

  /// Nome de marca exibido no marquee de cada gabinete.
  static const _brand = {
    'delivery': 'AURORA',
    'finance': 'MIRA',
    'realestate': 'SOLAR',
  };

  /// Cor do friso neon de cada gabinete — puxada da identidade do mock.
  static const _neon = {
    'finance': Color(0xFF2BF5C4),
    'delivery': Color(0xFFFF2E97),
    'realestate': Color(0xFFFFB547),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final templates = ShowcaseCatalog.all(l10n);

    final cabinets = [
      for (final t in templates)
        ArcadeCabinet(
          key: Key('showcase-cabinet-${t.id}'),
          label: _brand[t.id] ?? t.label.toUpperCase(),
          niche: t.label,
          description: t.description,
          actionLabel: l10n.showcase_openDemo,
          neon: _neon[t.id],
          enabled: t.hasDemo,
          preview: _previewFor(t.id),
          onTap: () => _openDemo(context, t),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonSectionHeading(
          index: '01',
          eyebrow: l10n.showcase_eyebrow,
          title: l10n.showcase_title,
          titleAccent: l10n.showcase_titleAccent,
          subtitle: l10n.showcase_subtitle,
        ),
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.lg,
            desktop: AppSpacing.xxl,
          ),
        ),
        if (context.isMobile)
          _ShowcaseCarousel(cabinets: cabinets)
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cabinets.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: cabinets[i],
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  void _openDemo(BuildContext context, ShowcaseTemplate template) {
    final open = onOpenDemo;
    if (open != null) {
      open(template.id);
      return;
    }
    // Fallback sem router: push imperativo fullscreen (standalone/testes).
    final demo = showcaseDemoById(template.id);
    if (demo == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => demo, fullscreenDialog: true),
    );
  }

  /// Preview = home real do mock, sem interatividade. Delivery roda sem
  /// ticker (corredor estatico) pra nao gastar frame budget na miniatura.
  Widget _previewFor(String id) =>
      _buildDemo(id, preview: true) ?? const SizedBox.shrink();
}

/// Constroi o demo completo (interativo) de um mock por id — pronto pra ser
/// hospedado numa rota go_router (`/demo/:id`) ou num push fullscreen. Null =
/// id desconhecido.
Widget? showcaseDemoById(String id) => _buildDemo(id, preview: false);

/// Constroi o widget de demo por id. [preview] desliga o ticker do delivery
/// na miniatura; no fullscreen ele roda normalmente.
Widget? _buildDemo(String id, {required bool preview}) {
  return switch (id) {
    'delivery' => DeliveryDemo(
      ticker: preview
          ? null
          : Stream<void>.periodic(const Duration(seconds: 2)),
    ),
    'realestate' => const RealEstateDemo(),
    'finance' => const FinanceDemo(),
    _ => null,
  };
}

/// Carrossel "stage select" do mobile: um gabinete por vez (PageView com
/// peek do vizinho), bolinhas de pagina e setas ‹ ›. Evita a pilha vertical
/// gigante dos 5 gabinetes empilhados. Como e PageView.builder, so monta os
/// previews proximos da pagina atual — mais leve que o Wrap (que monta os 5).
class _ShowcaseCarousel extends StatefulWidget {
  const _ShowcaseCarousel({required this.cabinets});

  final List<Widget> cabinets;

  @override
  State<_ShowcaseCarousel> createState() => _ShowcaseCarouselState();
}

class _ShowcaseCarouselState extends State<_ShowcaseCarousel> {
  static const double _viewportFraction = 0.86;

  /// Altura fixa do gabinete fora da tela (marquee + deck + porta) mais a
  /// legenda abaixo dele.
  static const double _cabinetChrome = 162 + 170;

  late final PageController _controller = PageController(
    viewportFraction: _viewportFraction,
  );
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final target = page.clamp(0, widget.cabinets.length - 1);
    _controller.animateToPage(
      target,
      duration: AppDuration.base,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth * _viewportFraction;
        final screenWidth = pageWidth - AppSpacing.sm * 2 - 48;
        final cabinetHeight = _cabinetChrome + screenWidth * 4 / 3;

        return Column(
          children: [
            SizedBox(
              height: cabinetHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.cabinets.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: widget.cabinets[i],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Arrow(
                  glyph: '<',
                  enabled: _page > 0,
                  onTap: () => _goTo(_page - 1),
                ),
                const SizedBox(width: AppSpacing.md),
                for (var i = 0; i < widget.cabinets.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      width: i == _page ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? colors.primary
                            : colors.onSurfaceMuted.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.md),
                _Arrow(
                  glyph: '>',
                  enabled: _page < widget.cabinets.length - 1,
                  onTap: () => _goTo(_page + 1),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Seta ‹ › em fonte pixel; apagada quando nao ha pra onde ir.
class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.glyph,
    required this.enabled,
    required this.onTap,
  });

  final String glyph;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: PixelText(
            glyph,
            color: enabled ? colors.accent : colors.onSurfaceMuted,
            pixelSize: 4,
          ),
        ),
      ),
    );
  }
}
