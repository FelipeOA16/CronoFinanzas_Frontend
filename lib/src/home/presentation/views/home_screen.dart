import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/brand/brand_icons.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../app/di/providers.dart';
import '../../../auth/presentation/app/riverpod/auth_state.dart';
import '../../../auth/presentation/widgets/login_form.dart';
import '../../../education/data/financial_lessons.dart';
import '../../../finances/deudas_prestamos/domain/entities/deuda_prestamo_resumen.dart';
import '../../../finances/deudas_prestamos/presentation/app/riverpod/deuda_prestamo_controller.dart';
import '../../../finances/captura_rapida/presentation/app/riverpod/captura_rapida_controller.dart';
import '../../../finances/metas/domain/entities/meta_financiera_resumen.dart';
import '../../../finances/metas/presentation/app/riverpod/meta_financiera_controller.dart';
import '../../../finances/presupuestos/domain/entities/presupuesto.dart';
import '../../../finances/presupuestos/presentation/app/riverpod/presupuesto_controller.dart';
import '../../../finances/presupuestos/presentation/app/riverpod/presupuesto_state.dart';
import '../../../finances/reportes/presentation/app/riverpod/reporte_controller.dart';
import '../../../finances/reportes/presentation/app/riverpod/reporte_state.dart';
import '../../../finances/transacciones/domain/entities/transaccion.dart';
import '../../../finances/transacciones/presentation/app/riverpod/transaccion_controller.dart';
import '../../../finances/transacciones/presentation/app/riverpod/transaccion_state.dart';
import '../../../guide/yachay_messages.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref
          .read(reporteControllerProvider.notifier)
          .loadReporte(mes: now.month, anio: now.year);
      ref
          .read(presupuestoControllerProvider.notifier)
          .loadPresupuestos(mes: now.month, anio: now.year);
      ref.read(transaccionControllerProvider.notifier).load(limit: 5);
    });
  }

  String _displayName() {
    final state = ref.read(authControllerProvider);
    if (state is AuthAuthenticated) return state.user.displayName;
    return 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    final patrimonioAsync = ref.watch(patrimonioProvider);
    final patrimonioNetoAsync = ref.watch(patrimonioNetoEstimadoProvider);
    final deudasResumenAsync = ref.watch(deudaPrestamoResumenProvider);
    final metasResumenAsync = ref.watch(metaFinancieraResumenProvider);
    final reporteState = ref.watch(reporteControllerProvider);
    final presupuestoState = ref.watch(presupuestoControllerProvider);
    final transaccionState = ref.watch(transaccionControllerProvider);

    double ingresos = 0, gastos = 0, neto = 0;
    if (reporteState is ReporteLoaded) {
      ingresos = reporteState.data.resumen.totalIngresos;
      gastos = reporteState.data.resumen.totalGastos;
      neto = reporteState.data.resumen.neto;
    }

    final patrimonio = patrimonioAsync.when(
      data: (v) => v,
      loading: () => null,
      error: (_, __) => 0.0,
    );
    final netoEstimado = patrimonioNetoAsync.when(
      data: (v) => v,
      loading: () => null,
      error: (_, __) => null,
    );

    final presupuestos = _presupuestosFromState(presupuestoState);
    final presupuesto = _BudgetSnapshot.fromPresupuestos(
      presupuestos,
      gastosDelMes: gastos,
    );
    final movimientos = _transaccionesFromState(transaccionState);
    final loadingReport =
        reporteState is ReporteLoading || reporteState is ReporteInitial;

    return Scaffold(
      backgroundColor: CFColors.marfil,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final desktop = width >= 1100;
            final mobile = width < 600;
            final tablet = width >= 600 && !desktop;
            final horizontalPadding = desktop
                ? 32.0
                : tablet
                ? 24.0
                : 16.0;
            final contentMaxWidth = desktop ? 1240.0 : double.infinity;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                CFSpacing.sm,
                horizontalPadding,
                mobile ? 112 : 88,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeTopBar(displayName: _displayName(), compact: mobile),
                      SizedBox(height: mobile ? CFSpacing.sm : CFSpacing.lg),
                      if (desktop)
                        _DesktopHomeLayout(
                          patrimonio: patrimonio,
                          netoEstimado: netoEstimado,
                          presupuesto: presupuesto,
                          ingresos: ingresos,
                          gastos: gastos,
                          neto: neto,
                          loadingReport: loadingReport,
                          deudasResumenAsync: deudasResumenAsync,
                          metasResumenAsync: metasResumenAsync,
                          movimientos: movimientos,
                          loadingMovimientos:
                              transaccionState is TransaccionLoading ||
                              transaccionState is TransaccionInitial,
                        )
                      else if (mobile)
                        _MobileHomeLayout(
                          patrimonio: patrimonio,
                          netoEstimado: netoEstimado,
                          presupuesto: presupuesto,
                          ingresos: ingresos,
                          gastos: gastos,
                          neto: neto,
                          loadingReport: loadingReport,
                          deudasResumenAsync: deudasResumenAsync,
                          metasResumenAsync: metasResumenAsync,
                          movimientos: movimientos,
                          loadingMovimientos:
                              transaccionState is TransaccionLoading ||
                              transaccionState is TransaccionInitial,
                        )
                      else
                        _StackedHomeLayout(
                          patrimonio: patrimonio,
                          netoEstimado: netoEstimado,
                          presupuesto: presupuesto,
                          ingresos: ingresos,
                          gastos: gastos,
                          neto: neto,
                          loadingReport: loadingReport,
                          deudasResumenAsync: deudasResumenAsync,
                          metasResumenAsync: metasResumenAsync,
                          movimientos: movimientos,
                          loadingMovimientos:
                              transaccionState is TransaccionLoading ||
                              transaccionState is TransaccionInitial,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MobileHomeLayout extends StatelessWidget {
  final double? patrimonio;
  final double? netoEstimado;
  final _BudgetSnapshot presupuesto;
  final double ingresos;
  final double gastos;
  final double neto;
  final bool loadingReport;
  final AsyncValue<DeudaPrestamoResumen> deudasResumenAsync;
  final AsyncValue<MetaFinancieraResumen> metasResumenAsync;
  final List<Transaccion> movimientos;
  final bool loadingMovimientos;

  const _MobileHomeLayout({
    required this.patrimonio,
    required this.netoEstimado,
    required this.presupuesto,
    required this.ingresos,
    required this.gastos,
    required this.neto,
    required this.loadingReport,
    required this.deudasResumenAsync,
    required this.metasResumenAsync,
    required this.movimientos,
    required this.loadingMovimientos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          labelSmall: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
        ),
      ),
      child: Column(
        children: [
          _PatrimonioHero(
            patrimonio: patrimonio,
            netoEstimado: netoEstimado,
            compact: true,
          ),
          const SizedBox(height: CFSpacing.sm),
          _FinancialSummaryGrid(
            ingresos: ingresos,
            gastos: gastos,
            neto: neto,
            loading: loadingReport,
            compact: true,
          ),
          const SizedBox(height: CFSpacing.sm),
          _MonthlyBudgetPremiumCard(snapshot: presupuesto, compact: true),
          const SizedBox(height: CFSpacing.sm),
          deudasResumenAsync.when(
            data: (resumen) =>
                _CommitmentsCard(resumen: resumen, maxItems: 2, compact: true),
            loading: () => const _PanelLoading(
              title: 'Proximos compromisos',
              compact: true,
            ),
            error: (_, __) =>
                const _PanelError(title: 'Proximos compromisos', compact: true),
          ),
          const SizedBox(height: CFSpacing.sm),
          metasResumenAsync.when(
            data: (resumen) =>
                _GoalsCompactCard(resumen: resumen, compact: true),
            loading: () =>
                const _PanelLoading(title: 'Metas financieras', compact: true),
            error: (_, __) =>
                const _PanelError(title: 'Metas financieras', compact: true),
          ),
          const SizedBox(height: CFSpacing.sm),
          deudasResumenAsync.when(
            data: (resumen) =>
                _DebtPremiumCard(resumen: resumen, compact: true),
            loading: () =>
                const _PanelLoading(title: 'Deudas y prestamos', compact: true),
            error: (_, __) =>
                const _PanelError(title: 'Deudas y prestamos', compact: true),
          ),
          const SizedBox(height: CFSpacing.sm),
          const _QuickCaptureHomeCard(compact: true),
          const SizedBox(height: CFSpacing.sm),
          _RecentMovementsCard(
            movimientos: movimientos.take(3).toList(),
            loading: loadingMovimientos,
            compact: true,
          ),
          const SizedBox(height: CFSpacing.sm),
          CFYachayCard(
            title: YachayMessages.title,
            message: _homeYachayMessage(
              patrimonio: patrimonio,
              ingresos: ingresos,
              gastos: gastos,
              presupuesto: presupuesto,
              metasResumenAsync: metasResumenAsync,
              movimientos: movimientos,
            ),
            mood: YachayAvatarMood.thinking,
            actionText: 'Ver leccion',
            compact: true,
            onAction: () => Navigator.of(context).pushNamed(
              '/education/lesson',
              arguments: FinancialLessons.featured,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHomeLayout extends StatelessWidget {
  final double? patrimonio;
  final double? netoEstimado;
  final _BudgetSnapshot presupuesto;
  final double ingresos;
  final double gastos;
  final double neto;
  final bool loadingReport;
  final AsyncValue<DeudaPrestamoResumen> deudasResumenAsync;
  final AsyncValue<MetaFinancieraResumen> metasResumenAsync;
  final List<Transaccion> movimientos;
  final bool loadingMovimientos;

  const _DesktopHomeLayout({
    required this.patrimonio,
    required this.netoEstimado,
    required this.presupuesto,
    required this.ingresos,
    required this.gastos,
    required this.neto,
    required this.loadingReport,
    required this.deudasResumenAsync,
    required this.metasResumenAsync,
    required this.movimientos,
    required this.loadingMovimientos,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _PatrimonioHero(
                patrimonio: patrimonio,
                netoEstimado: netoEstimado,
              ),
              const SizedBox(height: CFSpacing.md),
              _FinancialSummaryGrid(
                ingresos: ingresos,
                gastos: gastos,
                neto: neto,
                loading: loadingReport,
              ),
              const SizedBox(height: CFSpacing.md),
              _MonthlyBudgetPremiumCard(snapshot: presupuesto),
              const SizedBox(height: CFSpacing.md),
              metasResumenAsync.when(
                data: (resumen) => _GoalsCompactCard(resumen: resumen),
                loading: () => const _PanelLoading(title: 'Metas financieras'),
                error: (_, __) => const _PanelError(title: 'Metas financieras'),
              ),
              const SizedBox(height: CFSpacing.md),
              const _QuickCaptureHomeCard(),
              const SizedBox(height: CFSpacing.md),
              _RecentMovementsCard(
                movimientos: movimientos,
                loading: loadingMovimientos,
              ),
            ],
          ),
        ),
        const SizedBox(width: CFSpacing.md),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              deudasResumenAsync.when(
                data: (resumen) => _DebtPremiumCard(resumen: resumen),
                loading: () => const _PanelLoading(title: 'Deudas y prestamos'),
                error: (_, __) =>
                    const _PanelError(title: 'Deudas y prestamos'),
              ),
              const SizedBox(height: CFSpacing.md),
              deudasResumenAsync.when(
                data: (resumen) => _CommitmentsCard(resumen: resumen),
                loading: () =>
                    const _PanelLoading(title: 'Proximos compromisos'),
                error: (_, __) =>
                    const _PanelError(title: 'Proximos compromisos'),
              ),
              const SizedBox(height: CFSpacing.md),
              CFYachayCard(
                title: YachayMessages.title,
                message: _homeYachayMessage(
                  patrimonio: patrimonio,
                  ingresos: ingresos,
                  gastos: gastos,
                  presupuesto: presupuesto,
                  metasResumenAsync: metasResumenAsync,
                  movimientos: movimientos,
                ),
                mood: YachayAvatarMood.thinking,
                actionText: 'Ver leccion',
                onAction: () => Navigator.of(context).pushNamed(
                  '/education/lesson',
                  arguments: FinancialLessons.featured,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StackedHomeLayout extends StatelessWidget {
  final double? patrimonio;
  final double? netoEstimado;
  final _BudgetSnapshot presupuesto;
  final double ingresos;
  final double gastos;
  final double neto;
  final bool loadingReport;
  final AsyncValue<DeudaPrestamoResumen> deudasResumenAsync;
  final AsyncValue<MetaFinancieraResumen> metasResumenAsync;
  final List<Transaccion> movimientos;
  final bool loadingMovimientos;

  const _StackedHomeLayout({
    required this.patrimonio,
    required this.netoEstimado,
    required this.presupuesto,
    required this.ingresos,
    required this.gastos,
    required this.neto,
    required this.loadingReport,
    required this.deudasResumenAsync,
    required this.metasResumenAsync,
    required this.movimientos,
    required this.loadingMovimientos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PatrimonioHero(patrimonio: patrimonio, netoEstimado: netoEstimado),
        const SizedBox(height: CFSpacing.md),
        _FinancialSummaryGrid(
          ingresos: ingresos,
          gastos: gastos,
          neto: neto,
          loading: loadingReport,
        ),
        const SizedBox(height: CFSpacing.md),
        _MonthlyBudgetPremiumCard(snapshot: presupuesto),
        const SizedBox(height: CFSpacing.md),
        metasResumenAsync.when(
          data: (resumen) => _GoalsCompactCard(resumen: resumen),
          loading: () => const _PanelLoading(title: 'Metas financieras'),
          error: (_, __) => const _PanelError(title: 'Metas financieras'),
        ),
        const SizedBox(height: CFSpacing.md),
        deudasResumenAsync.when(
          data: (resumen) => _DebtPremiumCard(resumen: resumen),
          loading: () => const _PanelLoading(title: 'Deudas y prestamos'),
          error: (_, __) => const _PanelError(title: 'Deudas y prestamos'),
        ),
        const SizedBox(height: CFSpacing.md),
        deudasResumenAsync.when(
          data: (resumen) => _CommitmentsCard(resumen: resumen),
          loading: () => const _PanelLoading(title: 'Proximos compromisos'),
          error: (_, __) => const _PanelError(title: 'Proximos compromisos'),
        ),
        const SizedBox(height: CFSpacing.md),
        const _QuickCaptureHomeCard(),
        const SizedBox(height: CFSpacing.md),
        _RecentMovementsCard(
          movimientos: movimientos,
          loading: loadingMovimientos,
        ),
        const SizedBox(height: CFSpacing.md),
        CFYachayCard(
          title: YachayMessages.title,
          message: _homeYachayMessage(
            patrimonio: patrimonio,
            ingresos: ingresos,
            gastos: gastos,
            presupuesto: presupuesto,
            metasResumenAsync: metasResumenAsync,
            movimientos: movimientos,
          ),
          mood: YachayAvatarMood.thinking,
          actionText: 'Ver leccion',
          onAction: () => Navigator.of(context).pushNamed(
            '/education/lesson',
            arguments: FinancialLessons.featured,
          ),
        ),
      ],
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final String displayName;
  final bool compact;

  const _HomeTopBar({required this.displayName, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isEmpty ? 'U' : displayName[0].toUpperCase();
    return Row(
      children: [
        Container(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CFColors.verdeValle, CFColors.azulAndino],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(CFRadius.lg),
            boxShadow: CFShadows.subtle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: CFSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineSmall)
                        ?.copyWith(
                          color: CFColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
              ),
              const SizedBox(height: 2),
              Text(
                'Cultiva hoy el futuro que imaginas',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: CFColors.textSecondary),
              ),
            ],
          ),
        ),
        CFIconButton(
          onPressed: () => Navigator.of(context).pushNamed('/profile'),
          icon: BrandIcons.alerts,
          tooltip: 'Notificaciones',
        ),
      ],
    );
  }
}

class _PatrimonioHero extends StatelessWidget {
  final double? patrimonio;
  final double? netoEstimado;
  final bool compact;

  const _PatrimonioHero({
    required this.patrimonio,
    required this.netoEstimado,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CFColors.verdeValle, CFColors.azulAndino],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CFRadius.xl),
        boxShadow: CFShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 36 : 42,
                height: compact ? 36 : 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(CFRadius.md),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  CFIcons.wallet,
                  color: CFColors.oroInca,
                  size: 22,
                ),
              ),
              const SizedBox(width: CFSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patrimonio actual',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Suma de tus cuentas activas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.visibility_outlined,
                size: 20,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ],
          ),
          SizedBox(height: compact ? CFSpacing.sm : CFSpacing.lg),
          patrimonio == null
              ? const SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : Text(
                  _money(patrimonio!),
                  style:
                      (compact
                              ? Theme.of(context).textTheme.headlineMedium
                              : Theme.of(context).textTheme.displayMedium)
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                ),
          if (netoEstimado != null) ...[
            SizedBox(height: compact ? CFSpacing.sm : CFSpacing.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: CFSpacing.sm,
                vertical: compact ? CFSpacing.xs : CFSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(CFRadius.md),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.balance_outlined,
                    color: CFColors.oroInca,
                    size: 18,
                  ),
                  const SizedBox(width: CFSpacing.xs),
                  Expanded(
                    child: Text(
                      'Neto estimado: ${_money(netoEstimado!)}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinancialSummaryGrid extends StatelessWidget {
  final double ingresos;
  final double gastos;
  final double neto;
  final bool loading;
  final bool compact;

  const _FinancialSummaryGrid({
    required this.ingresos,
    required this.gastos,
    required this.neto,
    required this.loading,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CFLoadingState(message: 'Cargando resumen financiero');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _PremiumMetricCard(
            label: 'Ingresos',
            value: _money(ingresos),
            icon: CFIcons.income,
            color: CFColors.success,
            helper: 'Este mes',
            compact: compact,
          ),
          _PremiumMetricCard(
            label: 'Gastos',
            value: _money(gastos),
            icon: CFIcons.expense,
            color: CFColors.danger,
            helper: 'Este mes',
            compact: compact,
          ),
          _PremiumMetricCard(
            label: 'Ahorro',
            value: _money(neto),
            icon: Icons.savings_outlined,
            color: neto >= 0 ? CFColors.verdeValle : CFColors.danger,
            helper: 'Ingresos - gastos',
            compact: compact,
          ),
        ];

        if (compact) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: CFSpacing.xs),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: CFSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _PremiumMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String helper;
  final bool compact;

  const _PremiumMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.helper,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      elevated: true,
      padding: EdgeInsets.all(compact ? CFSpacing.sm : CFSpacing.md),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: CFSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CFColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
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
            )
          : Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(CFRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: CFSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: CFColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        helper,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: CFColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _MonthlyBudgetPremiumCard extends StatelessWidget {
  final _BudgetSnapshot snapshot;
  final bool compact;

  const _MonthlyBudgetPremiumCard({
    required this.snapshot,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = snapshot.hasBudget
        ? (snapshot.gastado / snapshot.limite).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final progressColor = snapshot.porcentaje >= 90
        ? CFColors.danger
        : snapshot.porcentaje >= 70
        ? CFColors.warning
        : CFColors.verdeValle;

    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: CFIcons.budgets,
            title: 'Presupuesto mensual',
            subtitle: snapshot.hasBudget
                ? snapshot.label
                : 'Sin presupuesto activo para este mes',
          ),
          SizedBox(height: compact ? CFSpacing.sm : CFSpacing.md),
          _BudgetMetrics(snapshot: snapshot, compact: compact),
          SizedBox(height: compact ? CFSpacing.sm : CFSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(CFRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: CFColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          const SizedBox(height: CFSpacing.xs),
          Row(
            children: [
              Text(
                '${snapshot.porcentaje.toStringAsFixed(0)}% utilizado',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!compact) ...[
                const Spacer(),
                Text(
                  snapshot.hasBudget
                      ? 'Presupuesto restante: ${_money(snapshot.disponible)}'
                      : 'Sin presupuesto definido',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetMetrics extends StatelessWidget {
  final _BudgetSnapshot snapshot;
  final bool compact;

  const _BudgetMetrics({required this.snapshot, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _BudgetAmount(
        label: 'Limite mensual',
        value: snapshot.hasBudget ? _money(snapshot.limite) : '--',
        color: CFColors.azulAndino,
        compact: compact,
      ),
      _BudgetAmount(
        label: 'Gastado',
        value: _money(snapshot.gastado),
        color: CFColors.danger,
        compact: compact,
      ),
      _BudgetAmount(
        label: 'Presupuesto restante',
        value: snapshot.hasBudget ? _money(snapshot.disponible) : '--',
        color: CFColors.success,
        compact: compact,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              metrics[i],
              if (i < metrics.length - 1) const SizedBox(width: CFSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _BudgetAmount extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool compact;

  const _BudgetAmount({
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(compact ? CFSpacing.xs : CFSpacing.sm),
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
              ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtPremiumCard extends StatelessWidget {
  final DeudaPrestamoResumen resumen;
  final bool compact;

  const _DebtPremiumCard({required this.resumen, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: CFIcons.debts,
            title: 'Deudas y prestamos',
            subtitle: 'Resumen de saldos pendientes',
          ),
          SizedBox(height: compact ? CFSpacing.sm : CFSpacing.md),
          Row(
            children: [
              _DebtMetric(
                label: 'Por pagar',
                value: resumen.totalDebo,
                color: CFColors.danger,
              ),
              const SizedBox(width: CFSpacing.sm),
              _DebtMetric(
                label: 'Por cobrar',
                value: resumen.totalMeDeben,
                color: CFColors.success,
              ),
            ],
          ),
          const SizedBox(height: CFSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CFSpacing.sm),
            decoration: BoxDecoration(
              color: resumen.balanceNeto >= 0
                  ? CFColors.success.withValues(alpha: 0.09)
                  : CFColors.danger.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(CFRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  resumen.balanceNeto >= 0
                      ? Icons.north_east_rounded
                      : Icons.south_west_rounded,
                  color: resumen.balanceNeto >= 0
                      ? CFColors.success
                      : CFColors.danger,
                  size: 18,
                ),
                const SizedBox(width: CFSpacing.xs),
                Expanded(
                  child: Text(
                    'Neto de deudas: ${_money(resumen.balanceNeto)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: resumen.balanceNeto >= 0
                          ? CFColors.success
                          : CFColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsCompactCard extends StatelessWidget {
  final MetaFinancieraResumen resumen;
  final bool compact;

  const _GoalsCompactCard({required this.resumen, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final metas = resumen.topMetas.take(2).toList();
    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.flag_outlined,
            title: 'Metas financieras',
            subtitle: 'Avance de tus objetivos activos',
          ),
          SizedBox(height: compact ? CFSpacing.sm : CFSpacing.md),
          if (metas.isEmpty)
            const _GoalsEmptyState()
          else ...[
            Row(
              children: [
                _BudgetAmount(
                  label: 'Avance',
                  value: _money(resumen.totalActual),
                  color: CFColors.success,
                ),
                const SizedBox(width: CFSpacing.sm),
                _BudgetAmount(
                  label: 'Objetivo',
                  value: _money(resumen.totalObjetivo),
                  color: CFColors.azulAndino,
                ),
              ],
            ),
            SizedBox(height: compact ? CFSpacing.sm : CFSpacing.md),
            Column(
              children: [
                for (var i = 0; i < metas.length; i++) ...[
                  _GoalSummaryTile(item: metas[i]),
                  if (i < metas.length - 1)
                    const Divider(height: 18, color: CFColors.border),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalsEmptyState extends StatelessWidget {
  const _GoalsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CFSpacing.md),
      decoration: BoxDecoration(
        color: CFColors.surfaceMuted,
        borderRadius: BorderRadius.circular(CFRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aun no tienes metas financieras',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CFColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CFSpacing.xxs),
          Text(
            'Crea tu primera meta para darle direccion a tu dinero',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: CFColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _GoalSummaryTile extends StatelessWidget {
  final MetaFinancieraResumenItem item;

  const _GoalSummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final progress = (item.porcentaje / 100).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${item.porcentaje.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CFColors.verdeValle,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: CFSpacing.xs),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: CFColors.surfaceMuted,
          valueColor: const AlwaysStoppedAnimation(CFColors.verdeValle),
        ),
        const SizedBox(height: CFSpacing.xs),
        Text(
          '${_money(item.montoActual)} / ${_money(item.montoObjetivo)}',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
        ),
      ],
    );
  }
}

class _DebtMetric extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _DebtMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(CFSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(CFRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
            ),
            const SizedBox(height: 3),
            Text(
              _money(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommitmentsCard extends StatelessWidget {
  final DeudaPrestamoResumen resumen;
  final int maxItems;
  final bool compact;

  const _CommitmentsCard({
    required this.resumen,
    this.maxItems = 3,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = resumen.proximas.take(maxItems).toList();
    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: CFIcons.calendar,
            title: 'Proximos compromisos',
            subtitle: 'Pagos y cobros registrados',
          ),
          const SizedBox(height: CFSpacing.sm),
          if (items.isEmpty)
            const _QuietEmpty(text: 'No hay compromisos proximos.')
          else
            Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _CommitmentTile(item: items[i]),
                  if (i < items.length - 1)
                    const Divider(height: 18, color: CFColors.border),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CommitmentTile extends StatelessWidget {
  final DeudaPrestamoResumenItem item;

  const _CommitmentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDebt = item.tipo == 'debo';
    final color = isDebt ? CFColors.danger : CFColors.success;
    final hasNextAmount = item.montoProximo != null;
    final amountLabel = hasNextAmount
        ? (isDebt ? 'Proximo pago' : 'Proximo cobro')
        : 'Saldo pendiente';
    final amount = item.montoProximo ?? item.saldoPendiente;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(CFRadius.sm),
          ),
          child: Icon(
            isDebt ? Icons.call_made_rounded : Icons.call_received_rounded,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: CFSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CFColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.fechaProxima == null
                    ? item.contraparte
                    : '${_date(item.fechaProxima!)} - ${item.contraparte}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: CFSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountLabel,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              _money(amount),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickCaptureHomeCard extends ConsumerWidget {
  final bool compact;

  const _QuickCaptureHomeCard({this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(capturaRapidaResumenProvider)
        .when(
          data: (summary) {
            if (summary.pendientes == 0) return const SizedBox.shrink();
            final latest = summary.ultimaCaptura;
            final latestText = latest == null
                ? null
                : 'Ultima: S/ ${latest.monto.toStringAsFixed(2)} - '
                      '${latest.tipo[0].toUpperCase()}${latest.tipo.substring(1)}';
            return CFCard(
              padding: EdgeInsets.all(compact ? CFSpacing.sm : CFSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    BrandIcons.quickCapture,
                    color: CFColors.azulAndino,
                  ),
                  const SizedBox(width: CFSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capturas pendientes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('${summary.pendientes} por completar'),
                        if (latestText != null)
                          Text(
                            latestText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  CFOutlinedButton(
                    label: 'Completar',
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

class _RecentMovementsCard extends StatelessWidget {
  final List<Transaccion> movimientos;
  final bool loading;
  final bool compact;

  const _RecentMovementsCard({
    required this.movimientos,
    required this.loading,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Movimientos recientes',
            subtitle: 'Ultimas transacciones registradas',
            trailing: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/transacciones'),
              child: const Text('Ver todos'),
            ),
          ),
          const SizedBox(height: CFSpacing.sm),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CFSpacing.md),
              child: Center(
                child: CircularProgressIndicator(
                  color: CFColors.verdeValle,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (movimientos.isEmpty)
            const _QuietEmpty(text: 'Todavia no hay movimientos.')
          else
            Column(
              children: [
                for (var i = 0; i < movimientos.length; i++) ...[
                  _MovementTile(transaccion: movimientos[i]),
                  if (i < movimientos.length - 1)
                    const Divider(height: 18, color: CFColors.border),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final Transaccion transaccion;

  const _MovementTile({required this.transaccion});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaccion.tipo == 'ingreso';
    final isTransfer = transaccion.tipo == 'transferencia';
    final color = isIncome
        ? CFColors.success
        : isTransfer
        ? CFColors.info
        : CFColors.danger;
    final title = transaccion.descripcion?.trim().isNotEmpty == true
        ? transaccion.descripcion!.trim()
        : _tipoLabel(transaccion.tipo);
    final sign = isIncome
        ? '+'
        : isTransfer
        ? ''
        : '-';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(CFRadius.sm),
          ),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : isTransfer
                ? Icons.swap_horiz_rounded
                : Icons.arrow_upward_rounded,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: CFSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CFColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_tipoLabel(transaccion.tipo)} - ${_date(transaccion.fecha)}',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: CFSpacing.sm),
        Text(
          '$sign${_money(transaccion.monto)}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CFColors.verdeValle.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(CFRadius.sm),
          ),
          child: Icon(icon, color: CFColors.verdeValle, size: 18),
        ),
        const SizedBox(width: CFSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CFColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: CFColors.textMuted),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _PanelLoading extends StatelessWidget {
  final String title;
  final bool compact;

  const _PanelLoading({required this.title, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.sync_rounded,
            title: title,
            subtitle: 'Cargando informacion',
          ),
          const SizedBox(height: CFSpacing.md),
          const Center(
            child: CircularProgressIndicator(
              color: CFColors.verdeValle,
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelError extends StatelessWidget {
  final String title;
  final bool compact;

  const _PanelError({required this.title, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return CFCard(
      padding: EdgeInsets.all(compact ? CFSpacing.md : CFSpacing.lg),
      child: _PanelHeader(
        icon: CFIcons.error,
        title: title,
        subtitle: 'No se pudo cargar la informacion',
      ),
    );
  }
}

class _QuietEmpty extends StatelessWidget {
  final String text;

  const _QuietEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: CFSpacing.md,
        horizontal: CFSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: CFColors.surfaceMuted,
        borderRadius: BorderRadius.circular(CFRadius.md),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: CFColors.textMuted),
      ),
    );
  }
}

String _homeYachayMessage({
  required double? patrimonio,
  required double ingresos,
  required double gastos,
  required _BudgetSnapshot presupuesto,
  required AsyncValue<MetaFinancieraResumen> metasResumenAsync,
  required List<Transaccion> movimientos,
}) {
  if (patrimonio != null && patrimonio <= 0) {
    return 'Empieza creando tu primera cuenta para ver tu camino financiero.';
  }

  final metas = metasResumenAsync.asData?.value;
  if (metas != null &&
      metas.cantidadActivas == 0 &&
      metas.cantidadCompletadas == 0) {
    return 'Una meta pequena puede darle direccion a tu dinero.';
  }

  if (!presupuesto.hasBudget) {
    return 'Este puede ser un buen momento para preparar tu presupuesto.';
  }

  if (movimientos.isEmpty) {
    return 'No registras movimientos recientes. Observarlos mantiene claro tu camino.';
  }

  if (ingresos > 0) {
    final porcentaje = ((gastos / ingresos) * 100).clamp(0, 999);
    return 'Tus gastos representan el ${porcentaje.toStringAsFixed(0)}% de tus ingresos este mes.';
  }

  return 'Este mes llevas buen ritmo. Cada registro ayuda a mirar tu dinero con claridad.';
}

class _BudgetSnapshot {
  final double limite;
  final double gastado;
  final double disponible;
  final double porcentaje;
  final String label;
  final bool hasBudget;

  const _BudgetSnapshot({
    required this.limite,
    required this.gastado,
    required this.disponible,
    required this.porcentaje,
    required this.label,
    required this.hasBudget,
  });

  factory _BudgetSnapshot.fromPresupuestos(
    List<Presupuesto> presupuestos, {
    required double gastosDelMes,
  }) {
    if (presupuestos.isEmpty) {
      return _BudgetSnapshot(
        limite: 0,
        gastado: gastosDelMes,
        disponible: 0,
        porcentaje: 0,
        label: 'Presupuesto mensual',
        hasBudget: false,
      );
    }

    final globales = presupuestos.where((p) => p.esGlobal).toList();
    if (globales.isNotEmpty) {
      final p = globales.first;
      return _BudgetSnapshot(
        limite: p.montoLimite,
        gastado: p.montoGastado,
        disponible: math.max(p.montoDisponible, 0.0),
        porcentaje: p.porcentaje,
        label: 'Presupuesto global',
        hasBudget: p.montoLimite > 0,
      );
    }

    final limite = presupuestos.fold<double>(
      0,
      (total, p) => total + p.montoLimite,
    );
    final gastado = presupuestos.fold<double>(
      0,
      (total, p) => total + p.montoGastado,
    );
    final porcentaje = limite <= 0 ? 0.0 : (gastado / limite) * 100;
    return _BudgetSnapshot(
      limite: limite,
      gastado: gastado,
      disponible: math.max(limite - gastado, 0.0),
      porcentaje: porcentaje,
      label: '${presupuestos.length} presupuestos por categoria',
      hasBudget: limite > 0,
    );
  }
}

List<Presupuesto> _presupuestosFromState(PresupuestoState state) {
  if (state is PresupuestoLoaded) return state.presupuestos;
  if (state is PresupuestoError) return state.previous;
  return const [];
}

List<Transaccion> _transaccionesFromState(TransaccionState state) {
  if (state is TransaccionLoaded) return state.items.take(5).toList();
  if (state is TransaccionOperationSuccess) return state.items.take(5).toList();
  if (state is TransaccionError) return state.previousItems.take(5).toList();
  return const [];
}

String _money(double value) => 'S/ ${value.toStringAsFixed(2)}';

String _tipoLabel(String tipo) {
  switch (tipo) {
    case 'ingreso':
      return 'Ingreso';
    case 'gasto':
      return 'Gasto';
    case 'transferencia':
      return 'Transferencia';
    default:
      return tipo;
  }
}

String _date(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
