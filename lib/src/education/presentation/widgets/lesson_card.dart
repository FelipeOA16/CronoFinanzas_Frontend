import 'package:flutter/material.dart';

import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../../domain/entities/financial_lesson.dart';

class LessonCard extends StatelessWidget {
  final FinancialLesson lesson;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      elevated: true,
      borderColor: _categoryColor(lesson.category).withValues(alpha: 0.24),
      margin: const EdgeInsets.only(bottom: CFSpacing.sm),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(CFSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor(lesson.category).withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(CFRadius.md),
              ),
              child: Icon(
                _categoryIcon(lesson.category),
                color: _categoryColor(lesson.category),
                size: 22,
              ),
            ),
            const SizedBox(width: CFSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: CFSpacing.xs,
                    runSpacing: CFSpacing.xxs,
                    children: [
                      CFBadge(
                        label: lesson.category,
                        color: _categoryColor(lesson.category),
                      ),
                      CFBadge(label: lesson.level, color: CFColors.azulAndino),
                    ],
                  ),
                  const SizedBox(height: CFSpacing.sm),
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CFColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: CFSpacing.xxs),
                  Text(
                    lesson.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CFColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: CFSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: CFColors.textMuted,
                      ),
                      const SizedBox(width: CFSpacing.xxs),
                      Text(
                        '${lesson.estimatedMinutes} min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: CFColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: CFSpacing.xs),
            const Icon(Icons.chevron_right_rounded, color: CFColors.textMuted),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    return switch (category) {
      'Ahorro' => CFColors.success,
      'Presupuesto' => CFColors.azulAndino,
      'Deudas' => CFColors.terracota,
      'Metas' => CFColors.oroInca,
      'Patrimonio' => CFColors.info,
      _ => CFColors.verdeValle,
    };
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Ahorro' => Icons.savings_outlined,
      'Presupuesto' => Icons.pie_chart_outline,
      'Deudas' => Icons.handshake_outlined,
      'Metas' => Icons.flag_outlined,
      'Patrimonio' => Icons.account_balance_wallet_outlined,
      _ => Icons.autorenew_rounded,
    };
  }
}
