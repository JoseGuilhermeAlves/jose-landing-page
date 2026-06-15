import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:landing/config/app_config.dart';
import 'package:landing/widgets/arcade/arcade_hero.dart';
import 'package:landing/widgets/arcade/arcade_side_nav.dart';
import 'package:landing/widgets/engineering_section.dart';
import 'package:landing/widgets/home_bottom_nav.dart';
import 'package:landing/widgets/home_footer.dart';
import 'package:landing/widgets/home_nav.dart';
import 'package:landing/widgets/section_visibility.dart';
import 'package:landing/widgets/section_wave_divider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Home da landing — composta pelas feature_* na ordem do scroll.
/// Plugadas: Hero (§12.6) + Showcase (§12.10) + About (§12.8) +
/// Engineering (services + tech merged) + Contact (§12.9), separadas
/// por `SectionWaveDivider` e envoltas em `GlowBackdrop` alternados.
/// Cada secao vai dentro de um `SectionVisibility` que pausa os
/// tickers quando ela sai do viewport (e quando o sistema pede
/// animacoes reduzidas).
///
/// O `HomeNav` flutua no topo via Stack overlay, com 5 ancoras que
/// rolam a posicao via `ScrollController.animateTo`. O calculo do
/// offset usa `RenderAbstractViewport.getOffsetToReveal` menos a
/// altura do nav, pra que o eyebrow chip da secao destino fique
/// visivel logo abaixo da barra.
class HomePage extends StatefulWidget {
  const HomePage({super.key = const Key('home-page')});

  /// Limita a largura do conteudo das secoes pra que viewport
  /// ultra-wide nao estique paragrafos a ponto de quebrar a leitura.
  static const double _maxContentWidth = 1180;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  /// Indice da ancora ativa pra bottom nav mobile (scroll-spy). -1 = hero
  /// (nenhuma secao destacada ainda).
  final ValueNotifier<int> _activeIndex = ValueNotifier<int>(-1);

