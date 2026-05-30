import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';

/// Secao de fechamento da landing — case study tecnico do Pulso, o
/// mock de fitness recem-pivotado pra dark Whoop recovery-first. Em
/// vez de fechar com hype, mostra **como pensar arquitetura**:
/// narrativa do pivot + 3 painters ao vivo do proprio mock + bento
/// de decisoes (arquitetura, performance de painter, state).
///
/// Os painters sao consumidos via barrel publico de `feature_showcase`
/// (`PulsoRecoveryRing`, `PulsoStrainDial`, `PulsoPeriodizationTimeline`,
/// `PulsoTempoBars`, `PulsoBodyDiagram`). Eles trazem a paleta dark
/// Whoop deles mesmo — manter o look-and-feel do mock dentro do card
/// da landing reforca o tom "esse codigo e o codigo real, nao foto".
class CaseStudySection extends StatelessWidget {
  const CaseStudySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          eyebrow: 'Case study',
          title: 'Pulso reescrito —',
          titleAccent: 'dark Whoop, do zero.',
          subtitle:
              'O mock de fitness começou cream/laranja, padrão Strava. '
              'Foi pivotado pra dark recovery-first inspirado no Whoop '
              'após uma sessão de revisão crítica do scroll de '
              'fechamento. Aqui ficam as decisões que sustentam o '
              'novo Pulso.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        _HeroBlock(isMobile: isMobile),
        const SizedBox(height: AppSpacing.xxl),
        _PainterShowcase(isMobile: isMobile),
        const SizedBox(height: AppSpacing.xxl),
        _DecisionsGrid(isMobile: isMobile),
        const SizedBox(height: AppSpacing.xxl),
        const _ClosingTakeaway(),
      ],
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final narrative = _Narrative();
    final ring = _PulsoLivePreview();
    if (isMobile) {
      return Column(
        children: [
          ring,
          const SizedBox(height: AppSpacing.lg),
          narrative,
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: narrative),
          const SizedBox(width: AppSpacing.xl),
          Expanded(flex: 4, child: ring),
        ],
      ),
    );
  }
}

class _Narrative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O PIVOT',
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Do logger leve ao dashboard de leitura.',
            style: tt.headlineSmall?.copyWith(
              color: colors.onSurface,
              height: 1.2,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Paragraph(
            'A primeira versao do Pulso era um tracker comum: aba Hoje, '
            'aba Semana, aba Progresso. Tudo funcionava — set dots, '
            'rings, volume — mas a experiencia se resumia a "ver '
            'numeros". Tres em cada quatro telas eram somente leitura.',
          ),
          const SizedBox(height: AppSpacing.md),
          _Paragraph(
            'A reescrita inverteu o foco: recovery primeiro, logger '
            'depois. Mesociclo de 8 semanas com progressao linear + '
            'deload na ultima. Cada set logado avanca um strain '
            'accumulator que reage em tempo real. A paleta cream/laranja '
            'cedeu lugar ao verde recovery #00D982 e cyan strain '
            '#5AC8FA sobre superficie quase preta — referencia '
            'explicita ao Whoop, sem fingir originalidade.',
          ),
          const SizedBox(height: AppSpacing.md),
          _Paragraph(
            'O dominio cresceu: Program, ProgramWeek, SessionTemplate, '
            'PlannedExercise, SetEntry, LoggedSession, RecoverySnapshot, '
            'StrainScore, MuscleRecovery, SleepWindow. Tudo plain Dart '
            'com Equatable — sem freezed, sem codegen — pra manter o '
            'workspace sem build_runner.',
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceMuted,
        height: 1.6,
      ),
    );
  }
}

class _PulsoLivePreview extends StatefulWidget {
  @override
  State<_PulsoLivePreview> createState() => _PulsoLivePreviewState();
}

