import 'package:flutter/material.dart';

import '../tokens/theme_tokens.dart';

class CFExtendedFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool visible;
  final String? tooltip;

  const CFExtendedFab({
    super.key,
    required this.onPressed,
    this.label = 'Agregar',
    this.icon = Icons.add,
    this.visible = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final button = SizedBox(
      height: 48,
      child: FloatingActionButton.extended(
        heroTag: null,
        onPressed: onPressed,
        elevation: 4,
        hoverElevation: 6,
        backgroundColor: CFColors.verdeValle,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        extendedPadding: const EdgeInsets.symmetric(horizontal: CFSpacing.lg),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
