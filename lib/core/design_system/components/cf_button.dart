import 'package:flutter/material.dart';

import '../spacing/cf_spacing.dart';
import '../tokens/cf_colors.dart';
import '../tokens/cf_radius.dart';

enum CFButtonTone { primary, danger }

class CFButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final CFButtonTone tone;

  const CFButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.tone = CFButtonTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: tone == CFButtonTone.danger
          ? CFColors.danger
          : CFColors.verdeValle,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: CFSpacing.lg,
        vertical: CFSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CFRadius.md),
      ),
    );

    final content = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(label);

    if (icon == null || loading) {
      return FilledButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: content,
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class CFOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final CFButtonTone tone;

  const CFOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.tone = CFButtonTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: tone == CFButtonTone.danger
          ? CFColors.danger
          : CFColors.azulAndino,
      side: BorderSide(
        color: tone == CFButtonTone.danger
            ? CFColors.danger
            : CFColors.azulAndino,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: CFSpacing.lg,
        vertical: CFSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CFRadius.md),
      ),
    );

    if (loading) {
      return OutlinedButton(
        onPressed: null,
        style: style,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (icon == null) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
