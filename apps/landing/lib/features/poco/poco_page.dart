import 'package:design_system/design_system.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/config/app_config.dart';
import 'package:landing/features/poco/poco_sections.dart';
import 'package:landing/features/poco/poco_widgets.dart';
import 'package:landing/router/route_paths.dart';
import 'package:landing/widgets/arcade/crt_overlay.dart';
import 'package:landing/widgets/open_external.dart';

/// Landing gamificada do Poço (`/poco`) — a "pagina de loja" do jogo, na
/// arquitetura de informacao de uma pagina itch.io (capa -> trailer ->
/// destaques -> herois -> galeria -> controles -> ficha + download), vestida
/// na estetica neon da zeguidev. Aqui o fliperama e o assunto, entao a
/// fonte pixel, o CRT e o "PRESS START" sao bem-vindos.
///
/// [focus] = `download` rola direto pro bloco de download (CTA "Baixar demo"
/// do teaser da home).
class PocoPage extends StatefulWidget {
  const PocoPage({this.focus, super.key});

  final String? focus;

  static const double _maxWidth = 1120;

  @override
  State<PocoPage> createState() => _PocoPageState();
}

class _PocoPageState extends State<PocoPage> {
  final _scroll = ScrollController();
  final _trailerKey = GlobalKey(debugLabel: 'poco-trailer');
  final _downloadKey = GlobalKey(debugLabel: 'poco-download');

  @override
  void initState() {
    super.initState();
    if (widget.focus == 'download') {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollTo(_downloadKey, animate: false),
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key, {bool animate = true}) async {
    final ro = key.currentContext?.findRenderObject();
    if (ro == null || !_scroll.hasClients) return;
    final target =
        (RenderAbstractViewport.of(ro).getOffsetToReveal(ro, 0).offset -
                kPocoTopBarHeight -
                AppSpacing.lg)
            .clamp(0.0, _scroll.position.maxScrollExtent);
    if (!animate) {
      _scroll.jumpTo(target);
      return;
    }
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;
    final gutter = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.huge,
    );
    final gap = context.responsive<double>(mobile: 72, desktop: 128);

    Widget section(Widget child, {Key? key}) => Padding(
      key: key,
      padding: EdgeInsets.fromLTRB(gutter, 0, gutter, gap),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: PocoPage._maxWidth),
          child: child,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: PocoTitleScreen(
                  version: AppConfig.pocoDemoVersion,
                  onDownload: () => _scrollTo(_downloadKey),
                  onTrailer: () => _scrollTo(_trailerKey),
                ),
              ),
              SliverToBoxAdapter(
                child: section(
                  key: _trailerKey,
                  const PocoTrailerSection(
                    trailerUrl: AppConfig.pocoTrailerUrl,
                    posterAsset: AppConfig.pocoTrailerPosterAsset,
                    gameplayTrailerUrl: AppConfig.pocoGameplayTrailerUrl,
                    gameplayPosterAsset:
                        AppConfig.pocoGameplayTrailerPosterAsset,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: section(const PocoFeaturesSection())),
              SliverToBoxAdapter(child: section(const PocoHeroesSection())),
              SliverToBoxAdapter(child: section(const PocoGallerySection())),
              SliverToBoxAdapter(child: section(const PocoControlsSection())),
              SliverToBoxAdapter(
                child: section(
                  key: _downloadKey,
                  const PocoDownloadSection(
                    version: AppConfig.pocoDemoVersion,
                    windowsUrl: AppConfig.pocoDemoWindowsUrl,
                    androidUrl: AppConfig.pocoDemoAndroidUrl,
                    onOpenUri: openExternalUri,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: PocoFooter(
                  email: AppConfig.email,
                  onOpenUri: openExternalUri,
                  onBack: _back,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PocoTopBar(
              version: AppConfig.pocoDemoVersion,
              onBack: _back,
              onDownload: () => _scrollTo(_downloadKey),
            ),
          ),
          // CRT so nesta pagina — aqui o fliperama e o assunto. Leve, pra
          // nao custar a leitura.
          if (!isMobile)
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: CrtOverlay(tint: colors.onSurface),
              ),
            ),
        ],
      ),
    );
  }
}

/// Altura da barra superior fixa da pagina do Poço.
const double kPocoTopBarHeight = 64;

/// Barra HUD fixa: voltar pra zeguidev, logo pequeno, versao e download.
class PocoTopBar extends StatelessWidget {
  const PocoTopBar({
    required this.version,
    required this.onBack,
    required this.onDownload,
    super.key,
  });

  final String version;
  final VoidCallback onBack;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;
    final l10n = context.l10n;

    return Container(
      height: kPocoTopBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(
          mobile: AppSpacing.md,
          desktop: AppSpacing.xl,
        ),
      ),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.88),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l10n.poco_back,
            excludeSemantics: true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (isMobile)
                      Text(
                        'zeguidev',
                        style: tt.labelLarge?.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      )
                    else
                      Text(
                        l10n.poco_back,
                        style: tt.labelLarge?.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            PixelText('1UP', color: colors.primary, pixelSize: 2),
            const SizedBox(width: AppSpacing.sm),
            PixelText(
              version.toUpperCase(),
              color: colors.onSurfaceMuted,
              pixelSize: 2,
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          NeonButton(
            label: l10n.poco_ctaDownload,
            filled: true,
            dense: true,
            icon: Icons.download_rounded,
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}

/// Approved key art, kept intact at every screen width.
class PocoTitleScreen extends StatelessWidget {
  const PocoTitleScreen({
    required this.version,
    required this.onDownload,
    required this.onTrailer,
    super.key,
  });
  final String version;
  final VoidCallback onDownload;
  final VoidCallback onTrailer;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final art = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 350 : 390),
          child: Image.asset(
            'assets/images/poco/picks-wish-cover.png',
            fit: BoxFit.contain,
            semanticLabel: "Pick's Wish",
          ),
        );
        final copy = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: compact
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              l10n.poco_status.toUpperCase(),
              style: tt.labelMedium?.copyWith(
                color: const Color(0xffb49b62),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.game_subtitle,
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: tt.headlineSmall?.copyWith(
                color: const Color(0xffded9c6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              alignment: compact ? WrapAlignment.center : WrapAlignment.start,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                NeonButton(
                  label: l10n.poco_ctaDownload,
                  filled: true,
                  pixel: true,
                  color: const Color(0xffb49b62),
                  onPressed: onDownload,
                ),
                NeonButton(
                  label: l10n.poco_ctaTrailer,
                  pixel: true,
                  color: const Color(0xff8b9a88),
                  onPressed: onTrailer,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.game_metaLine(version),
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: tt.bodySmall?.copyWith(color: const Color(0xffb5b7ab)),
            ),
          ],
        );
        return ColoredBox(
          color: const Color(0xff111315),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 24 : 48,
              kPocoTopBarHeight + 32,
              compact ? 24 : 48,
              72,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: compact
                    ? Column(children: [art, const SizedBox(height: 32), copy])
                    : Row(
                        children: [
                          Expanded(flex: 5, child: art),
                          const SizedBox(width: 64),
                          Expanded(flex: 6, child: copy),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
