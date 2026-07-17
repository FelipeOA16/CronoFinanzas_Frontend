import 'package:flutter/material.dart';

import '../spacing/cf_spacing.dart';
import '../tokens/cf_colors.dart';
import 'cf_card.dart';

class CFStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? helper;

  const CFStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = CFColors.verdeValle,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: const EdgeInsets.all(CFSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: CFSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: CFSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: CFSpacing.xxs),
            Text(helper!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
