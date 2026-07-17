import 'package:flutter/material.dart';

import '../brand/brand_assets.dart';
import '../brand/crono_brand_theme.dart';
import 'brand_image.dart';

enum CFEmptyIllustrationType { accounts, goals, budget, transactions, debts }

class CFEmptyIllustration extends StatelessWidget {
  final CFEmptyIllustrationType type;
  final double size;
  final BoxFit fit;

  const CFEmptyIllustration({
    super.key,
    required this.type,
    this.size = 160,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return BrandImage(
      assetPath: _assetForType(type),
      width: size,
      height: size,
      fit: fit,
      semanticLabel: 'Estado vacio',
      placeholder: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.brandColors.marfil,
          borderRadius: BorderRadius.circular(context.brandRadius.radius16),
        ),
        child: Icon(
          _iconForType(type),
          size: size * 0.32,
          color: context.brandColors.grisNeutro,
        ),
      ),
    );
  }

  String _assetForType(CFEmptyIllustrationType type) {
    return switch (type) {
      CFEmptyIllustrationType.accounts => BrandAssets.emptyAccounts,
      CFEmptyIllustrationType.goals => BrandAssets.emptyGoals,
      CFEmptyIllustrationType.budget => BrandAssets.emptyBudget,
      CFEmptyIllustrationType.transactions => BrandAssets.emptyTransactions,
      CFEmptyIllustrationType.debts => BrandAssets.emptyDebts,
    };
  }

  IconData _iconForType(CFEmptyIllustrationType type) {
    return switch (type) {
      CFEmptyIllustrationType.accounts => Icons.account_balance_wallet_outlined,
      CFEmptyIllustrationType.goals => Icons.flag_outlined,
      CFEmptyIllustrationType.budget => Icons.pie_chart_outline,
      CFEmptyIllustrationType.transactions => Icons.receipt_long_outlined,
      CFEmptyIllustrationType.debts => Icons.handshake_outlined,
    };
  }
}
