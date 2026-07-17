import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/reporte.dart';
import '../app/riverpod/reporte_controller.dart';
import '../app/riverpod/reporte_state.dart';
import '../../../deudas_prestamos/presentation/app/riverpod/deuda_prestamo_controller.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  late int _mes;
  late int _anio;

  static const _meses = [
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
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = now.month;
    _anio = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref
        .read(reporteControllerProvider.notifier)
        .loadReporte(mes: _mes, anio: _anio, mesesFlujo: 6);
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mes += delta;
      if (_mes > 12) {
        _mes = 1;
        _anio++;
      }
      if (_mes < 1) {
        _mes = 12;
        _anio--;
      }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reporteControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: switch (state) {
                ReporteLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ReporteError(:final message) => _buildError(message),
                ReporteLoaded(:final data) => _buildContent(data),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Header con selector de mes ────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _cambiarMes(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            padding: EdgeInsets.zero,
          ),
          Text(
            '${_meses[_mes - 1]} $_anio',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: () => _cambiarMes(1),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.gasto, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            CFButton(label: 'Reintentar', onPressed: _load),
          ],
        ),
      ),
    );
  }

  // ── Contenido principal ───────────────────────────────────────────────────

  Widget _buildContent(ReporteData data) {
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(data.resumen),
            const SizedBox(height: 20),
            ref
                .watch(deudaPrestamoResumenProvider)
                .when(
                  data: (resumen) => _DeudasReporteCard(
                    totalDebo: resumen.totalDebo,
                    totalMeDeben: resumen.totalMeDeben,
                    balanceNeto: resumen.balanceNeto,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 20),
            if (data.gastosPorCategoria.isNotEmpty) ...[
              _buildSectionTitle('Gastos por Categoría'),
              const SizedBox(height: 12),
              _buildPieChart(data.gastosPorCategoria),
              const SizedBox(height: 20),
            ],
            _buildSectionTitle('Flujo Mensual (últimos 6 meses)'),
            const SizedBox(height: 12),
            _buildBarChart(data.flujoMensual),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Cards de resumen ──────────────────────────────────────────────────────

  Widget _buildSummaryCards(ResumenMes resumen) {
    final cards = [
      _SummaryCard(
        label: 'Ingresos',
        amount: resumen.totalIngresos,
        color: AppColors.ingreso,
        icon: Icons.arrow_downward_rounded,
      ),
      _SummaryCard(
        label: 'Gastos',
        amount: resumen.totalGastos,
        color: AppColors.gasto,
        icon: Icons.arrow_upward_rounded,
      ),
      _SummaryCard(
        label: 'Neto del mes',
        amount: resumen.neto,
        color: resumen.neto >= 0 ? AppColors.ingreso : AppColors.gasto,
        icon: Icons.balance_rounded,
      ),
      _SummaryCard(
        label: 'Balance total',
        amount: resumen.balanceTotalCuentas,
        color: AppColors.primary,
        icon: Icons.account_balance_wallet_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ── Pie chart ─────────────────────────────────────────────────────────────

  Widget _buildPieChart(List<GastoCategoria> gastos) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final sections = gastos.map((g) {
      final color = _hexToColor(g.color);
      return PieChartSectionData(
        value: g.monto,
        color: color,
        radius: mobile ? 50 : 60,
        showTitle: g.porcentaje >= 5,
        title: '${g.porcentaje.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return _Card(
      child: Column(
        children: [
          SizedBox(
            height: mobile ? 168 : 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: mobile ? 32 : 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Leyenda
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: gastos.map((g) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _hexToColor(g.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${g.nombre}  S/ ${g.monto.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Bar chart ─────────────────────────────────────────────────────────────

  Widget _buildBarChart(List<FlujoMes> flujo) {
    if (flujo.isEmpty) {
      return const _Card(
        child: Center(
          child: CFEmptyState(
            title: 'Sin datos para este periodo',
            message: 'Los gráficos aparecerán cuando existan movimientos.',
          ),
        ),
      );
    }

    final maxY = flujo.fold<double>(
      0,
      (prev, f) => [prev, f.ingresos, f.gastos].reduce((a, b) => a > b ? a : b),
    );

    final groups = flujo.asMap().entries.map((entry) {
      final i = entry.key;
      final f = entry.value;
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: f.ingresos,
            color: AppColors.ingreso,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: f.gastos,
            color: AppColors.gasto,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    const mesesAbrev = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return _Card(
      child: Column(
        children: [
          // Leyenda del bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.ingreso, label: 'Ingresos'),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.gasto, label: 'Gastos'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth < 520
                      ? 520
                      : constraints.maxWidth,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY * 1.2,
                      barGroups: groups,
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= flujo.length) {
                                return const SizedBox.shrink();
                              }
                              final mes = flujo[idx].mes;
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  mesesAbrev[mes - 1],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Utilidades ────────────────────────────────────────────────────────────

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return AppColors.textSecondary;
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DeudasReporteCard extends StatelessWidget {
  final double totalDebo;
  final double totalMeDeben;
  final double balanceNeto;

  const _DeudasReporteCard({
    required this.totalDebo,
    required this.totalMeDeben,
    required this.balanceNeto,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deudas y prestamos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _DebtMetric('Debo', totalDebo, AppColors.gasto)),
              Expanded(
                child: _DebtMetric('Me deben', totalMeDeben, AppColors.ingreso),
              ),
              Expanded(
                child: _DebtMetric(
                  'Neto',
                  balanceNeto,
                  balanceNeto >= 0 ? AppColors.ingreso : AppColors.gasto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _DebtMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'S/ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'S/ ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
