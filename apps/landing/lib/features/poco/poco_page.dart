import 'dart:ui' as ui;

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

/// "Title screen" do jogo: arte de titulo do Poço escurecida ao fundo, logo
/// em pixel neon, subtitulo oficial ("O desejo de Pick"), CTAs e chao
/// Outrun.
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
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isMobile = context.isMobile;
    final h = MediaQuery.sizeOf(context).height.clamp(620.0, 900.0);

    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arte de titulo do jogo, apagada e tingida pra servir de cenario.
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0, 0.6, 1],
            ).createShader,
            child: Opacity(
              opacity: 0.3,
              // Blur forte: a arte vira atmosfera e o logo/menu originais do
              // jogo nao competem com o logo neon.
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Image.asset(
                  'assets/images/poco/title-art.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.3),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.9,
                colors: [
                  colors.background.withValues(alpha: 0.2),
                  colors.background.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isMobile ? 120 : 190,
            child: HorizonFloor(near: colors.primary, far: colors.accent),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              kPocoTopBarHeight + AppSpacing.xl,
              AppSpacing.lg,
              isMobile ? 120 : 170,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.poco_status.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: tt.labelMedium?.copyWith(
                      color: colors.accent,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PocoLogo(pixelSize: isMobile ? 11 : 20),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.poco_subtitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: (isMobile ? tt.titleSmall : tt.titleMedium)
                        ?.copyWith(
                          color: colors.onSurface,
                          letterSpacing: isMobile ? 4 : 7,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Text(
                      l10n.game_subtitle,
                      textAlign: TextAlign.center,
                      style: (isMobile ? tt.bodyLarge : tt.titleLarge)
                          ?.copyWith(
                            color: colors.onSurface,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      NeonButton(
                        label: l10n.poco_ctaDownload,
                        filled: true,
                        pixel: true,
                        onPressed: onDownload,
                      ),
                      NeonButton(
                        label: l10n.poco_ctaTrailer,
                        color: colors.accent,
                        pixel: true,
                        onPressed: onTrailer,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.game_metaLine(version),
                    style: tt.bodySmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
