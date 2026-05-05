import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:feature_contact/feature_contact.dart';
import 'package:feature_hero/feature_hero.dart';
import 'package:feature_services/feature_services.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';

/// Home da landing — composta pelas feature_* na ordem do scroll.
/// Plugadas: Hero (§12.6) + Services (§12.7) + Showcase (§12.10) +
/// About (§12.8) + Contact (§12.9).
class HomePage extends StatelessWidget {
  const HomePage({super.key = const Key('home-page')});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 720,
              child: HeroSection(
                // TODO(jose): plugar abertura do wa.me e scroll para Showcase
                // quando feature_showcase entrar no shell.
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
              vertical: AppSpacing.section,
            ),
            sliver: const SliverToBoxAdapter(child: ServicesGrid()),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
              vertical: AppSpacing.section,
            ),
            sliver: const SliverToBoxAdapter(child: ShowcaseSection()),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
              vertical: AppSpacing.section,
            ),
            sliver: const SliverToBoxAdapter(child: AboutSection()),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
              vertical: AppSpacing.section,
            ),
            sliver: const SliverToBoxAdapter(
              child: ContactSection(
                // TODO(jose): trocar pelo numero do WhatsApp real e plugar
                // url_launcher pra abrir as Uris emitidas.
                whatsappNumber: '5571999990000',
                email: 'contato.joseguilhermealves@gmail.com',
                linkedinUrl:
                    'https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/',
                githubUrl: 'https://github.com/JoseGuilhermeAlves',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
