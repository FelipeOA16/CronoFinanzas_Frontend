import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../../guide/yachay_messages.dart';
import '../../domain/entities/meta_financiera.dart';
import '../app/riverpod/meta_financiera_controller.dart';
import '../app/riverpod/meta_financiera_state.dart';
import 'meta_financiera_detail_screen.dart';
import 'meta_financiera_form_screen.dart';
import 'registrar_aporte_meta_screen.dart';

class MetasScreen extends ConsumerStatefulWidget {
  const MetasScreen({super.key});

  @override
  ConsumerState<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends ConsumerState<MetasScreen> {
  String? _prioridad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref
        .read(metaFinancieraControllerProvider.notifier)
        .load(prioridad: _prioridad);
  }

  Future<void> _openForm({MetaFinanciera? item}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MetaFinancieraFormScreen(item: item)),
    );
    if (result == true && mounted) _load();
  }

  Future<void> _openDetail(MetaFinanciera item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MetaFinancieraDetailScreen(id: item.id),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _openAporte(MetaFinanciera item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegistrarAporteMetaScreen(item: item)),
    );
    if (result == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metaFinancieraControllerProvider);
    final showExtendedFab = MediaQuery.sizeOf(context).width >= 840;

    ref.listen<MetaFinancieraState>(metaFinancieraControllerProvider, (
      _,
      next,
    ) {
      if (next is MetaFinancieraError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: CFColors.danger,
          ),
        );
      }
    });

    final items = switch (state) {
      MetaFinancieraLoaded(:final items) => items,
      MetaFinancieraError(:final previousItems) => previousItems,
      _ => <MetaFinanciera>[],
    };
    final resumen = switch (state) {
      MetaFinancieraLoaded(:final resumen) => resumen,
      MetaFinancieraError(:final previousResumen) => previousResumen,
      _ => null,
    };
    final loading = state is MetaFinancieraLoading;

    return Scaffold(
      backgroundColor: CFColors.marfil,
      appBar: AppBar(
        title: const Text('Metas'),
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
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            CFSpacing.md,
            CFSpacing.md,
            CFSpacing.md,
            96,
          ),
          itemCount: 1 + (loading || items.isEmpty ? 0 : items.length),
          itemBuilder: (context, index) {
            if (index > 0) {
              final item = items[index - 1];
              return _MetaCard(
                item: item,
                onTap: () => _openDetail(item),
                onEdit: () => _openForm(item: item),
                onAporte: item.estaActiva ? () => _openAporte(item) : null,
              );
            }
            return Column(
              children: [
                if (resumen != null) _ResumenMetas(resumen: resumen),
                const SizedBox(height: CFSpacing.sm),
                _Filtros(
                  prioridad: _prioridad,
                  onPrioridad: (value) {
                    setState(() => _prioridad = value);
                    _load();
                  },
                ),
                const SizedBox(height: CFSpacing.sm),
                if (!loading && items.isNotEmpty) ...[
                  const CFYachayCard(
                    title: YachayMessages.title,
                    message:
                        'Cada aporte es una semilla para el futuro que estas construyendo.',
                    mood: YachayAvatarMood.happy,
                    compact: true,
                  ),
                  const SizedBox(height: CFSpacing.sm),
                ],
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  CFYachayCard(
                    title: YachayMessages.title,
                    message:
                        'Aun no tienes una meta. Toda construccion comienza con el primer paso.',
                    mood: YachayAvatarMood.empty,
                    compact: true,
                    actionText: 'Crear meta',
                    onAction: () => _openForm(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumenMetas extends StatelessWidget {
  final dynamic resumen;
  const _ResumenMetas({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CFStatCard(
            label: 'Ahorrado',
            value: _money(resumen.totalActual),
            icon: Icons.savings_outlined,
            color: CFColors.success,
          ),
        ),
        const SizedBox(width: CFSpacing.sm),
        Expanded(
          child: CFStatCard(
            label: 'Objetivo',
            value: _money(resumen.totalObjetivo),
            icon: Icons.flag_outlined,
            color: CFColors.azulAndino,
          ),
        ),
      ],
    );
  }
}

class _Filtros extends StatelessWidget {
  final String? prioridad;
  final ValueChanged<String?> onPrioridad;

  const _Filtros({required this.prioridad, required this.onPrioridad});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CFSpacing.xs,
      children: [
        ChoiceChip(
          label: const Text('Todas'),
          selected: prioridad == null,
          onSelected: (_) => onPrioridad(null),
        ),
        ChoiceChip(
          label: const Text('Alta'),
          selected: prioridad == 'alta',
          onSelected: (_) => onPrioridad('alta'),
        ),
        ChoiceChip(
          label: const Text('Media'),
          selected: prioridad == 'media',
          onSelected: (_) => onPrioridad('media'),
        ),
        ChoiceChip(
          label: const Text('Baja'),
          selected: prioridad == 'baja',
          onSelected: (_) => onPrioridad('baja'),
        ),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  final MetaFinanciera item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onAporte;

  const _MetaCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onAporte,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.estaCompletada ? CFColors.success : CFColors.verdeValle;
    return CFCard(
      margin: const EdgeInsets.only(bottom: CFSpacing.sm),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(CFSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined, color: color),
                const SizedBox(width: CFSpacing.xs),
                Expanded(
                  child: Text(
                    item.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
            const SizedBox(height: CFSpacing.sm),
            LinearProgressIndicator(
              value: item.progreso,
              minHeight: 9,
              backgroundColor: CFColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: CFSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_money(item.montoActual)} / ${_money(item.montoObjetivo)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${(item.progreso * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: CFSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: CFOutlinedButton(
                label: 'Registrar aporte',
                onPressed: onAporte,
                icon: Icons.add_card_outlined,
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
      'alta' => CFColors.warning,
      'baja' => CFColors.textMuted,
      _ => CFColors.azulAndino,
    };
    return CFBadge(label: prioridad, color: color);
  }
}

String _money(double value) => 'S/ ${value.toStringAsFixed(2)}';
