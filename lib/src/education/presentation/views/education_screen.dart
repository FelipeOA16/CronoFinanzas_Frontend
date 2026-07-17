import 'package:flutter/material.dart';

import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../guide/yachay_messages.dart';
import '../../data/financial_lessons.dart';
import '../../domain/entities/financial_lesson.dart';
import '../widgets/category_filter.dart';
import '../widgets/lesson_card.dart';
import 'lesson_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String? _selectedCategory;

  List<FinancialLesson> get _visibleLessons {
    if (_selectedCategory == null) return FinancialLessons.lessons;
    return FinancialLessons.lessons
        .where((lesson) => lesson.category == _selectedCategory)
        .toList();
  }

  void _openLesson(FinancialLesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _visibleLessons;
    final brand = context.brandColors;
    return Scaffold(
      backgroundColor: CFColors.marfil,
      appBar: AppBar(title: const Text('Educacion financiera')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 900
              ? CFSpacing.xl
              : CFSpacing.md;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              CFSpacing.md,
              horizontalPadding,
              96,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Educacion financiera',
                        style: context.brandTypography.headline.copyWith(
                          color: brand.azulAndino,
                        ),
                      ),
                      const SizedBox(height: CFSpacing.xxs),
                      Text(
                        'Aprende a tomar mejores decisiones con tu dinero',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: brand.grisNeutro,
                        ),
                      ),
                      const SizedBox(height: CFSpacing.lg),
                      CFYachayCard(
                        title: YachayMessages.title,
                        message:
                            'Aprender sobre tu dinero es otra forma de cuidar el futuro que estas cultivando.',
                        mood: YachayAvatarMood.happy,
                        compact: constraints.maxWidth < 600,
                      ),
                      const SizedBox(height: CFSpacing.lg),
                      Text(
                        'Explora por tema',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: CFSpacing.sm),
                      CategoryFilter(
                        categories: FinancialLessons.categories,
                        selected: _selectedCategory,
                        onSelected: (category) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                      const SizedBox(height: CFSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCategory ?? 'Todas las lecciones',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            '${lessons.length} lecciones',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: CFColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: CFSpacing.sm),
                      if (lessons.isEmpty)
                        const CFEmptyState(
                          title: 'Sin lecciones',
                          message: 'Explora otra categoria.',
                        )
                      else
                        ...lessons.map(
                          (lesson) => LessonCard(
                            lesson: lesson,
                            onTap: () => _openLesson(lesson),
                          ),
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
