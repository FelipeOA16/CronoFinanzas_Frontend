import 'package:flutter/material.dart';

import '../spacing/cf_spacing.dart';
import '../tokens/cf_colors.dart';
import '../tokens/cf_radius.dart';
import '../tokens/cf_shadows.dart';

class CFCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool elevated;

  const CFCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(CFSpacing.md),
      decoration: BoxDecoration(
        color: color ?? CFColors.surface,
        borderRadius: BorderRadius.circular(CFRadius.lg),
        border: Border.all(color: borderColor ?? CFColors.border),
        boxShadow: elevated ? CFShadows.subtle : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CFRadius.lg),
        child: content,
      ),
    );
  }
}
