import 'package:flutter/material.dart';

import '../spacing/cf_spacing.dart';
import '../tokens/cf_colors.dart';
import '../tokens/cf_radius.dart';

class CFBadge extends StatelessWidget {
  final String label;
  final Color color;

  const CFBadge({
    super.key,
    required this.label,
    this.color = CFColors.verdeValle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CFSpacing.sm,
        vertical: CFSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CFRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
