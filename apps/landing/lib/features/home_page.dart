import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:feature_services/feature_services.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:landing/widgets/home_footer.dart';
import 'package:landing/widgets/home_nav.dart';
import 'package:landing/widgets/labs_teaser_section.dart';
import 'package:landing/widgets/section_wave_divider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Home da landing — composta pelas feature_* na ordem do scroll.
/// Plugadas: Hero (§12.6) + Services (§12.7) + Showcase (§12.10) +
/// About (§12.8) + Labs teaser + Contact (§12.9), separadas por
/// `SectionWaveDivider` e envoltas em `GlowBackdrop` alternados.
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

  // Uma `GlobalKey` por secao navegavel — ancorada na arvore via
  // `KeyedSubtree`. As 5 ancoras do `HomeNav` (servicos, showcase,
  // sobre, labs, contato) usam estas pra calcular offset de scroll.
  final _servicesKey = GlobalKey(debugLabel: 'home-anchor-services');
  final _showcaseKey = GlobalKey(debugLabel: 'home-anchor-showcase');
  final _aboutKey = GlobalKey(debugLabel: 'home-anchor-about');
  final _labsKey = GlobalKey(debugLabel: 'home-anchor-labs');
  final _contactKey = GlobalKey(debugLabel: 'home-anchor-contact');

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final colors = context.colors;
    final isMobile = context.isMobile;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // Hero ocupa a viewport inteira (clamped) — sensacao "fold" classica
    // de landing moderna. O proprio Hero tem fade-out gradient no rodape
    // pra emendar com a primeira secao.
    final heroHeight = viewportHeight.clamp(640.0, 920.0);

    final horizontalPadding =
        isMobile ? AppSpacing.lg : AppSpacing.huge;

    final anchors = <HomeNavAnchor>[
      HomeNavAnchor(
        id: 'servicos',
        label: 'Serviços',
        onTap: () => _scrollToKey(_servicesKey),
      ),
      HomeNavAnchor(
        id: 'showcase',
        label: 'Showcase',
        onTap: () => _scrollToKey(_showcaseKey),
      ),
      HomeNavAnchor(
        id: 'sobre',
        label: 'Sobre',
        onTap: () => _scrollToKey(_aboutKey),
      ),
      HomeNavAnchor(
        id: 'labs',
        label: 'Labs',
        onTap: () => _scrollToKey(_labsKey),
      ),
      HomeNavAnchor(
        id: 'contato',
        label: 'Contato',
        onTap: () => _scrollToKey(_contactKey),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: heroHeight,
                  child: HeroSection(
                    onContactPressed: () => _scrollToKey(_contactKey),
                    onSeeProjectsPressed: () => _scrollToKey(_showcaseKey),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _servicesKey,
                  child: _SectionSlot(
                    horizontalPadding: horizontalPadding,
                    glowAlignment: Alignment.topRight,
                    child: const ServicesSection(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionWaveDivider()),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _showcaseKey,
                  child: _SectionSlot(
                    horizontalPadding: horizontalPadding,
                    glowAlignment: Alignment.topLeft,
                    child: const ShowcaseSection(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionWaveDivider()),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _aboutKey,
                  child: _SectionSlot(
                    horizontalPadding: horizontalPadding,
                    glowAlignment: Alignment.centerRight,
                    child: const AboutSection(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionWaveDivider()),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _labsKey,
                  child: _SectionSlot(
                    horizontalPadding: horizontalPadding,
                    glowAlignment: Alignment.topRight,
                    child: const LabsTeaserSection(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SectionWaveDivider()),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _contactKey,
                  child: _SectionSlot(
                    horizontalPadding: horizontalPadding,
                    glowAlignment: Alignment.centerLeft,
                    child: ContactSection(
                      // TODO(jose): trocar pelo numero do WhatsApp real.
                      whatsappNumber: '5571999990000',
                      email: 'contato.joseguilhermealves@gmail.com',
                      linkedinUrl:
                          'https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/',
                      githubUrl: 'https://github.com/JoseGuilhermeAlves',
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
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeNav(
              anchors: anchors,
              onLogoTap: _scrollToTop,
              onCtaTap: () => _scrollToKey(_contactKey),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper de secao: padding lateral + max-width centralizado +
/// GlowBackdrop sutil atras do conteudo. Centraliza o ritmo de spacing
/// e o "fundo decorativo" de cada secao num lugar so.
class _SectionSlot extends StatelessWidget {
  const _SectionSlot({
    required this.child,
    required this.horizontalPadding,
    required this.glowAlignment,
  });

  final Widget child;
  final double horizontalPadding;
  final Alignment glowAlignment;

  @override
  Widget build(BuildContext context) {
    return GlowBackdrop(
      alignment: glowAlignment,
      intensity: 0.08,
      radius: 0.45,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          // Spacing reduzido (96 -> 64) pra que a transicao entre
          // secoes nao "engula" tanto viewport — senao o usuario
          // mobile fica confuso sobre onde acaba uma e comeca outra.
          vertical: AppSpacing.huge,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: HomePage._maxContentWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
