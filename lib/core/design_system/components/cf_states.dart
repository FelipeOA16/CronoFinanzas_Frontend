import 'package:flutter/material.dart';

import '../icons/cf_icons.dart';
import '../spacing/cf_spacing.dart';
import '../tokens/cf_colors.dart';

class CFEmptyState extends StatelessWidget {
  final String title;
  final String? message;

  const CFEmptyState({super.key, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: CFIcons.empty,
      title: title,
      message: message,
      color: CFColors.textMuted,
    );
  }
}

class CFLoadingState extends StatelessWidget {
  final String? message;

  const CFLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CFSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: CFSpacing.md),
              Text(message!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class CFErrorState extends StatelessWidget {
  final String title;
  final String message;

  const CFErrorState({
    super.key,
    this.title = 'Algo no salio bien',
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: CFIcons.error,
      title: title,
      message: message,
      color: CFColors.danger,
    );
  }
}

class _StateLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Color color;

  const _StateLayout({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CFSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(height: CFSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: CFSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
