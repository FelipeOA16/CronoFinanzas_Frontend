@pragma('vm:prefer-inline')
class BrandSpacing {
  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space20;
  final double space24;
  final double space32;
  final double space40;
  final double space48;
  final double space64;

  const BrandSpacing({
    this.space4 = 4,
    this.space8 = 8,
    this.space12 = 12,
    this.space16 = 16,
    this.space20 = 20,
    this.space24 = 24,
    this.space32 = 32,
    this.space40 = 40,
    this.space48 = 48,
    this.space64 = 64,
  });

  static const standard = BrandSpacing();
}
