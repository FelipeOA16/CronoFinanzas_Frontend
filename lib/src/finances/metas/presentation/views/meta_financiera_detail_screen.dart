import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../domain/entities/aporte_meta.dart';
import '../../domain/entities/meta_financiera.dart';
import '../app/riverpod/meta_financiera_controller.dart';
import '../app/riverpod/meta_financiera_state.dart';
import 'meta_financiera_form_screen.dart';
import 'registrar_aporte_meta_screen.dart';

class MetaFinancieraDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const MetaFinancieraDetailScreen({super.key, required this.id});

  @override
  ConsumerState<MetaFinancieraDetailScreen> createState() =>
      _MetaFinancieraDetailScreenState();
}

class _MetaFinancieraDetailScreenState
    extends ConsumerState<MetaFinancieraDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(metaFinancieraControllerProvider.notifier).loadDetail(widget.id);
    });
  }

  Future<void> _openAporte(MetaFinanciera item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegistrarAporteMetaScreen(item: item)),
    );
    if (result == true && mounted) {
      ref.read(metaFinancieraControllerProvider.notifier).loadDetail(widget.id);
    }
  }

  Future<void> _openEdit(MetaFinanciera item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MetaFinancieraFormScreen(item: item)),
    );
    if (result == true && mounted) {
      ref.read(metaFinancieraControllerProvider.notifier).loadDetail(widget.id);
    }
  }

  Future<void> _confirmDeleteAporte(int metaId, int aporteId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar aporte'),
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
        .read(metaFinancieraControllerProvider.notifier)
        .eliminarAporte(metaId, aporteId);
    if (done && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aporte revertido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metaFinancieraControllerProvider);
    if (state is MetaFinancieraLoading || state is MetaFinancieraInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state is MetaFinancieraError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meta')),
        body: Center(child: Text(state.message)),
      );
    }
    final loaded = state as MetaFinancieraLoaded;
    final item = loaded.selected;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Meta no encontrada')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meta'),
        actions: [
          IconButton(
            onPressed: () => _openEdit(item),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          CFSpacing.md,
          CFSpacing.md,
          CFSpacing.md,
          96,
        ),
        children: [
          _Header(item: item),
          const SizedBox(height: CFSpacing.md),
          CFButton(
            label: 'Registrar aporte',
            onPressed: item.estaActiva ? () => _openAporte(item) : null,
            icon: Icons.add_card_outlined,
          ),
          const SizedBox(height: CFSpacing.lg),
          Text(
            'Historial de aportes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: CFSpacing.sm),
          if (loaded.aportes.isEmpty)
            const CFEmptyState(
              title: 'Sin aportes registrados',
              message: 'El historial aparecerá cuando registres un aporte.',
            )
          else
            ...loaded.aportes.map(
              (aporte) => _AporteTile(
                aporte: aporte,
                onDelete: () => _confirmDeleteAporte(item.id, aporte.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MetaFinanciera item;
  const _Header({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.estaCompletada ? CFColors.success : CFColors.verdeValle;
    return CFCard(
      padding: const EdgeInsets.all(CFSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.nombre, style: Theme.of(context).textTheme.titleLarge),
          if (item.descripcion?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              item.descripcion!,
              style: const TextStyle(color: CFColors.textSecondary),
            ),
          ],
          const SizedBox(height: CFSpacing.md),
          Text(
            _money(item.montoActual),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'de ${_money(item.montoObjetivo)}',
            style: const TextStyle(color: CFColors.textSecondary),
          ),
          const SizedBox(height: CFSpacing.md),
          LinearProgressIndicator(
            value: item.progreso,
            minHeight: 12,
            backgroundColor: CFColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: CFSpacing.xs),
          Text('${(item.progreso * 100).toStringAsFixed(0)}% completado'),
          if (item.fechaObjetivo != null) ...[
            const SizedBox(height: CFSpacing.xs),
            Text('Fecha objetivo: ${_fmt(item.fechaObjetivo!)}'),
          ],
          const SizedBox(height: CFSpacing.xs),
          Text('Prioridad: ${item.prioridad} - Estado: ${item.estado}'),
        ],
      ),
    );
  }
}

class _AporteTile extends StatelessWidget {
  final AporteMeta aporte;
  final VoidCallback onDelete;

  const _AporteTile({required this.aporte, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      margin: const EdgeInsets.only(bottom: CFSpacing.xs),
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text('${aporte.moneda} ${aporte.monto.toStringAsFixed(2)}'),
        subtitle: Text(
          '${_fmt(aporte.fechaAporte)} - Tx #${aporte.transaccionId}',
        ),
        trailing: SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: CFColors.danger),
            tooltip: 'Eliminar aporte',
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}

String _money(double value) => 'S/ ${value.toStringAsFixed(2)}';
String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
