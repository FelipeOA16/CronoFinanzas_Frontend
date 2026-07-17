import 'package:flutter/material.dart';

import '../tokens/cf_colors.dart';
import '../tokens/cf_radius.dart';

class CFIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;

  const CFIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      color: color ?? CFColors.azulAndino,
      style: IconButton.styleFrom(
        backgroundColor: CFColors.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
        ),
      ),
    );
  }
}