  // Uma `GlobalKey` por secao navegavel — ancorada na arvore via
  // `KeyedSubtree`. As 4 ancoras do `HomeNav` (showcase, sobre,
  // engenharia, contato) usam estas pra calcular offset de scroll.
  final _showcaseKey = GlobalKey(debugLabel: 'home-anchor-showcase');
  final _engineeringKey = GlobalKey(debugLabel: 'home-anchor-engineering');
  final _aboutKey = GlobalKey(debugLabel: 'home-anchor-about');
  final _contactKey = GlobalKey(debugLabel: 'home-anchor-contact');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _activeIndex.dispose();
    super.dispose();
  }

  /// Ultimo offset processado pelo scroll-spy — usado pra throttle.
  double? _lastSpyOffset;

  /// Scroll-spy pra bottom nav mobile: descobre qual secao esta sob o
  /// nav. Recalcula o offset de revelacao de cada ancora (mesmo metodo do
  /// `_scrollToKey`) e marca a ultima cujo topo ja passou pelo nav.
  ///
  /// Throttle por delta: `getOffsetToReveal` x4 por notificacao e caro;
  /// como a janela de decisao tem folga de 140px, recalcular so a cada
  /// 24px de deslocamento nao muda o resultado percebido.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final current = _scrollController.offset;
    final last = _lastSpyOffset;
    if (last != null && (current - last).abs() < 24) return;
    _lastSpyOffset = current;
    final keys = [_showcaseKey, _aboutKey, _engineeringKey, _contactKey];
    var active = -1;
    for (var i = 0; i < keys.length; i++) {
      final ctx = keys[i].currentContext;
      if (ctx == null) continue;
      final renderObject = ctx.findRenderObject();
      if (renderObject == null) continue;
      final reveal = RenderAbstractViewport.of(
        renderObject,
      ).getOffsetToReveal(renderObject, 0).offset;
      if (current >= reveal - kHomeNavHeight - 140) active = i;
    }
    if (active != _activeIndex.value) _activeIndex.value = active;
  }

  /// Anima o scroll ate que a secao identificada por [key] fique logo
  /// abaixo do `HomeNav`. Usa `RenderAbstractViewport` pra computar o
  /// offset exato — mais robusto que `Scrollable.ensureVisible`, que
  /// nao expoe ajuste fino de margem superior.
  Future<void> _scrollToKey(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;

    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final reveal = viewport.getOffsetToReveal(renderObject, 0).offset;
    final target = (reveal - kHomeNavHeight - AppSpacing.md).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Abre a [uri] no app externo apropriado (browser, mail client,
  /// WhatsApp). No web, [LaunchMode.externalApplication] equivale a
  /// `window.open(_blank)`. Engole falhas silenciosamente — falhar
  /// um CTA nao deve quebrar o resto da sessao.
  Future<void> _openExternalUri(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (error, stack) {
      // Reporta no console em debug; em release o usuario apenas nao
      // ve o app externo abrir — sem crash.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'apps/landing',
          context: ErrorDescription('opening external uri $uri'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // Hero ocupa a viewport inteira (clamped) — sensacao "fold" classica
    // de landing moderna. O proprio Hero tem fade-out gradient no rodape
    // pra emendar com a primeira secao.
    final heroHeight = viewportHeight.clamp(640.0, 920.0);

    final horizontalPadding = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.huge,
    );

    final anchors = <HomeNavAnchor>[
      HomeNavAnchor(
        id: 'showcase',
        label: context.l10n.nav_showcase,
        icon: Icons.grid_view_rounded,
        onTap: () => _scrollToKey(_showcaseKey),
      ),
      HomeNavAnchor(
        id: 'sobre',
        label: context.l10n.nav_about,
        icon: Icons.person_outline_rounded,
        onTap: () => _scrollToKey(_aboutKey),
      ),
      HomeNavAnchor(
        id: 'engenharia',
        label: context.l10n.nav_engineering,
        icon: Icons.terminal_rounded,
        onTap: () => _scrollToKey(_engineeringKey),
      ),
      HomeNavAnchor(
        id: 'contato',
        label: context.l10n.nav_contact,
        icon: Icons.mail_outline_rounded,
        onTap: () => _scrollToKey(_contactKey),
      ),
    ];

    return Scaffold(
      // Transparente pra revelar o ArcadeBackdrop global (starfield + grid).
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Desktop reserva a coluna esquerda pro menu lateral arcade.
          Padding(
            padding: EdgeInsets.only(left: isMobile ? 0 : kArcadeSideNavWidth),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SectionVisibility(
                    id: 'hero',
                    child: SizedBox(
                      height: heroHeight,
                      child: ArcadeHero(
                        // Funil recrutador: ambos os CTAs rolam dentro da
                        // pagina — primario pro contato, secundario pro
                        // showcase. WhatsApp/email moram na secao Contact.
                        onContactPressed: () => _scrollToKey(_contactKey),
                        onSeeProjectsPressed: () => _scrollToKey(_showcaseKey),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _showcaseKey,
                    child: _SectionSlot(
                      id: 'showcase',
                      horizontalPadding: horizontalPadding,
                      glowAlignment: Alignment.topLeft,
                      child: const ShowcaseSection(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SectionVisibility(
                    id: 'divider-showcase-about',
                    child: SectionWaveDivider(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _aboutKey,
                    child: _SectionSlot(
                      id: 'about',
                      horizontalPadding: horizontalPadding,
                      glowAlignment: Alignment.centerRight,
                      child: const AboutSection(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SectionVisibility(
                    id: 'divider-about-engineering',
                    child: SectionWaveDivider(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _engineeringKey,
                    child: _SectionSlot(
                      id: 'engineering',
                      horizontalPadding: horizontalPadding,
                      glowAlignment: Alignment.bottomRight,
                      child: EngineeringSection(
                        githubUrl: AppConfig.githubProfileUrl,
                        onOpenGithub: (url) => _openExternalUri(Uri.parse(url)),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SectionVisibility(
                    id: 'divider-engineering-contact',
                    child: SectionWaveDivider(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _contactKey,
                    child: _SectionSlot(
                      id: 'contact',
                      horizontalPadding: horizontalPadding,
                      glowAlignment: Alignment.centerLeft,
                      child: ContactSection(
                        whatsappNumber: AppConfig.whatsappNumber,
                        email: AppConfig.email,
                        linkedinUrl: AppConfig.linkedinUrl,
                        githubUrl: AppConfig.githubProfileUrl,
                        onOpenUri: _openExternalUri,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: HomeFooter(
                    startYear: 2026,
                    name: 'Jose Guilherme Alves',
                  ),
                ),
                // Mobile: reserva espaco no fim pra o footer nao ficar atras
                // da HomeBottomNav fixa.
                if (isMobile)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          kHomeBottomNavHeight +
                          MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
              ],
            ),
          ),
          // Desktop: menu lateral arcade (stage select). Mobile mantem o
          // top nav + bottom nav.
          if (!isMobile)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: ArcadeSideNav(
                anchors: anchors,
                activeIndex: _activeIndex,
                onLogoTap: _scrollToTop,
                githubUrl: AppConfig.githubProfileUrl,
                linkedinUrl: AppConfig.linkedinUrl,
                onOpenSocial: (url) => _openExternalUri(Uri.parse(url)),
              ),
            ),
          if (isMobile)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeNav(
                anchors: anchors,
                onLogoTap: _scrollToTop,
                onCtaTap: () => _scrollToKey(_contactKey),
                githubUrl: AppConfig.githubProfileUrl,
                linkedinUrl: AppConfig.linkedinUrl,
                onOpenSocial: (url) => _openExternalUri(Uri.parse(url)),
              ),
            ),
          // Bottom nav so na visao mobile — substitui o menu hamburger.
          if (isMobile)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ValueListenableBuilder<int>(
                valueListenable: _activeIndex,
                builder: (_, active, _) =>
                    HomeBottomNav(anchors: anchors, activeIndex: active),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wrapper de secao: padding lateral + max-width centralizado +
/// GlowBackdrop sutil atras do conteudo + `SectionVisibility` que pausa
/// os tickers da secao quando ela sai do viewport. Centraliza o ritmo
/// de spacing e o "fundo decorativo" de cada secao num lugar so.
class _SectionSlot extends StatelessWidget {
  const _SectionSlot({
    required this.id,
    required this.child,
    required this.horizontalPadding,
    required this.glowAlignment,
  });

  /// Identificador estavel da secao — repassado ao `SectionVisibility`.
  final String id;

  final Widget child;
  final double horizontalPadding;
  final Alignment glowAlignment;

  @override
  Widget build(BuildContext context) {
    return SectionVisibility(id: id, child: _buildSlot(context));
  }

  Widget _buildSlot(BuildContext context) {
    return GlowBackdrop(
      alignment: glowAlignment,
      intensity: 0.08,
      radius: 0.45,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          // Desktop usa 64 (reduzido de 96) pra dar respiro entre secoes.
          // Mobile aperta pra 24 — viewport curto nao pode gastar 128px
          // (topo+base) de whitespace por secao, senao o scroll vira um
          // tunel vazio entre blocos.
          vertical: context.responsive(
            mobile: AppSpacing.lg,
            desktop: AppSpacing.huge,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HomePage._maxContentWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
