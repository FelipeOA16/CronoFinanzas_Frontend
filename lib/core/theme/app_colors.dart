import 'package:flutter/material.dart';

import '../design_system/tokens/cf_colors.dart';

/// Compatibilidad para pantallas existentes.
/// Las nuevas superficies deben importar ThemeTokens/CFColors directamente.
abstract class AppColors {
  static const primary = CFColors.verdeValle;
  static const primaryLight = CFColors.success;
  static const primaryDark = CFColors.azulAndino;

  static const background = CFColors.marfil;
  static const surface = CFColors.surface;
  static const surfaceVariant = CFColors.surfaceAlt;

  static const textPrimary = CFColors.textPrimary;
  static const textSecondary = CFColors.textSecondary;
  static const textHint = CFColors.textMuted;

  static const border = CFColors.border;

  static const ingreso = CFColors.success;
  static const ingresoLight = Color(0xFFE4EFE3);
  static const gasto = CFColors.danger;
  static const gastoLight = Color(0xFFF9E1DA);
  static const transferencia = CFColors.info;
  static const transferenciaLight = Color(0xFFDDEAF2);

  static const gold = CFColors.oroInca;
  static const goldLight = Color(0xFFF3E7BC);
  static const fire = CFColors.terracota;

  static const catAlimentacion = CFColors.danger;
  static const catTransporte = CFColors.info;
  static const catEntretenimiento = CFColors.terracota;
  static const catSalud = CFColors.success;
  static const catEducacion = CFColors.azulAndino;
  static const catOtros = CFColors.textSecondary;
}
