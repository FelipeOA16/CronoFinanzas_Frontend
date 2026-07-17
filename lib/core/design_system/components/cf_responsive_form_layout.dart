import 'package:flutter/material.dart';

import '../brand/crono_brand_theme.dart';
import '../tokens/theme_tokens.dart';
import 'cf_form_components.dart';

class CFResponsiveFormLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;
  final String? title;
  final String? subtitle;

  const CFResponsiveFormLayout({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          labelSmall: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(44, 48)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(44, 48)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 600;
            final insets = MediaQuery.viewInsetsOf(context);
            final effectivePadding =
                padding ??
                EdgeInsets.fromLTRB(
                  mobile ? CFSpacing.md : CFSpacing.lg,
                  CFSpacing.md,
                  mobile ? CFSpacing.md : CFSpacing.lg,
                  insets.bottom + (mobile ? 120 : CFSpacing.xl),
                );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: effectivePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.97, end: 1),
                    builder: (context, scale, animatedChild) => Opacity(
                      opacity: ((scale - 0.97) / 0.03).clamp(0, 1),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topCenter,
                        child: animatedChild,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null) ...[
                          CFFormHeader(title: title!, subtitle: subtitle ?? ''),
                          SizedBox(height: context.brandSpacing.space20),
                        ],
                        CFFormSurface(child: child),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CFResponsiveFormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const CFResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing = CFSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}
