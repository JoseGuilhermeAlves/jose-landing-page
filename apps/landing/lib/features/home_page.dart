import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:feature_services/feature_services.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/home_footer.dart';
import 'package:landing/widgets/labs_teaser_section.dart';
import 'package:landing/widgets/section_wave_divider.dart';

/// Home da landing — composta pelas feature_* na ordem do scroll.
/// Plugadas: Hero (§12.6) + Services (§12.7) + Showcase (§12.10) +
/// About (§12.8) + Contact (§12.9), separadas por `SectionWaveDivider`
/// e envoltas em `GlowBackdrop` alternados pra dar profundidade
/// visual.
class HomePage extends StatelessWidget {
  const HomePage({super.key = const Key('home-page')});

  /// Limita a largura do conteudo das secoes pra que viewport
  /// ultra-wide nao estique paragrafos a ponto de quebrar a leitura.
  static const double _maxContentWidth = 1180;

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

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight,
              child: const HeroSection(),
            ),
          ),
          _SectionSlot(
            horizontalPadding: horizontalPadding,
            glowAlignment: Alignment.topRight,
            child: const ServicesSection(),
          ),
          const SliverToBoxAdapter(child: SectionWaveDivider()),
          _SectionSlot(
            horizontalPadding: horizontalPadding,
            glowAlignment: Alignment.topLeft,
            child: const ShowcaseSection(),
          ),
          const SliverToBoxAdapter(child: SectionWaveDivider()),
          _SectionSlot(
            horizontalPadding: horizontalPadding,
            glowAlignment: Alignment.centerRight,
            child: const AboutSection(),
          ),
          const SliverToBoxAdapter(child: SectionWaveDivider()),
          _SectionSlot(
            horizontalPadding: horizontalPadding,
            glowAlignment: Alignment.topRight,
            child: const LabsTeaserSection(),
          ),
          const SliverToBoxAdapter(child: SectionWaveDivider()),
          _SectionSlot(
            horizontalPadding: horizontalPadding,
            glowAlignment: Alignment.centerLeft,
            child: const ContactSection(
              // TODO(jose): trocar pelo numero do WhatsApp real e plugar
              // url_launcher pra abrir as Uris emitidas.
              whatsappNumber: '5571999990000',
              email: 'contato.joseguilhermealves@gmail.com',
              linkedinUrl:
                  'https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/',
              githubUrl: 'https://github.com/JoseGuilhermeAlves',
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
    return SliverToBoxAdapter(
      child: GlowBackdrop(
        alignment: glowAlignment,
        intensity: 0.08,
        radius: 0.45,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: AppSpacing.section,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: HomePage._maxContentWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
