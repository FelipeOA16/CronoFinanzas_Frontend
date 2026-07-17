import 'package:flutter/material.dart';

import '../spacing/cf_spacing.dart';
import '../tokens/cf_colors.dart';
import 'cf_button.dart';
import 'cf_card.dart';
import 'yachay_avatar.dart';

class CFYachayCard extends StatelessWidget {
  final String title;
  final String message;
  final YachayAvatarMood mood;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? action;
  final bool compact;
  final String? imageAsset;
  final bool showMascot;

  const CFYachayCard({
    super.key,
    required this.title,
    required this.message,
    this.mood = YachayAvatarMood.defaultMood,
    this.actionText,
    this.onAction,
    this.action,
    this.compact = false,
    this.imageAsset,
    this.showMascot = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForMood(mood);

    return CFCard(
      elevated: true,
      color: CFColors.surface,
      borderColor: color.withValues(alpha: 0.24),
      padding: EdgeInsets.all(
        MediaQuery.sizeOf(context).width >= 840 ? CFSpacing.lg : CFSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical = compact || constraints.maxWidth < 520;
          final avatar = showMascot
              ? YachayAvatar(
                  mood: mood,
                  imageAsset: imageAsset,
                  semanticLabel: '$title, Yachay',
                )
              : null;
          final text = _YachayText(
            title: title,
            message: message,
            color: color,
            compact: compact,
          );
          final actionWidget =
              action ??
              (actionText == null
                  ? null
                  : CFOutlinedButton(
                      label: actionText!,
                      onPressed: onAction,
                      icon: Icons.arrow_forward_rounded,
                    ));

          if (vertical) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (avatar != null) ...[
                      avatar,
                      const SizedBox(width: CFSpacing.sm),
                    ],
                    Expanded(child: text),
                  ],
                ),
                if (actionWidget != null) ...[
                  const SizedBox(height: CFSpacing.sm),
                  Align(alignment: Alignment.centerRight, child: actionWidget),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (avatar != null) ...[
                avatar,
                const SizedBox(width: CFSpacing.md),
              ],
              Expanded(child: text),
              if (actionWidget != null) ...[
                const SizedBox(width: CFSpacing.md),
                actionWidget,
              ],
            ],
          );
        },
      ),
    );
  }

  Color _colorForMood(YachayAvatarMood mood) {
    return switch (mood) {
      YachayAvatarMood.success => CFColors.success,
      YachayAvatarMood.warning => CFColors.warning,
      YachayAvatarMood.thinking => CFColors.azulAndino,
      YachayAvatarMood.happy => CFColors.oroInca,
      YachayAvatarMood.empty => CFColors.textMuted,
      YachayAvatarMood.defaultMood => CFColors.verdeValle,
    };
  }
}

class _YachayText extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final bool compact;

  const _YachayText({
    required this.title,
    required this.message,
    required this.color,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: compact ? 3 : CFSpacing.xxs),
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: CFColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
