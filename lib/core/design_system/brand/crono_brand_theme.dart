import 'package:flutter/material.dart';

import 'brand_colors.dart';
import 'brand_radius.dart';
import 'brand_spacing.dart';
import 'brand_typography.dart';

@immutable
class CronoBrandTheme extends ThemeExtension<CronoBrandTheme> {
  final BrandColors colors;
  final BrandRadius radius;
  final BrandSpacing spacing;
  final BrandTypography typography;

  const CronoBrandTheme({
    required this.colors,
    required this.radius,
    required this.spacing,
    required this.typography,
  });

  static const standard = CronoBrandTheme(
    colors: BrandColors.standard,
    radius: BrandRadius.standard,
    spacing: BrandSpacing.standard,
    typography: BrandTypography.standard,
  );

  @override
  CronoBrandTheme copyWith({
    BrandColors? colors,
    BrandRadius? radius,
    BrandSpacing? spacing,
    BrandTypography? typography,
  }) {
    return CronoBrandTheme(
      colors: colors ?? this.colors,
      radius: radius ?? this.radius,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
    );
  }

  @override
  CronoBrandTheme lerp(CronoBrandTheme? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

extension CronoBrandBuildContext on BuildContext {
  CronoBrandTheme get cronoBrand =>
      Theme.of(this).extension<CronoBrandTheme>() ?? CronoBrandTheme.standard;

  BrandColors get brandColors => cronoBrand.colors;
  BrandRadius get brandRadius => cronoBrand.radius;
  BrandSpacing get brandSpacing => cronoBrand.spacing;
  BrandTypography get brandTypography => cronoBrand.typography;
}
