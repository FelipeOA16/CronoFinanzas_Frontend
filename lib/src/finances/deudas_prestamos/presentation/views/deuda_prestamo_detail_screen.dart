import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/di/providers.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../domain/entities/deuda_prestamo.dart';
import '../../domain/entities/pago_deuda_prestamo.dart';
import '../app/riverpod/deuda_prestamo_controller.dart';
import '../app/riverpod/deuda_prestamo_state.dart';
import 'deuda_prestamo_form_screen.dart';
import 'registrar_pago_deuda_screen.dart';

class DeudaPrestamoDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const DeudaPrestamoDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DeudaPrestamoDetailScreen> createState() =>
      _DeudaPrestamoDetailScreenState();
}

class _DeudaPrestamoDetailScreenState
    extends ConsumerState<DeudaPrestamoDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deudaPrestamoControllerProvider.notifier).loadDetail(widget.id);
    });
  }

  Future<void> _openPago(DeudaPrestamo item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegistrarPagoDeudaScreen(item: item)),
    );
    if (result == true && mounted) {
      await _refreshFinancialState();
      if (mounted) {
        ref
            .read(deudaPrestamoControllerProvider.notifier)
            .loadDetail(widget.id);
      }
    }
  }

  Future<void> _openEdit(DeudaPrestamo item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DeudaPrestamoFormScreen(item: item)),
    );
    if (result == true && mounted) {
      ref.read(deudaPrestamoControllerProvider.notifier).loadDetail(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deudaPrestamoControllerProvider);
    if (state is DeudaPrestamoLoading || state is DeudaPrestamoInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state is DeudaPrestamoError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: Center(child: Text(state.message)),
      );
    }
    final loaded = state as DeudaPrestamoLoaded;
    final item = loaded.selected;
    if (item == null) {
      return const Scaffold(
        body: Center(child: Text('Registro no encontrado')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            onPressed: () => _openEdit(item),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _Header(item: item),
          const SizedBox(height: 16),
          CFButton(
            label: item.esDebo ? 'Registrar pago' : 'Registrar cobro',
            onPressed: item.estaActiva ? () => _openPago(item) : null,
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 24),
          Text('Historial', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (loaded.pagos.isEmpty)
            const CFEmptyState(
              title: 'Sin pagos o cobros',
              message: 'El historial aparecerá al registrar un movimiento.',
            )
          else
            ...loaded.pagos.map(
              (p) => _PagoTile(
                pago: p,
                onDelete: () => _confirmDeletePago(item.id, p.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePago(int id, int pagoId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text('Se revertira tambien la transaccion vinculada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CFButton(
            label: 'Eliminar',
            tone: CFButtonTone.danger,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final done = await ref
        .read(deudaPrestamoControllerProvider.notifier)
        .eliminarPago(id, pagoId);
    if (done && mounted) {
      await _refreshFinancialState();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Movimiento revertido')));
      }
    }
  }

  Future<void> _refreshFinancialState() async {
    await ref.read(cuentaControllerProvider.notifier).loadCuentas();
    if (!mounted) return;
    ref.invalidate(patrimonioProvider);
    ref.invalidate(deudaPrestamoResumenProvider);
    ref.invalidate(patrimonioNetoEstimadoProvider);
    try {
      await Future.wait([
        ref.read(patrimonioProvider.future),
        ref.read(deudaPrestamoResumenProvider.future),
        ref.read(patrimonioNetoEstimadoProvider.future),
      ]);
    } catch (_) {
      // La operacion principal ya fue exitosa; las pantallas con watch mostraran
      // el error normal del provider si el refresh financiero falla.
    }
  }
}

class _Header extends StatelessWidget {
  final DeudaPrestamo item;
  const _Header({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.esDebo ? CFColors.danger : CFColors.success;
    return CFCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.nombre, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${item.esDebo ? 'Debo' : 'Me deben'} - ${item.contraparte}',
            style: const TextStyle(color: CFColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            '${item.moneda} ${item.saldoPendiente.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Saldo pendiente',
            style: TextStyle(color: CFColors.textSecondary),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: item.progreso,
            minHeight: 10,
            backgroundColor: CFColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 10),
          Text('Pagado/cobrado: ${(item.progreso * 100).toStringAsFixed(0)}%'),
          if (item.fechaProxima != null) ...[
            const SizedBox(height: 8),
            Text('Fecha proxima: ${_fmt(item.fechaProxima!)}'),
          ],
          const SizedBox(height: 8),
          Text('Prioridad: ${item.prioridad} - Estado: ${item.estado}'),
        ],
      ),
    );
  }
}

class _PagoTile extends StatelessWidget {
  final PagoDeudaPrestamo pago;
  final VoidCallback onDelete;
  const _PagoTile({required this.pago, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text('${pago.moneda} ${pago.monto.toStringAsFixed(2)}'),
        subtitle: Text('${_fmt(pago.fechaPago)} - Tx #${pago.transaccionId}'),
        trailing: SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: CFColors.danger),
            tooltip: 'Eliminar pago',
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
