import 'package:flutter/material.dart';

import '../brand/crono_brand_theme.dart';

class BrandImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Widget? placeholder;
  final Duration fadeDuration;
  final String? semanticLabel;

  const BrandImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholder,
    this.fadeDuration = const Duration(milliseconds: 220),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fallback =
        placeholder ?? _BrandImagePlaceholder(width: width, height: height);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (_, __, ___) => fallback,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: fadeDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: frame == null
                ? KeyedSubtree(
                    key: const ValueKey('brand-image-loading'),
                    child: fallback,
                  )
                : KeyedSubtree(
                    key: const ValueKey('brand-image-loaded'),
                    child: child,
                  ),
          );
        },
      ),
    );
  }
}

class _BrandImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;

  const _BrandImagePlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: context.brandColors.marfil,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: context.brandColors.grisNeutro),
    );
  }
}
