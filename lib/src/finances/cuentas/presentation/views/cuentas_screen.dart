import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/brand/brand_shadows.dart';
import '../../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../../core/design_system/components/components.dart';
import '../app/riverpod/cuenta_controller.dart';
import '../app/riverpod/cuenta_state.dart';
import '../widgets/cuenta_card.dart';
import 'cuenta_form_screen.dart';

class CuentasScreen extends ConsumerStatefulWidget {
  const CuentasScreen({super.key});

  @override
  ConsumerState<CuentasScreen> createState() => _CuentasScreenState();
}

class _CuentasScreenState extends ConsumerState<CuentasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(cuentaControllerProvider.notifier).loadCuentas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cuentaControllerProvider);
    final showExtendedFab = MediaQuery.sizeOf(context).width >= 840;
    final colors = context.brandColors;

    // Show success/error snackbars
    ref.listen<CuentaState>(cuentaControllerProvider, (_, next) {
      if (next is CuentaOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: colors.verdeExito,
          ),
        );
      } else if (next is CuentaError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: colors.rojoError,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuentas'),
        centerTitle: true,
        actions: [
          if (!showExtendedFab)
            IconButton(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              tooltip: 'Agregar',
            ),
        ],
      ),
      body: _buildBody(context, state),
      floatingActionButton: CFExtendedFab(
        visible: showExtendedFab,
        onPressed: () => _openForm(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CuentaState state) {
    final colors = context.brandColors;
    final spacing = context.brandSpacing;
    final radius = context.brandRadius;

    if (state is CuentaLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cuentas = switch (state) {
      CuentaLoaded(cuentas: final c) => c,
      CuentaOperationSuccess(cuentas: final c) => c,
      CuentaError(previousCuentas: final c) => c,
      _ => <dynamic>[],
    };

    if (cuentas.isEmpty && state is! CuentaError) {
      return _emptyState(context);
    }

    // Compute total patrimony
    final total = cuentas
        .where((c) => c.incluirEnTotal)
        .fold<double>(0.0, (sum, c) => sum + c.saldoActual);

    return Column(
      children: [
        // Patrimony header
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(spacing.space16),
          padding: EdgeInsets.symmetric(
            vertical: spacing.space20,
            horizontal: spacing.space24,
          ),
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
                'Patrimonio total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PEN ${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cuentas.length} cuenta${cuentas.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: cuentas.length,
            itemBuilder: (context, i) {
              final cuenta = cuentas[i];
              return CuentaCard(
                cuenta: cuenta,
                onTap: () => _openForm(context, cuenta: cuenta),
                onDelete: () => ref
                    .read(cuentaControllerProvider.notifier)
                    .deleteCuenta(cuenta.id),
                onVerMovimientos: () => Navigator.of(context).pushNamed(
                  '/transacciones',
                  arguments: {
                    'cuentaId': cuenta.id,
                    'cuentaNombre': cuenta.nombre,
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final colors = context.brandColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CFEmptyIllustration(
            type: CFEmptyIllustrationType.accounts,
            size: 112,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin cuentas aún',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colors.grisNeutro),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una cuenta para organizar tu dinero',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.grisNeutro),
          ),
          const SizedBox(height: 20),
          CFButton(
            label: 'Crear cuenta',
            onPressed: () => _openForm(context),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, {dynamic cuenta}) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CuentaFormScreen(cuenta: cuenta)));
  }
}
