import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/notificacion.dart';
import '../app/riverpod/notificacion_controller.dart';
import '../app/riverpod/notificacion_state.dart';

class NotificacionesScreen extends ConsumerStatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificacionControllerProvider.notifier).loadAlertas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificacionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Alertas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () =>
                ref.read(notificacionControllerProvider.notifier).loadAlertas(),
          ),
        ],
      ),
      body: switch (state) {
        NotificacionLoading() => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        NotificacionError(message: final msg) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.gasto),
              const SizedBox(height: 12),
              Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              CFButton(
                label: 'Reintentar',
                onPressed: () => ref
                    .read(notificacionControllerProvider.notifier)
                    .loadAlertas(),
              ),
            ],
          ),
        ),
        NotificacionLoaded(alertas: final alertas) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(notificacionControllerProvider.notifier).loadAlertas(),
          child: alertas.isEmpty
              ? const _YachayEmptyAlerts()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: alertas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AlertCard(notificacion: alertas[i]),
                ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _YachayEmptyAlerts extends StatelessWidget {
  const _YachayEmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: const CFYachayCard(
                  title: 'Yachay',
                  message: 'No existen alertas activas.',
                  mood: YachayAvatarMood.success,
                  compact: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.ingreso,
                ),
                SizedBox(height: 16),
                Text(
                  'Sin alertas activas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Todos tus presupuestos están\ndentro del límite este mes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Alert card ────────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final Notificacion notificacion;
  const _AlertCard({required this.notificacion});

  @override
  Widget build(BuildContext context) {
    final isExcedido = notificacion.isExcedido;
    final color = isExcedido ? AppColors.gasto : AppColors.gold;
    final bgColor = color.withValues(alpha: 0.08);
    final icon = isExcedido
        ? Icons.warning_rounded
        : Icons.notifications_active_outlined;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificacion.titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${notificacion.porcentaje.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notificacion.mensaje,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (notificacion.porcentaje / 100).clamp(0.0, 1.0),
                      backgroundColor: AppColors.border,
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
