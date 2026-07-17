import 'package:flutter/material.dart';

import '../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brandColors;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: selected == null,
                  selectedColor: colors.verdeValle.withValues(alpha: 0.14),
                  side: BorderSide(
                    color: selected == null ? colors.verdeValle : colors.border,
                  ),
                  onSelected: (_) => onSelected(null),
                ),
                for (final category in categories) ...[
                  const SizedBox(width: CFSpacing.xs),
                  ChoiceChip(
                    label: Text(category),
                    selected: selected == category,
                    selectedColor: colors.verdeValle.withValues(alpha: 0.14),
                    side: BorderSide(
                      color: selected == category
                          ? colors.verdeValle
                          : colors.border,
                    ),
                    onSelected: (_) => onSelected(category),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: CFSpacing.xxs),
        const Tooltip(
          message: 'Desliza para ver mas categorias',
          child: Icon(
            Icons.swipe_left_rounded,
            size: 20,
            color: CFColors.textMuted,
          ),
        ),
      ],
    );
  }
}