class _PulsoLivePreviewState extends State<_PulsoLivePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _ringAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF26262F)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PULSO · HOJE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF7E7E8A),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PulsoRecoveryRing(percent: 79, diameter: 220, animation: _ringAnim),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tudo verde. Use a janela pra trabalho intenso\n'
            'no padrao do mesociclo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFF2F2F5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PainterShowcase extends StatelessWidget {
  const _PainterShowcase({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _PainterCard(
        title: 'Strain dial',
        caption:
            'Escala 0–21 logaritmica do Whoop. Arco com gradient '
            'azul → magenta. Numeral monospace centralizado pra '
            'leitura tipo equipamento.',
        child: const SizedBox(
          height: 200,
          child: Center(
            child: PulsoStrainDial(value: 14.2, target: 16, diameter: 180),
          ),
        ),
      ),
      _PainterCard(
        title: 'Tempo bars',
        caption:
            '4 fases — eccentric / pausa / concentric / pausa — com '
            'cursor luminoso percorrendo em loop. Roda em AnimationController '
            'passado direto pro CustomPainter via super(repaint:).',
        child: SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: const Center(
              child: PulsoTempoBars(tempoSeconds: [2, 1, 2, 1]),
            ),
          ),
        ),
      ),
      _PainterCard(
        title: 'Periodization grid',
        caption:
            'Mesociclo de 8 semanas × 7 dias. Heat por intensidade '
            'prescrita, borda na semana atual, deload colorido '
            'distinto. Tap em qualquer célula expõe a sessão.',
        child: SizedBox(
          height: 200,
          child: PulsoPeriodizationTimeline(
            program: MesocycleCatalog.build(),
            height: 200,
          ),
        ),
      ),
    ];
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            cards[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: cards[1]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: cards[2]),
        ],
      ),
    );
  }
}

class _PainterCard extends StatelessWidget {
  const _PainterCard({
    required this.title,
    required this.caption,
    required this.child,
  });

  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF26262F)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(image: true, label: '$title: $caption', child: child),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFFF2F2F5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyle(
              color: const Color(0xFF7E7E8A),
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionsGrid extends StatelessWidget {
  const _DecisionsGrid({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final decisions = [
      const _DecisionCard(
        eyebrow: 'ARQUITETURA',
        title: 'Clean Arch por mock, não por pacote',
        body:
            'Cada mock do showcase (Pulso, Garoa, Aurora, Vitral, Solar) '
            'tem seu próprio triângulo data / domain / presentation '
            'dentro de lib/src/<mock>/. Mocks não se importam entre si '
            '— só de shared/. Quando um mock cresce em entidades, tudo '
            'cabe dentro do triângulo dele.',
      ),
      const _DecisionCard(
        eyebrow: 'PAINTERS',
        title: 'super(repaint:) e shouldRepaint estrito',
        body:
            'Painters animados recebem o AnimationController direto no '
            'super(repaint:) — o engine pula build/layout e vai pra '
            'paint imediatamente. shouldRepaint compara campo a campo. '
            'Sem alocacao no hot loop: Paint, Path e TextPainter '
            'cacheados como fields static do painter.',
      ),
      const _DecisionCard(
        eyebrow: 'STATE',
        title: 'Bloc rico, set-a-set com RPE',
        body:
            'O estado antigo (mapa completedSets[weekday|exerciseId]) '
            'foi substituido por LoggedSession com SetEntry tipado: '
            'weight, reps, RPE, completed, notes. SetLogged move o '
            'strain accumulator em tempo real — set virando complete '
            'avanca, virando incompleto recua. Sem freezed; Equatable '
            'da o == que precisamos.',
      ),
    ];
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < decisions.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            decisions[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: decisions[0]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: decisions[1]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: decisions[2]),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow,
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosingTakeaway extends StatelessWidget {
  const _ClosingTakeaway();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.12),
            colors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAKEAWAY',
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Mocks do showcase não são demo de paleta — são prova de que '
            'o codigo aguenta uma virada de produto sem virar gambiarra.',
            style: tt.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'O pivot do Pulso trocou ~5K LOC de UI mantendo a hierarquia '
            'core → design_system → animations → feature_*, sem dep nova, '
            'sem regressao no resto do scroll. Os painters reusam tudo '
            'que já existia na própria sub-feature. O código que você vê '
            'aqui em cima está rodando exatamente como na sessão do '
            'Pulso — não tem espelho, não tem foto.',
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
