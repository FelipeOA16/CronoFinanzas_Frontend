import 'package:flutter/material.dart';

import '../../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../domain/entities/cuenta.dart';

/// Maps a hex color string (#RRGGBB) to a Flutter Color.
Color hexToColor(String? hex, {Color fallback = CFColors.textMuted}) {
  if (hex == null || hex.length != 7 || !hex.startsWith('#')) return fallback;
  return Color(int.parse('ff${hex.substring(1)}', radix: 16));
}

/// Returns the Spanish label for a tipo value.
String tipoLabel(String tipo) {
  const labels = {
    'banco': 'Banco',
    'efectivo': 'Efectivo',
    'tarjeta_credito': 'Tarjeta crédito',
    'tarjeta_debito': 'Tarjeta débito',
    'inversion': 'Inversión',
    'cripto': 'Cripto',
    'otro': 'Otro',
  };
  return labels[tipo] ?? tipo;
}

/// Returns a Material icon for a tipo value.
IconData tipoIcon(String tipo) {
  const icons = {
    'banco': Icons.account_balance_outlined,
    'efectivo': Icons.payments_outlined,
    'tarjeta_credito': Icons.credit_card_outlined,
    'tarjeta_debito': Icons.payment_outlined,
    'inversion': Icons.trending_up_outlined,
    'cripto': Icons.currency_bitcoin,
    'otro': Icons.account_balance_wallet_outlined,
  };
  return icons[tipo] ?? Icons.account_balance_wallet_outlined;
}

class CuentaCard extends StatelessWidget {
  final Cuenta cuenta;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onVerMovimientos;

  const CuentaCard({
    super.key,
    required this.cuenta,
    required this.onTap,
    required this.onDelete,
    this.onVerMovimientos,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brandColors;
    final spacing = context.brandSpacing;
    final radius = context.brandRadius;
    final color = hexToColor(cuenta.color);
    final balance = cuenta.saldoActual;
    final isNegative = balance < 0;

    return CFCard(
      elevated: true,
      margin: EdgeInsets.symmetric(
        horizontal: spacing.space16,
        vertical: spacing.space4,
      ),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Row(
        children: [
          // Color bar
          Container(
            width: 6,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius.radius16),
                bottomLeft: Radius.circular(radius.radius16),
              ),
            ),
          ),
          SizedBox(width: spacing.space12),
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(radius.radius12),
            ),
            child: Icon(tipoIcon(cuenta.tipo), color: color, size: 22),
          ),
          SizedBox(width: spacing.space12),
          // Name + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cuenta.nombre,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tipoLabel(cuenta.tipo)} · ${cuenta.moneda}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.grisNeutro),
                ),
              ],
            ),
          ),
          // Balance + delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isNegative ? '-' : ''}${cuenta.moneda} ${balance.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isNegative ? colors.rojoError : colors.piedra,
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: PopupMenuButton<String>(
                    tooltip: 'Acciones de cuenta',
                    onSelected: (value) {
                      if (value == 'movements') onVerMovimientos?.call();
                      if (value == 'edit') onTap();
                      if (value == 'delete') _confirmDelete(context);
                    },
                    itemBuilder: (_) => [
                      if (onVerMovimientos != null)
                        const PopupMenuItem(
                          value: 'movements',
                          child: Text('Ver movimientos'),
                        ),
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Eliminar',
                          style: TextStyle(color: colors.rojoError),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text(
          '¿Eliminar "${cuenta.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CFButton(
            label: 'Eliminar',
            tone: CFButtonTone.danger,
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
