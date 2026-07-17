import 'package:flutter/material.dart';

import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../domain/entities/transaccion.dart';

class TransaccionCard extends StatelessWidget {
  final Transaccion transaccion;
  final String? cuentaNombre;
  final String? cuentaDestinoNombre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransaccionCard({
    super.key,
    required this.transaccion,
    required this.onEdit,
    required this.onDelete,
    this.cuentaNombre,
    this.cuentaDestinoNombre,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (transaccion.tipo) {
      'ingreso' => CFColors.success,
      'gasto' => CFColors.danger,
      _ => CFColors.info,
    };
    final icon =
        _categoryIcon ??
        switch (transaccion.tipo) {
          'ingreso' => CFIcons.income,
          'gasto' => CFIcons.expense,
          _ => Icons.swap_horiz_rounded,
        };

    return CFCard(
      elevated: true,
      margin: const EdgeInsets.only(bottom: CFSpacing.xs),
      padding: EdgeInsets.zero,
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(CFSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(CFRadius.md),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: CFSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: CFColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CFColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _accountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CFSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _amount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: PopupMenuButton<String>(
                        tooltip: 'Acciones del movimiento',
                        onSelected: (value) {
                          if (value == 'delete') _confirmDelete(context);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'duplicate',
                            enabled: false,
                            child: Text('Duplicar'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Eliminar',
                              style: TextStyle(color: CFColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: CFColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    final description = transaccion.descripcion?.trim();
    if (description?.isNotEmpty == true) return description!;
    return transaccion.categoriaNombre ?? _typeLabel;
  }

  String get _subtitle {
    final parts = <String>[
      transaccion.categoriaNombre ?? _typeLabel,
      if (transaccion.pagadoA?.trim().isNotEmpty == true)
        transaccion.pagadoA!.trim(),
      if (_timeLabel != null) _timeLabel!,
    ];
    return parts.join(' - ');
  }

  String get _accountLabel {
    if (transaccion.tipo == 'transferencia' &&
        cuentaDestinoNombre?.isNotEmpty == true) {
      return '${cuentaNombre ?? 'Cuenta'} -> $cuentaDestinoNombre';
    }
    return cuentaNombre ?? 'Cuenta no disponible';
  }

  String get _amount {
    final sign = switch (transaccion.tipo) {
      'ingreso' => '+',
      'gasto' => '-',
      _ => '',
    };
    return '$sign${transaccion.moneda} ${transaccion.monto.toStringAsFixed(2)}';
  }

  String get _typeLabel {
    return switch (transaccion.tipo) {
      'ingreso' => 'Ingreso',
      'gasto' => 'Gasto',
      _ => 'Transferencia',
    };
  }

  String? get _timeLabel {
    if (transaccion.fecha.hour == 0 && transaccion.fecha.minute == 0) {
      return null;
    }
    final hour = transaccion.fecha.hour.toString().padLeft(2, '0');
    final minute = transaccion.fecha.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData? get _categoryIcon {
    return switch (transaccion.categoriaIcono) {
      'restaurant' => Icons.restaurant_rounded,
      'directions_car' => Icons.directions_car_rounded,
      'home' => Icons.home_rounded,
      'local_hospital' => Icons.local_hospital_rounded,
      'movie' => Icons.movie_rounded,
      'school' => Icons.school_rounded,
      'work' => Icons.work_rounded,
      'shopping_cart' => Icons.shopping_cart_rounded,
      'flight' => Icons.flight_rounded,
      'savings' => Icons.savings_rounded,
      'attach_money' => Icons.attach_money_rounded,
      'category' => Icons.category_rounded,
      _ => null,
    };
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text('Esta accion revertira el movimiento financiero.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: CFColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}
