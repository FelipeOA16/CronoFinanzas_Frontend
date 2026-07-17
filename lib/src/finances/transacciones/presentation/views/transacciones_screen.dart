import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/brand/brand_shadows.dart';
import '../../../../../core/design_system/brand/brand_icons.dart';
import '../../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../../captura_rapida/presentation/app/riverpod/captura_rapida_controller.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/transaccion.dart';
import '../app/riverpod/transaccion_controller.dart';
import '../app/riverpod/transaccion_state.dart';
import '../widgets/transaccion_card.dart';

class TransaccionesScreen extends ConsumerStatefulWidget {
  const TransaccionesScreen({super.key});

  @override
  ConsumerState<TransaccionesScreen> createState() =>
      _TransaccionesScreenState();
}

class _TransaccionesScreenState extends ConsumerState<TransaccionesScreen> {
  int? _cuentaIdFiltro;
  String? _cuentaNombreFiltro;
  bool _argsLoaded = false;
  String _quickFilter = 'todos';
  String _searchQuery = '';
  late DateTime _periodo;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _periodo = DateTime(now.year, now.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _cuentaIdFiltro = args?['cuentaId'] as int?;
    _cuentaNombreFiltro = args?['cuentaNombre'] as String?;

    Future.microtask(() {
      ref
          .read(transaccionControllerProvider.notifier)
          .load(cuentaId: _cuentaIdFiltro, limit: 200);
      final cuentas = ref.read(cuentaControllerProvider);
      if (cuentas is CuentaInitial) {
        ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    ref
        .read(transaccionControllerProvider.notifier)
        .load(cuentaId: _cuentaIdFiltro, limit: 200);
  }

  void _changePeriod(int delta) {
    setState(() {
      _periodo = DateTime(_periodo.year, _periodo.month + delta);
    });
  }

  Future<void> _openForm({Transaccion? existing}) async {
    final state = ref.read(transaccionControllerProvider);
    List<Categoria> categorias = const [];
    if (state is TransaccionLoaded) categorias = state.categorias;
    if (state is TransaccionOperationSuccess) categorias = state.categorias;

    final result = await Navigator.pushNamed(
      context,
      '/transacciones/form',
      arguments: <String, dynamic>{
        'transaccion': existing,
        'categorias': categorias,
        if (_cuentaIdFiltro != null) 'cuentaId': _cuentaIdFiltro,
      },
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transaccionControllerProvider);
    final showExtendedFab = MediaQuery.sizeOf(context).width >= 840;

    ref.listen<TransaccionState>(transaccionControllerProvider, (_, next) {
      if (next is TransaccionOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: CFColors.success,
          ),
        );
      } else if (next is TransaccionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: CFColors.danger,
          ),
        );
      }
    });

    final items = switch (state) {
      TransaccionLoaded(:final items) => items,
      TransaccionOperationSuccess(:final items) => items,
      TransaccionError(:final previousItems) => previousItems,
      _ => <Transaccion>[],
    };
    final isLoading =
        state is TransaccionLoading || state is TransaccionInitial;
    final cuentasMap = _cuentasMap(ref.watch(cuentaControllerProvider));

    final periodItems = items
        .where(
          (item) =>
              item.fecha.year == _periodo.year &&
              item.fecha.month == _periodo.month,
        )
        .toList();
    final visibleItems = periodItems.where((item) {
      if (!_matchesFilter(item)) return false;
      return _matchesSearch(item, cuentasMap);
    }).toList()..sort((a, b) => b.fecha.compareTo(a.fecha));

    final ingresos = periodItems
        .where((item) => item.tipo == 'ingreso')
        .fold<double>(0, (total, item) => total + item.monto);
    final gastos = periodItems
        .where((item) => item.tipo == 'gasto')
        .fold<double>(0, (total, item) => total + item.monto);
    final listEntries = _buildListEntries(visibleItems);

