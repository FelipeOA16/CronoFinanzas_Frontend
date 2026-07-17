import 'package:flutter/material.dart';

import '../../../../core/design_system/brand/brand_shadows.dart';
import '../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../core/design_system/components/components.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brandColors;
    final spacing = context.brandSpacing;
    final radius = context.brandRadius;

    return Scaffold(
      backgroundColor: colors.marfil,
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.marfil, colors.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.space24,
                vertical: spacing.space24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CFBrandMark(size: 80)),
                    SizedBox(height: spacing.space24),
                    Text(
                      'CronoFinanzas',
                      style: context.brandTypography.headline.copyWith(
                        fontSize: 30,
                        color: colors.piedra,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.space4),
                    Text(
                      'Cultiva hoy el futuro que imaginas',
                      style: context.brandTypography.body.copyWith(
                        color: colors.grisNeutro,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: spacing.space40),
                    Container(
                      padding: EdgeInsets.all(spacing.space24),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(radius.radius20),
                        border: Border.all(color: colors.border),
                        boxShadow: BrandShadows.soft,
                      ),
                      child: const LoginForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
