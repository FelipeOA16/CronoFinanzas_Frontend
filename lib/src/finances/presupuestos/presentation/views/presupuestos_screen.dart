import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/presupuesto.dart';
import '../app/riverpod/presupuesto_controller.dart';
import '../app/riverpod/presupuesto_state.dart';
import 'presupuesto_form_screen.dart';

class PresupuestosScreen extends ConsumerStatefulWidget {
  const PresupuestosScreen({super.key});

  @override
  ConsumerState<PresupuestosScreen> createState() => _PresupuestosScreenState();
}

class _PresupuestosScreenState extends ConsumerState<PresupuestosScreen> {
  late int _mes;
  late int _anio;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = now.month;
    _anio = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(presupuestoControllerProvider.notifier)
          .loadPresupuestos(mes: _mes, anio: _anio);
    });
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mes += delta;
      if (_mes > 12) {
        _mes = 1;
        _anio++;
      } else if (_mes < 1) {
        _mes = 12;
        _anio--;
      }
    });
    ref
        .read(presupuestoControllerProvider.notifier)
        .loadPresupuestos(mes: _mes, anio: _anio);
  }

  static const _meses = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(presupuestoControllerProvider);
    final showExtendedFab = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Presupuestos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!showExtendedFab)
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              tooltip: 'Agregar',
              onPressed: () => _openForm(context),
            ),
        ],
      ),
      body: Column(
        children: [
          _MesSelector(mes: _mes, anio: _anio, onChanged: _cambiarMes),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
      floatingActionButton: CFExtendedFab(
        visible: showExtendedFab,
        onPressed: () => _openForm(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PresupuestoState state) {
    if (state is PresupuestoLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is PresupuestoError && state.previous.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.gasto, size: 48),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            CFButton(
              label: 'Reintentar',
              onPressed: () => ref
                  .read(presupuestoControllerProvider.notifier)
                  .loadPresupuestos(mes: _mes, anio: _anio),
            ),
          ],
        ),
      );
    }

    final presupuestos = state is PresupuestoLoaded
        ? state.presupuestos
        : state is PresupuestoError
        ? state.previous
        : <Presupuesto>[];

    if (presupuestos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CFEmptyIllustration(
              type: CFEmptyIllustrationType.budget,
              size: 96,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin presupuestos este mes',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea un limite para organizar tus gastos',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
            const SizedBox(height: 20),
            CFButton(
              label: 'Crear presupuesto',
              onPressed: () => _openForm(context),
              icon: Icons.add,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref
          .read(presupuestoControllerProvider.notifier)
          .loadPresupuestos(mes: _mes, anio: _anio),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: presupuestos.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            final needsAttention = presupuestos.any(
              (presupuesto) => presupuesto.porcentaje >= 80,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CFYachayCard(
                title: 'Yachay',
                message: needsAttention
                    ? 'Tu presupuesto necesita atencion.'
                    : 'Vas cultivando un buen habito.',
                mood: needsAttention
                    ? YachayAvatarMood.warning
                    : YachayAvatarMood.success,
                compact: true,
              ),
            );
          }

          final presupuesto = presupuestos[i - 1];
          return _PresupuestoCard(
            presupuesto: presupuesto,
            onEdit: () => _openForm(context, presupuesto: presupuesto),
            onDelete: () => _confirmDelete(context, presupuesto),
          );
        },
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    Presupuesto? presupuesto,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PresupuestoFormScreen(
          presupuesto: presupuesto,
          defaultMes: _mes,
          defaultAnio: _anio,
        ),
      ),
    );
    if (result == true && mounted) {
      ref
          .read(presupuestoControllerProvider.notifier)
          .loadPresupuestos(mes: _mes, anio: _anio);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Presupuesto p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: Text(
          'Se eliminará el presupuesto '
          '${p.esGlobal ? 'global' : p.categoriaNombre ?? ''} '
          'de ${_meses[p.mes]} ${p.anio}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.gasto),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await ref
          .read(presupuestoControllerProvider.notifier)
          .deletePresupuesto(p.id, mes: _mes, anio: _anio);
      if (!ok && mounted) {
        final errState = ref.read(presupuestoControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errState is PresupuestoError
                  ? errState.message
                  : 'Error al eliminar',
            ),
            backgroundColor: AppColors.gasto,
          ),
        );
      }
    }
  }
}

// ─── Selector de mes ─────────────────────────────────────────────────────────

class _MesSelector extends StatelessWidget {
  final int mes;
  final int anio;
  final void Function(int delta) onChanged;

  static const _meses = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  const _MesSelector({
    required this.mes,
    required this.anio,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primary,
            onPressed: () => onChanged(-1),
          ),
          Text(
            '${_meses[mes]} $anio',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.primary,
            onPressed: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

// ─── Card de presupuesto ─────────────────────────────────────────────────────

class _PresupuestoCard extends StatelessWidget {
  final Presupuesto presupuesto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PresupuestoCard({
    required this.presupuesto,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _barColor {
    return switch (presupuesto.estado) {
      'excedido' => CFColors.danger,
      'alerta' => CFColors.warning,
      _ => CFColors.success,
    };
  }

  String get _estadoLabel {
    return switch (presupuesto.estado) {
      'excedido' => 'Excedido',
      'alerta' => 'En alerta',
      _ => 'En control',
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = presupuesto;
    final clampedPct = (p.porcentaje / 100).clamp(0.0, 1.0);
    final disponible = p.montoLimite - p.montoGastado;

    return CFCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderColor: p.estado == 'excedido'
          ? AppColors.gasto.withValues(alpha: 0.3)
          : AppColors.border,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryIcon(p: p),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.esGlobal
                            ? 'Presupuesto Global'
                            : (p.categoriaNombre ?? 'Sin nombre'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      CFBadge(label: _estadoLabel, color: _barColor),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.gasto),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clampedPct,
                minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _AmountLabel(
                    label: 'Gastado',
                    value: p.montoGastado,
                    moneda: p.moneda,
                    color: _barColor,
                  ),
                ),
                Text(
                  '${p.porcentaje.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _barColor,
                  ),
                ),
                _AmountLabel(
                  label: 'Límite',
                  value: p.montoLimite,
                  moneda: p.moneda,
                  color: AppColors.textSecondary,
                  alignRight: true,
                ),
              ],
            ),
            if (disponible > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Disponible: ${p.moneda} ${disponible.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final Presupuesto p;
  const _CategoryIcon({required this.p});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primaryLight.withValues(alpha: 0.15);
    Color fg = AppColors.primary;

    if (p.categoriaColor != null) {
      try {
        final hex = p.categoriaColor!.replaceAll('#', '');
        fg = Color(int.parse('FF$hex', radix: 16));
        bg = fg.withValues(alpha: 0.15);
      } catch (_) {}
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        p.esGlobal ? Icons.account_balance_wallet : Icons.category,
        color: fg,
        size: 22,
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final double value;
  final String moneda;
  final Color color;
  final bool alignRight;

  const _AmountLabel({
    required this.label,
    required this.value,
    required this.moneda,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            '$moneda ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
