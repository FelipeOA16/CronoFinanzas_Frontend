import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../../guide/yachay_messages.dart';
import '../../domain/entities/deuda_prestamo.dart';
import '../app/riverpod/deuda_prestamo_controller.dart';
import '../app/riverpod/deuda_prestamo_state.dart';
import 'deuda_prestamo_detail_screen.dart';
import 'deuda_prestamo_form_screen.dart';
import 'registrar_pago_deuda_screen.dart';

class DeudasPrestamosScreen extends ConsumerStatefulWidget {
  const DeudasPrestamosScreen({super.key});

  @override
  ConsumerState<DeudasPrestamosScreen> createState() =>
      _DeudasPrestamosScreenState();
}

class _DeudasPrestamosScreenState extends ConsumerState<DeudasPrestamosScreen> {
  String? _tipo;
  bool _soloAltaCritica = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(deudaPrestamoControllerProvider.notifier).load(tipo: _tipo);
  }

  void _setTipo(String? tipo) {
    setState(() => _tipo = tipo);
    _load();
  }

  Future<void> _openForm({DeudaPrestamo? item}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DeudaPrestamoFormScreen(item: item)),
    );
    if (result == true && mounted) _load();
  }

  Future<void> _openDetail(DeudaPrestamo item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DeudaPrestamoDetailScreen(id: item.id)),
    );
    if (mounted) _load();
  }

  Future<void> _openPago(DeudaPrestamo item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegistrarPagoDeudaScreen(item: item)),
    );
    if (result == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deudaPrestamoControllerProvider);
    final showExtendedFab = MediaQuery.sizeOf(context).width >= 840;

    ref.listen<DeudaPrestamoState>(deudaPrestamoControllerProvider, (_, next) {
      if (next is DeudaPrestamoError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: CFColors.danger,
          ),
        );
      }
    });

    final items = switch (state) {
      DeudaPrestamoLoaded(:final items) => items,
      DeudaPrestamoError(:final previousItems) => previousItems,
      _ => <DeudaPrestamo>[],
    };
    final resumen = switch (state) {
      DeudaPrestamoLoaded(:final resumen) => resumen,
      DeudaPrestamoError(:final previousResumen) => previousResumen,
      _ => null,
    };
    final loading = state is DeudaPrestamoLoading;
    final visible = _soloAltaCritica
        ? items
              .where((e) => e.prioridad == 'alta' || e.prioridad == 'critica')
              .toList()
        : items;
    final tieneImportantes = items.any(
      (e) => e.prioridad == 'alta' || e.prioridad == 'critica',
    );

    return Scaffold(
      backgroundColor: CFColors.marfil,
      appBar: AppBar(
        title: const Text('Deudas y prestamos'),
        actions: [
          if (!showExtendedFab)
            IconButton(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              tooltip: 'Agregar',
            ),
        ],
      ),
      floatingActionButton: CFExtendedFab(
        visible: showExtendedFab,
        onPressed: () => _openForm(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: 1 + (loading || visible.isEmpty ? 0 : visible.length),
          itemBuilder: (context, index) {
            if (index > 0) {
              final item = visible[index - 1];
              return _DeudaCard(
                item: item,
                onTap: () => _openDetail(item),
                onEdit: () => _openForm(item: item),
                onPago: item.estaActiva ? () => _openPago(item) : null,
              );
            }
            return Column(
              children: [
                if (resumen != null) _ResumenCards(resumen: resumen),
                const SizedBox(height: 12),
                _Filtros(
                  tipo: _tipo,
                  soloAltaCritica: _soloAltaCritica,
                  onTipo: _setTipo,
                  onAltaCritica: (v) {
                    setState(() => _soloAltaCritica = v);
                    _load();
                  },
                ),
                const SizedBox(height: 12),
                if (!loading && items.isNotEmpty) ...[
                  CFYachayCard(
                    title: YachayMessages.title,
                    message: tieneImportantes
                        ? 'Observa primero tus compromisos importantes antes de asumir nuevos gastos.'
                        : 'Observa tus compromisos antes de decidir un nuevo gasto.',
                    mood: tieneImportantes
                        ? YachayAvatarMood.warning
                        : YachayAvatarMood.thinking,
                    compact: true,
                  ),
                  const SizedBox(height: 12),
                ] else if (!loading && items.isEmpty) ...[
                  const CFYachayCard(
                    title: YachayMessages.title,
                    message:
                        'Vas ligero de compromisos. Es un buen momento para fortalecer tus metas.',
                    mood: YachayAvatarMood.success,
                    compact: true,
                  ),
                  const SizedBox(height: 12),
                ],
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (visible.isEmpty)
                  _EmptyState(onCreate: () => _openForm()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumenCards extends StatelessWidget {
  final dynamic resumen;
  const _ResumenCards({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric('Debo', resumen.totalDebo, CFColors.danger),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                'Me deben',
                resumen.totalMeDeben,
                CFColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Metric(
                'Neto',
                resumen.balanceNeto,
                resumen.balanceNeto >= 0 ? CFColors.success : CFColors.danger,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(
                'Criticas',
                resumen.cantidadCriticas.toDouble(),
                CFColors.azulAndino,
                money: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool money;
  const _Metric(this.label, this.value, this.color, {this.money = true});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: CFColors.textSecondary),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money
                  ? 'S/ ${value.toStringAsFixed(2)}'
                  : value.toStringAsFixed(0),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final String? tipo;
  final bool soloAltaCritica;
  final ValueChanged<String?> onTipo;
  final ValueChanged<bool> onAltaCritica;
  const _Filtros({
    required this.tipo,
    required this.soloAltaCritica,
    required this.onTipo,
    required this.onAltaCritica,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: tipo == null,
          onSelected: (_) => onTipo(null),
        ),
        ChoiceChip(
          label: const Text('Debo'),
          selected: tipo == 'debo',
          onSelected: (_) => onTipo('debo'),
        ),
        ChoiceChip(
          label: const Text('Me deben'),
          selected: tipo == 'me_deben',
          onSelected: (_) => onTipo('me_deben'),
        ),
        FilterChip(
          label: const Text('Alta/Critica'),
          selected: soloAltaCritica,
          onSelected: onAltaCritica,
        ),
      ],
    );
  }
}

class _DeudaCard extends StatelessWidget {
  final DeudaPrestamo item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onPago;
  const _DeudaCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onPago,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.esDebo ? CFColors.danger : CFColors.success;
    return CFCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.esDebo ? Icons.trending_down : Icons.trending_up,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _PriorityBadge(item.prioridad),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item.esDebo ? 'Debo' : 'Me deben'} - ${item.contraparte}',
              style: const TextStyle(
                color: CFColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: item.progreso,
              minHeight: 8,
              backgroundColor: CFColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pendiente: ${item.moneda} ${item.saldoPendiente.toStringAsFixed(2)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
                if (item.fechaProxima != null)
                  Text(
                    _fmt(item.fechaProxima!),
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: CFOutlinedButton(
                label: item.esDebo ? 'Registrar pago' : 'Registrar cobro',
                onPressed: onPago,
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String prioridad;
  const _PriorityBadge(this.prioridad);

  @override
  Widget build(BuildContext context) {
    final color = switch (prioridad) {
      'critica' => CFColors.danger,
      'alta' => CFColors.warning,
      'baja' => CFColors.textMuted,
      _ => CFColors.azulAndino,
    };
    return CFBadge(label: prioridad, color: color);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            const CFEmptyIllustration(
              type: CFEmptyIllustrationType.debts,
              size: 96,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sin deudas ni prestamos activos',
              style: TextStyle(color: CFColors.textSecondary),
            ),
            const SizedBox(height: 16),
            CFButton(
              label: 'Nuevo registro',
              onPressed: onCreate,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