    return Scaffold(
      backgroundColor: CFColors.marfil,
      appBar: AppBar(
        title: Text(
          _cuentaNombreFiltro == null
              ? 'Movimientos'
              : 'Movimientos - $_cuentaNombreFiltro',
        ),
        actions: [
          if (!showExtendedFab)
            IconButton(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              tooltip: 'Agregar',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      CFSpacing.md,
                      CFSpacing.md,
                      CFSpacing.md,
                      showExtendedFab ? 96 : 112,
                    ),
                    itemCount: 1 + (isLoading ? 0 : listEntries.length),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ExplorerHeader(
                          periodo: _periodo,
                          ingresos: ingresos,
                          gastos: gastos,
                          movimientos: periodItems.length,
                          searchController: _searchCtrl,
                          searchQuery: _searchQuery,
                          selectedFilter: _quickFilter,
                          onSearchChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          onClearSearch: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          onFilterChanged: (value) {
                            setState(() => _quickFilter = value);
                          },
                          onPreviousPeriod: () => _changePeriod(-1),
                          onNextPeriod: () => _changePeriod(1),
                          loading: isLoading,
                          empty: !isLoading && visibleItems.isEmpty,
                          hasAnyMovement: items.isNotEmpty,
                          onAdd: () => _openForm(),
                        );
                      }

                      final entry = listEntries[index - 1];
                      if (entry.date != null) {
                        return _DateHeader(date: entry.date!);
                      }
                      final transaction = entry.transaction!;
                      return TransaccionCard(
                        transaccion: transaction,
                        cuentaNombre: cuentasMap[transaction.cuentaId],
                        cuentaDestinoNombre: transaction.cuentaDestinoId == null
                            ? null
                            : cuentasMap[transaction.cuentaDestinoId!],
                        onEdit: () => _openForm(existing: transaction),
                        onDelete: () => ref
                            .read(transaccionControllerProvider.notifier)
                            .deleteTransaccion(transaction.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: CFExtendedFab(
        visible: showExtendedFab,
        onPressed: () => _openForm(),
      ),
    );
  }

  bool _matchesFilter(Transaccion item) {
    return switch (_quickFilter) {
      'ingreso' => item.tipo == 'ingreso',
      'gasto' => item.tipo == 'gasto',
      'transferencia' => item.tipo == 'transferencia',
      'recurrentes' => item.esRecurrente,
      _ => true,
    };
  }

  bool _matchesSearch(Transaccion item, Map<int, String> cuentas) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    final values = [
      item.descripcion,
      item.categoriaNombre,
      item.pagadoA,
      cuentas[item.cuentaId],
      item.cuentaDestinoId == null ? null : cuentas[item.cuentaDestinoId!],
    ];
    return values.any((value) => value?.toLowerCase().contains(query) ?? false);
  }

  Map<int, String> _cuentasMap(CuentaState state) {
    final cuentas = switch (state) {
      CuentaLoaded(:final cuentas) => cuentas,
      CuentaOperationSuccess(:final cuentas) => cuentas,
      CuentaError(:final previousCuentas) => previousCuentas,
      _ => const [],
    };
    return {for (final cuenta in cuentas) cuenta.id: cuenta.nombre};
  }

  List<_MovementListEntry> _buildListEntries(List<Transaccion> items) {
    final entries = <_MovementListEntry>[];
    DateTime? previousDate;
    for (final item in items) {
      final date = DateTime(item.fecha.year, item.fecha.month, item.fecha.day);
      if (previousDate != date) {
        entries.add(_MovementListEntry.date(date));
        previousDate = date;
      }
      entries.add(_MovementListEntry.transaction(item));
    }
    return entries;
  }
}

class _ExplorerHeader extends StatelessWidget {
  final DateTime periodo;
  final double ingresos;
  final double gastos;
  final int movimientos;
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;
  final bool loading;
  final bool empty;
  final bool hasAnyMovement;
  final VoidCallback onAdd;

  const _ExplorerHeader({
    required this.periodo,
    required this.ingresos,
    required this.gastos,
    required this.movimientos,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
    required this.loading,
    required this.empty,
    required this.hasAnyMovement,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PeriodSummary(
          periodo: periodo,
          ingresos: ingresos,
          gastos: gastos,
          movimientos: movimientos,
        ),
        const SizedBox(height: CFSpacing.md),
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar movimiento...',
            isDense: MediaQuery.sizeOf(context).width < 600,
            contentPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.sizeOf(context).width < 600 ? 12 : 16,
            ),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Limpiar busqueda',
                  ),
            filled: true,
            fillColor: CFColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CFRadius.md),
              borderSide: const BorderSide(color: CFColors.border),
            ),
          ),
        ),
        const SizedBox(height: CFSpacing.sm),
        _QuickFilters(selected: selectedFilter, onSelected: onFilterChanged),
        const SizedBox(height: CFSpacing.sm),
        _PeriodSelector(
          periodo: periodo,
          onPrevious: onPreviousPeriod,
          onNext: onNextPeriod,
        ),
        const SizedBox(height: CFSpacing.sm),
        const CFYachayCard(
          title: 'Yachay',
          message:
              'Observar tus movimientos con frecuencia puede ayudarte a decidir con mayor claridad.',
          mood: YachayAvatarMood.thinking,
          compact: true,
        ),
        const SizedBox(height: CFSpacing.sm),
        const _PendingCapturesNotice(),
        const SizedBox(height: CFSpacing.md),
        const CFSectionTitle(title: 'Movimientos del periodo'),
        const SizedBox(height: CFSpacing.xs),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: CFSpacing.xl),
            child: Center(
              child: CircularProgressIndicator(color: CFColors.verdeValle),
            ),
          )
        else if (empty)
          _MovementEmptyState(hasAnyMovement: hasAnyMovement, onAdd: onAdd),
      ],
    );
  }
}

