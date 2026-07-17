import 'package:flutter/material.dart';

import '../../../../core/design_system/brand/brand_shadows.dart';
import '../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../core/design_system/components/components.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brandColors;
    final spacing = context.brandSpacing;
    final radius = context.brandRadius;

    return Scaffold(
      backgroundColor: colors.marfil,
      appBar: AppBar(title: const Text('Crear cuenta'), centerTitle: true),
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
                vertical: spacing.space16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CFBrandMark(size: 68)),
                    SizedBox(height: spacing.space12),
                    Text(
                      'Únete a CronoFinanzas',
                      style: context.brandTypography.headline,
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
                    SizedBox(height: spacing.space32),
                    Container(
                      padding: EdgeInsets.all(spacing.space24),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(radius.radius20),
                        border: Border.all(color: colors.border),
                        boxShadow: BrandShadows.soft,
                      ),
                      child: const RegisterForm(),
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
