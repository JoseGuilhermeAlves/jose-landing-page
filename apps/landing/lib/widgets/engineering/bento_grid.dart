import 'package:design_system/design_system.dart';
import 'package:feature_tech/feature_tech.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/engineering/tech_body_popup.dart';
import 'package:landing/widgets/engineering/tech_brand_colors.dart';
import 'package:landing/widgets/engineering/tech_descriptions.dart';

/// Grid bento das techs da stack — 6 cards categoria com tiles
/// individuais por tech. Cada tile e clicavel; abre [showTechBodyPopup]
/// com a descricao expandida. Layout responsivo: 12 colunas em desktop,
/// duas colunas em tablet, coluna unica em mobile.
class TechBentoGrid extends StatelessWidget {
  const TechBentoGrid({this.onOpenDocs, super.key});

  /// Hook pra abrir a URL de docs do popup — wireado pelo shell.
  final void Function(String url)? onOpenDocs;

  /// Layout grid declarativo. Cada entry: categoria + flex span por
  /// linha (12-col base). Tres linhas em desktop pra entregar peso
  /// visual proporcional a importancia: framework dominante, estado
  /// e rotas equilibrados, qualidade/web/tooling em rodape.
  static const List<List<_Slot>> _desktopRows = [
    [
      _Slot(category: StackCategory.framework, span: 7),
      _Slot(category: StackCategory.state, span: 5),
    ],
    [
      _Slot(category: StackCategory.architecture, span: 7),
      _Slot(category: StackCategory.graphics, span: 5),
    ],
    [
      _Slot(category: StackCategory.persistence, span: 5),
      _Slot(category: StackCategory.routing, span: 7),
    ],
    [
      _Slot(category: StackCategory.quality, span: 4),
      _Slot(category: StackCategory.tooling, span: 4),
      _Slot(category: StackCategory.observability, span: 4),
    ],
  ];

  void _handleTechTap(BuildContext context, String techName) {
    final description = TechDescriptionsCatalog.byName[techName];
    if (description == null) return;
    showTechBodyPopup(
      context,
      description: description,
      onOpenDocs: onOpenDocs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final byCategory = StackCatalog.byCategory(context.l10n);

    if (isMobile) {
      const categories = StackCategory.values;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _CategoryCard(
              category: categories[i],
              items: byCategory[categories[i]] ?? const [],
              onTechTap: (name) => _handleTechTap(context, name),
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < _desktopRows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _desktopRows[rowIndex].length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: _desktopRows[rowIndex][i].span,
                    child: _CategoryCard(
                      category: _desktopRows[rowIndex][i].category,
                      items:
                          byCategory[_desktopRows[rowIndex][i].category] ??
                          const [],
                      onTechTap: (name) => _handleTechTap(context, name),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

@immutable
class _Slot {
  const _Slot({required this.category, required this.span});
  final StackCategory category;
  final int span;
}

/// Card de uma categoria — eyebrow chip colorido + label + grid de
/// `_TechTile` por tech. Em mobile o corpo colapsa por padrao; o header
/// vira tappable com chevron + contagem. Em desktop fica sempre expandido
/// e nao interativo.
class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.category,
    required this.items,
    required this.onTechTap,
  });

  final StackCategory category;
  final List<StackItem> items;
  final void Function(String techName) onTechTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  Color _categoryColor() =>
      CategoryBrandColors.byCategory[widget.category.name] ??
      const Color(0xFF9497A9);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final accent = _categoryColor();
    final isMobile = context.isMobile;
    final showTiles = !isMobile || _expanded;

    Widget header = Row(
      children: [
        ColoredBox(color: accent, child: const SizedBox(width: 9, height: 9)),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: PixelText(
              widget.category.label(context.l10n),
              color: accent,
              glowColor: accent,
              pixelSize: 3,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          widget.items.length.toString().padLeft(2, '0'),
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (isMobile) ...[
          const Spacer(),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: colors.onSurfaceMuted,
            ),
          ),
        ],
      ],
    );

    if (isMobile) {
      header = Semantics(
        button: true,
        expanded: _expanded,
        label:
            '${widget.category.label(context.l10n)}. '
            '${widget.items.length} tecnologias. '
            'Toque pra ${_expanded ? 'recolher' : 'expandir'}.',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: header,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 2),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 16),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          context.responsive(mobile: AppSpacing.md, desktop: AppSpacing.lg),
        ),
        child: AnimatedSize(
          duration: AppDuration.fast,
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              if (showTiles) ...[
                SizedBox(
                  height: context.responsive(
                    mobile: AppSpacing.sm,
                    desktop: AppSpacing.md,
                  ),
                ),
                _TileGrid(items: widget.items, onTechTap: widget.onTechTap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout de tiles que preenche a largura do card. Distribui items
/// em rows de Expanded — sem LayoutBuilder (incompativel com
/// IntrinsicHeight). Coluna count derivado do total de items.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.items, required this.onTechTap});

  final List<StackItem> items;
  final void Function(String techName) onTechTap;

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(
      mobile: items.length.clamp(1, 2),
      desktop: items.length.clamp(1, 3),
    );

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += cols) {
      final rowItems = items.sublist(i, (i + cols).clamp(0, items.length));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < rowItems.length; j++) ...[
              if (j > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TechTile(
                  techName: rowItems[j].name,
                  role: rowItems[j].role,
                  onTap: () => onTechTap(rowItems[j].name),
                ),
              ),
            ],
            for (var j = rowItems.length; j < cols; j++) ...[
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: SizedBox.shrink()),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          rows[i],
        ],
      ],
    );
  }
}

/// Tile individual de uma tech dentro do card — clicavel, com hover
/// glow na cor brand. Mostra nome + role curto.
class _TechTile extends StatefulWidget {
  const _TechTile({
    required this.techName,
    required this.role,
    required this.onTap,
  });

  final String techName;
  final String role;
  final VoidCallback onTap;

  @override
  State<_TechTile> createState() => _TechTileState();
}

class _TechTileState extends State<_TechTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final brand = TechBrandColors.primary(widget.techName);

    final shadows = _hovered
        ? [
            BoxShadow(
              color: brand.withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: -2,
            ),
          ]
        : const <BoxShadow>[];

    return Semantics(
      button: true,
      label: '${widget.techName}. Toque pra abrir descrição.',
      onTap: widget.onTap,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            padding: EdgeInsets.all(
              context.responsive(mobile: AppSpacing.sm, desktop: AppSpacing.md),
            ),
            decoration: BoxDecoration(
              color: brand.withValues(alpha: _hovered ? 0.18 : 0.05),
              border: Border.all(
                color: brand.withValues(alpha: _hovered ? 1 : 0.45),
                width: 1.5,
              ),
              boxShadow: shadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ColoredBox(
                      color: brand,
                      child: const SizedBox(width: 8, height: 8),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        widget.techName.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.role,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.4,
                  ),
                  maxLines: context.responsive(mobile: 1, desktop: 2),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
