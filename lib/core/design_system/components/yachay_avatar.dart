import 'package:flutter/material.dart';

import '../brand/brand_assets.dart';
import '../brand/crono_brand_theme.dart';
import 'brand_image.dart';

enum YachayAvatarMood { defaultMood, happy, thinking, warning, success, empty }

class YachayAvatar extends StatelessWidget {
  final YachayAvatarMood mood;
  final double size;
  final String? imageAsset;
  final String? semanticLabel;

  const YachayAvatar({
    super.key,
    this.mood = YachayAvatarMood.defaultMood,
    this.size = 52,
    this.imageAsset,
    this.semanticLabel = 'Yachay',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.94, end: 1),
      builder: (context, scale, child) => Opacity(
        opacity: ((scale - 0.94) / 0.06).clamp(0, 1),
        child: Transform.scale(scale: scale, child: child),
      ),
      child: BrandImage(
        assetPath: imageAsset ?? _assetForMood(mood),
        width: size,
        height: size,
        fadeDuration: const Duration(milliseconds: 200),
        borderRadius: BorderRadius.circular(context.brandRadius.circle),
        semanticLabel: semanticLabel,
        placeholder: _YachayPlaceholder(size: size),
      ),
    );
  }

  String _assetForMood(YachayAvatarMood mood) {
    return switch (mood) {
      YachayAvatarMood.happy => BrandAssets.yachayHappy,
      YachayAvatarMood.thinking => BrandAssets.yachayThinking,
      YachayAvatarMood.warning => BrandAssets.yachayWarning,
      YachayAvatarMood.success => BrandAssets.yachaySuccess,
      YachayAvatarMood.empty => BrandAssets.yachayEmpty,
      YachayAvatarMood.defaultMood => BrandAssets.yachayDefault,
    };
  }
}

class _YachayPlaceholder extends StatelessWidget {
  final double size;

  const _YachayPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.brandColors.marfil,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.flight_takeoff_outlined,
        size: size * 0.5,
        color: context.brandColors.verdeValle,
      ),
    );
  }
}