class _PendingCapturesNotice extends ConsumerWidget {
  const _PendingCapturesNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(capturaRapidaResumenProvider)
        .when(
          data: (summary) {
            if (summary.pendientes == 0) return const SizedBox.shrink();
            return CFCard(
              padding: const EdgeInsets.all(CFSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    BrandIcons.quickCapture,
                    color: CFColors.azulAndino,
                  ),
                  const SizedBox(width: CFSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tienes ${summary.pendientes} capturas rapidas por completar.',
                    ),
                  ),
                  CFOutlinedButton(
                    label: 'Ver pendientes',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/capturas-rapidas'),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}

class _PeriodSummary extends StatelessWidget {
  final DateTime periodo;
  final double ingresos;
  final double gastos;
  final int movimientos;

  const _PeriodSummary({
    required this.periodo,
    required this.ingresos,
    required this.gastos,
    required this.movimientos,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.brandColors;
    final radius = context.brandRadius;
    final metrics = [
      _SummaryMetric(
        label: 'Ingresos',
        value: _money(ingresos),
        color: CFColors.success,
      ),
      _SummaryMetric(
        label: 'Gastos',
        value: _money(gastos),
        color: CFColors.danger,
      ),
      _SummaryMetric(
        label: 'Balance',
        value: _money(ingresos - gastos),
        color: ingresos - gastos >= 0 ? CFColors.verdeValle : CFColors.danger,
      ),
      _SummaryMetric(
        label: 'Movimientos',
        value: '$movimientos',
        color: CFColors.azulAndino,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(CFSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.verdeValle, colors.azulAndino],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius.radius20),
        boxShadow: BrandShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _monthYear(periodo),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: CFSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 4 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * CFSpacing.sm) /
                  columns;
              return Wrap(
                spacing: CFSpacing.sm,
                runSpacing: CFSpacing.sm,
                children: [
                  for (final metric in metrics)
                    SizedBox(width: width, child: metric),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CFSpacing.sm),
      decoration: BoxDecoration(
        color: CFColors.surfaceAlt,
        borderRadius: BorderRadius.circular(CFRadius.md),
        border: Border.all(color: CFColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: CFColors.textSecondary),
          ),
          const SizedBox(height: CFSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFilters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _QuickFilters({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    const allFilters = [
      ('todos', 'Todos'),
      ('ingreso', 'Ingresos'),
      ('gasto', 'Gastos'),
      ('transferencia', 'Transferencias'),
      ('recurrentes', 'Recurrentes'),
    ];
    final filters = mobile ? allFilters.take(4).toList() : allFilters;
    final itemCount = filters.length + (mobile ? 0 : 1);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: CFSpacing.xs),
        itemBuilder: (context, index) {
          if (!mobile && index == filters.length) {
            return const Tooltip(
              message: 'Disponible en una fase futura',
              child: ChoiceChip(
                label: Text('Favoritos'),
                selected: false,
                onSelected: null,
              ),
            );
          }
          final filter = filters[index];
          return ChoiceChip(
            label: Text(filter.$2),
            selected: selected == filter.$1,
            onSelected: (_) => onSelected(filter.$1),
          );
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final DateTime periodo;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PeriodSelector({
    required this.periodo,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: const EdgeInsets.symmetric(
        horizontal: CFSpacing.xs,
        vertical: CFSpacing.xxs,
      ),
      child: Row(
        children: [
          CFIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: onPrevious,
            tooltip: 'Mes anterior',
          ),
          Expanded(
            child: Text(
              _monthYear(periodo),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CFColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          CFIconButton(
            icon: Icons.chevron_right_rounded,
            onPressed: onNext,
            tooltip: 'Mes siguiente',
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CFSpacing.xs,
        CFSpacing.md,
        CFSpacing.xs,
        CFSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: context.brandColors.oroInca,
              borderRadius: BorderRadius.circular(context.brandRadius.pill),
            ),
          ),
          const SizedBox(width: CFSpacing.xs),
          Text(
            _dateLabel(date),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.brandColors.azulAndino,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementEmptyState extends StatelessWidget {
  final bool hasAnyMovement;
  final VoidCallback onAdd;

  const _MovementEmptyState({
    required this.hasAnyMovement,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (hasAnyMovement) {
      return const CFEmptyState(
        title: 'Sin resultados',
        message: 'No hay movimientos para este periodo o filtro.',
      );
    }
    return Column(
      children: [
        const CFEmptyIllustration(
          type: CFEmptyIllustrationType.transactions,
          size: 96,
        ),
        const SizedBox(height: CFSpacing.sm),
        Text(
          'Aun no registras movimientos.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: CFSpacing.xs),
        Text(
          'Agrega tu primer movimiento para empezar a explorar tu dinero.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: CFSpacing.md),
        CFButton(label: 'Agregar', icon: Icons.add, onPressed: onAdd),
        const SizedBox(height: CFSpacing.md),
      ],
    );
  }
}

class _MovementListEntry {
  final DateTime? date;
  final Transaccion? transaction;

  const _MovementListEntry.date(this.date) : transaction = null;
  const _MovementListEntry.transaction(this.transaction) : date = null;
}

String _money(double value) => 'S/ ${value.toStringAsFixed(2)}';

String _monthYear(DateTime value) {
  const months = [
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
  return '${months[value.month - 1]} ${value.year}';
}

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (date == today) return 'HOY';
  if (date == today.subtract(const Duration(days: 1))) return 'AYER';
  return '${date.day} ${_monthYear(date).split(' ').first.toLowerCase()}';
}
