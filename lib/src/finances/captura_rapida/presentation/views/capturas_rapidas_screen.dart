import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/design_system/brand/brand_icons.dart';
import '../../../../../../core/design_system/components/components.dart';
import '../../../../../../core/design_system/spacing/cf_spacing.dart';
import '../../../../../../core/design_system/tokens/cf_colors.dart';
import '../../domain/entities/captura_rapida.dart';
import '../app/riverpod/captura_rapida_controller.dart';
import '../app/riverpod/captura_rapida_state.dart';
import '../widgets/captura_rapida_sheet.dart';

class CapturasRapidasScreen extends ConsumerStatefulWidget {
  const CapturasRapidasScreen({super.key});

  @override
  ConsumerState<CapturasRapidasScreen> createState() =>
      _CapturasRapidasScreenState();
}

class _CapturasRapidasScreenState extends ConsumerState<CapturasRapidasScreen> {
  String _estado = 'pendiente';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _load());
  }

  void _load() {
    ref.read(capturaRapidaControllerProvider.notifier).load(estado: _estado);
  }

  Future<void> _newCapture() async {
    final submission = await CapturaRapidaSheet.show(context);
    if (submission == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Captura guardada como pendiente.')),
    );
    final saved = await submission.completion;
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar. Intenta nuevamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(capturaRapidaControllerProvider);
    final items = state.itemsFor(_estado);
    final loading = state.isLoading(_estado);
    final loaded = state.isLoaded(_estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturas rapidas'),
        actions: [
          CFIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Configurar captura rapida',
            onPressed: () =>
                Navigator.of(context).pushNamed('/capturas-rapidas/settings'),
          ),
          const SizedBox(width: CFSpacing.xs),
        ],
      ),
      floatingActionButton: MediaQuery.sizeOf(context).width >= 840
          ? CFExtendedFab(onPressed: _newCapture)
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(capturaRapidaControllerProvider.notifier)
              .load(estado: _estado, force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              CFSpacing.md,
              CFSpacing.sm,
              CFSpacing.md,
              112,
            ),
            children: [
              const CFYachayCard(
                title: 'Yachay te acompana',
                message:
                    'Lo importante era no olvidarlo. Luego puedes completar los detalles.',
                mood: YachayAvatarMood.thinking,
                compact: true,
              ),
              const SizedBox(height: CFSpacing.md),
              ref
                  .watch(capturaRapidaResumenProvider)
                  .when(
                    data: (summary) => CFCard(
                      child: Row(
                        children: [
                          const Icon(
                            BrandIcons.quickCapture,
                            color: CFColors.verdeValle,
                          ),
                          const SizedBox(width: CFSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${summary.pendientes} pendientes',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  'Total anotado: S/ ${summary.totalPendiente.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ),
                          if (MediaQuery.sizeOf(context).width < 840)
                            CFIconButton(
                              icon: BrandIcons.add,
                              tooltip: 'Nueva captura',
                              onPressed: _newCapture,
                            ),
                        ],
                      ),
                    ),
                    loading: () =>
                        const SizedBox(height: 72, child: CFLoadingState()),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
              const SizedBox(height: CFSpacing.md),
              CFFormSegmented<String>(
                segments: const [
                  ButtonSegment(value: 'pendiente', label: Text('Pendientes')),
                  ButtonSegment(
                    value: 'completada',
                    label: Text('Completadas'),
                  ),
                ],
                selected: {_estado},
                onSelectionChanged: (selected) {
                  setState(() => _estado = selected.first);
                  _load();
                },
              ),
              const SizedBox(height: CFSpacing.md),
              if (loading && !loaded)
                const CFLoadingState(message: 'Cargando capturas...')
              else if (state.errorMessage != null && !loaded)
                CFErrorState(message: state.errorMessage!)
              else if (items.isEmpty)
                CFEmptyState(
                  title: _estado == 'pendiente'
                      ? 'No tienes capturas pendientes'
                      : 'Aun no hay capturas completadas',
                  message: _estado == 'pendiente'
                      ? 'Tus anotaciones rapidas apareceran aqui.'
                      : null,
                )
              else
                for (final item in items) ...[
                  _CaptureCard(
                    capture: item,
                    status: state.statusFor(item.id),
                    onComplete:
                        item.estaPendiente &&
                            {
                              CapturaItemStatus.idle,
                              CapturaItemStatus.error,
                            }.contains(state.statusFor(item.id))
                        ? () => Navigator.of(context).pushNamed(
                            '/capturas-rapidas/completar',
                            arguments: item,
                          )
                        : null,
                    onDiscard:
                        item.estaPendiente &&
                            {
                              CapturaItemStatus.idle,
                              CapturaItemStatus.error,
                            }.contains(state.statusFor(item.id))
                        ? () async {
                            final ok = await ref
                                .read(capturaRapidaControllerProvider.notifier)
                                .descartar(item.id);
                            if (!context.mounted || ok) return;
                            final current = ref.read(
                              capturaRapidaControllerProvider,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  current.errorMessage ??
                                      'No se pudo eliminar. Intenta nuevamente.',
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: CFSpacing.sm),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final CapturaRapida capture;
  final CapturaItemStatus status;
  final VoidCallback? onComplete;
  final VoidCallback? onDiscard;

  const _CaptureCard({
    required this.capture,
    required this.status,
    this.onComplete,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final created = capture.createdAt;
    final date =
        '${created.day.toString().padLeft(2, '0')}/'
        '${created.month.toString().padLeft(2, '0')}/${created.year} '
        '${created.hour.toString().padLeft(2, '0')}:'
        '${created.minute.toString().padLeft(2, '0')}';
    return CFCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CFBadge(
                label:
                    capture.tipo[0].toUpperCase() + capture.tipo.substring(1),
              ),
              const Spacer(),
              Text(
                'S/ ${capture.monto.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: CFSpacing.xs),
          Text(capture.notaRapida ?? capture.descripcion ?? 'Sin nota'),
          const SizedBox(height: CFSpacing.xs),
          Text(date, style: Theme.of(context).textTheme.bodySmall),
          if (status == CapturaItemStatus.saving) ...[
            const SizedBox(height: CFSpacing.xs),
            const LinearProgressIndicator(),
            const SizedBox(height: CFSpacing.xs),
            Text(
              'Guardando captura...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (status == CapturaItemStatus.error) ...[
            const SizedBox(height: CFSpacing.xs),
            Text(
              'La ultima operacion no se pudo completar.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: CFColors.danger),
            ),
          ],
          if (capture.estaPendiente && status != CapturaItemStatus.saving) ...[
            const SizedBox(height: CFSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: CFButton(
                    label: status == CapturaItemStatus.completing
                        ? 'Completando movimiento...'
                        : 'Completar',
                    loading: status == CapturaItemStatus.completing,
                    onPressed: onComplete,
                  ),
                ),
                const SizedBox(width: CFSpacing.xs),
                if (status == CapturaItemStatus.deleting)
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  CFIconButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Descartar',
                    color: CFColors.danger,
                    onPressed: onDiscard,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
