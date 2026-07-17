import 'package:flutter/material.dart';

import '../brand/brand_assets.dart';
import '../brand/brand_shadows.dart';
import '../brand/crono_brand_theme.dart';
import 'brand_image.dart';

class CFBrandMark extends StatelessWidget {
  final double size;
  final bool elevated;

  const CFBrandMark({super.key, this.size = 72, this.elevated = true});

  @override
  Widget build(BuildContext context) {
    final radius = context.brandRadius.radius20;
    final colors = context.brandColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.verdeValle, colors.azulAndino],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: elevated ? BrandShadows.soft : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: BrandImage(
        assetPath: BrandAssets.logoSymbol,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'CronoFinanzas',
        placeholder: _BrandFallback(size: size),
      ),
    );
  }
}

class _BrandFallback extends StatelessWidget {
  final double size;

  const _BrandFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: size * 0.42,
          color: Colors.white,
        ),
        Positioned(
          right: size * 0.17,
          top: size * 0.16,
          child: Container(
            width: size * 0.13,
            height: size * 0.13,
            decoration: BoxDecoration(
              color: context.brandColors.oroInca,
              borderRadius: BorderRadius.circular(context.brandRadius.radius8),
            ),
          ),
        ),
      ],
    );
  }
}
