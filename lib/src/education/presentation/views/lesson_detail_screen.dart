import 'package:flutter/material.dart';

import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../guide/yachay_messages.dart';
import '../../domain/entities/financial_lesson.dart';

class LessonDetailScreen extends StatelessWidget {
  final FinancialLesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CFColors.marfil,
      appBar: AppBar(title: const Text('Leccion')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth >= 720
              ? CFSpacing.xl
              : CFSpacing.md;
          return ListView(
            padding: EdgeInsets.fromLTRB(padding, CFSpacing.md, padding, 96),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: CFSpacing.xs,
                        runSpacing: CFSpacing.xxs,
                        children: [
                          CFBadge(
                            label: lesson.category,
                            color: CFColors.verdeValle,
                          ),
                          CFBadge(
                            label: lesson.level,
                            color: CFColors.azulAndino,
                          ),
                          CFBadge(
                            label: '${lesson.estimatedMinutes} min',
                            color: CFColors.oroInca,
                          ),
                        ],
                      ),
                      const SizedBox(height: CFSpacing.md),
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: CFColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: CFSpacing.xs),
                      Text(
                        lesson.shortDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CFColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: CFSpacing.lg),
                      CFCard(
                        padding: const EdgeInsets.all(CFSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < lesson.content.length; i++) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: CFColors.verdeValle.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        CFRadius.sm,
                                      ),
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: CFColors.verdeValle,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: CFSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      lesson.content[i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: CFColors.textPrimary,
                                            height: 1.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (i < lesson.content.length - 1)
                                const SizedBox(height: CFSpacing.md),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: CFSpacing.md),
                      CFYachayCard(
                        title: YachayMessages.title,
                        message: lesson.yachayMessage,
                        mood: YachayAvatarMood.happy,
                        compact: constraints.maxWidth < 600,
                      ),
                      const SizedBox(height: CFSpacing.md),
                      CFCard(
                        padding: const EdgeInsets.all(CFSpacing.md),
                        borderColor: CFColors.oroInca.withValues(alpha: 0.38),
                        color: CFColors.surfaceAlt,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.checklist_rounded,
                              color: CFColors.oroInca,
                            ),
                            const SizedBox(width: CFSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accion sugerida',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: CFColors.oroInca,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: CFSpacing.xxs),
                                  Text(
                                    lesson.suggestedAction,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: CFColors.textPrimary,
                                          height: 1.4,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: CFSpacing.lg),
                      CFButton(
                        label: 'Volver a lecciones',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
