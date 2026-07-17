import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/config/env.dart';
import '../../../../../../core/design_system/brand/brand_icons.dart';
import '../../../../../../core/design_system/components/components.dart';
import '../../../../../../core/design_system/spacing/cf_spacing.dart';
import '../../../../../../core/design_system/tokens/cf_colors.dart';
import '../../../../app/di/providers.dart';
import '../../../cuentas/domain/entities/cuenta.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../platform/quick_capture_platform_service.dart';

class CapturaRapidaSettingsScreen extends ConsumerStatefulWidget {
  const CapturaRapidaSettingsScreen({super.key});

  @override
  ConsumerState<CapturaRapidaSettingsScreen> createState() =>
      _CapturaRapidaSettingsScreenState();
}

class _CapturaRapidaSettingsScreenState
    extends ConsumerState<CapturaRapidaSettingsScreen>
    with WidgetsBindingObserver {
  final _platform = QuickCapturePlatformService();
  bool _loadingStatus = true;
  bool _overlayGranted = false;
  bool _notificationGranted = false;
  bool _batteryUnrestricted = false;
  bool _restoreOnBoot = false;
  bool _changingBubble = false;
  QuickCaptureBubbleStatus _bubbleStatus = QuickCaptureBubbleStatus.unsupported;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    if (mounted) setState(() => _loadingStatus = true);
    final granted = await _platform.isOverlayPermissionGranted();
    final status = await _platform.getBubbleStatus();
    final notificationGranted = await _platform
        .isNotificationPermissionGranted();
    final batteryUnrestricted = await _platform
        .isIgnoringBatteryOptimizations();
    final restoreOnBoot = await _platform.getRestoreOnBoot();
    if (!mounted) return;
    setState(() {
      _overlayGranted = granted;
      _bubbleStatus = status;
      _notificationGranted = notificationGranted;
      _batteryUnrestricted = batteryUnrestricted;
      _restoreOnBoot = restoreOnBoot;
      _loadingStatus = false;
    });
  }

  Future<void> _openPermissionSettings() async {
    if (!_platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta configuracion estara disponible en Android.'),
        ),
      );
      return;
    }
    await _platform.openOverlayPermissionSettings();
  }

  Future<void> _toggleBubble(bool enabled) async {
    if (_changingBubble) return;
    if (enabled && !_overlayGranted) {
      await _openPermissionSettings();
      return;
    }
    setState(() => _changingBubble = true);
    bool changed;
    if (enabled) {
      if (!_notificationGranted) {
        final allowed = await _platform.requestNotificationPermission();
        if (!allowed) {
          if (!mounted) return;
          setState(() => _changingBubble = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Android bloqueo la notificacion del servicio.'),
            ),
          );
          await _refreshStatus();
          return;
        }
      }
      if (ref.read(cuentaControllerProvider) is CuentaInitial) {
        await ref.read(cuentaControllerProvider.notifier).loadCuentas();
      }
      final token = await ref.read(tokenStorageProvider).getAccessToken();
      changed = await _platform.startBubble(
        accessToken: token,
        apiBaseUrl: Env.baseUrl,
        accounts: _activeAccounts(),
      );
    } else {
      changed = await _platform.stopBubble();
    }
    if (!mounted) return;
    setState(() => _changingBubble = false);
    await _refreshStatus();
    if (!mounted) return;
    if (!changed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'No se pudo activar la burbuja. Revisa el permiso.'
                : 'No se pudo desactivar la burbuja.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleRestoreOnBoot(bool enabled) async {
    final changed = await _platform.setRestoreOnBoot(enabled);
    if (!mounted) return;
    if (changed) {
      setState(() => _restoreOnBoot = enabled);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la preferencia.')),
      );
    }
  }

  Future<void> _restartBubble() async {
    if (_changingBubble || _bubbleStatus != QuickCaptureBubbleStatus.active) {
      return;
    }
    setState(() => _changingBubble = true);
    await _platform.stopBubble();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (ref.read(cuentaControllerProvider) is CuentaInitial) {
      await ref.read(cuentaControllerProvider.notifier).loadCuentas();
    }
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    await _platform.startBubble(
      accessToken: token,
      apiBaseUrl: Env.baseUrl,
      accounts: _activeAccounts(),
    );
    if (!mounted) return;
    setState(() => _changingBubble = false);
    await _refreshStatus();
  }

  Future<void> _openBatterySettings() async {
    await _platform.openBatteryOptimizationSettings();
  }

  List<Map<String, Object>> _activeAccounts() {
    final state = ref.read(cuentaControllerProvider);
    final accounts = switch (state) {
      CuentaLoaded(:final cuentas) => cuentas,
      CuentaOperationSuccess(:final cuentas) => cuentas,
      CuentaError(:final previousCuentas) => previousCuentas,
      _ => <Cuenta>[],
    };
    return [
      for (final account in accounts.where((item) => item.esActiva))
        <String, Object>{
          'id': account.id,
          'name': account.nombre,
          'currency': account.moneda,
        },
    ];
  }

  bool get _bubbleActive => _bubbleStatus == QuickCaptureBubbleStatus.active;

  String get _bubbleStatusLabel {
    if (_loadingStatus) return 'Consultando';
    if (_changingBubble) return 'Actualizando';
    return switch (_bubbleStatus) {
      QuickCaptureBubbleStatus.unsupported => 'No soportado',
      QuickCaptureBubbleStatus.permissionRequired => 'Requiere permiso',
      QuickCaptureBubbleStatus.inactive => 'Inactiva',
      QuickCaptureBubbleStatus.starting => 'Recuperando',
      QuickCaptureBubbleStatus.active => 'Activa',
      QuickCaptureBubbleStatus.stopping => 'Deteniendo',
      QuickCaptureBubbleStatus.error => 'Error',
    };
  }

  Color get _bubbleStatusColor {
    return switch (_bubbleStatus) {
      QuickCaptureBubbleStatus.active => CFColors.success,
      QuickCaptureBubbleStatus.permissionRequired ||
      QuickCaptureBubbleStatus.starting => CFColors.warning,
      QuickCaptureBubbleStatus.error => CFColors.danger,
      _ => CFColors.azulAndino,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CFColors.marfil,
      appBar: AppBar(title: const Text('Captura rapida')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                CFSpacing.md,
                CFSpacing.md,
                CFSpacing.md,
                96,
              ),
              children: [
                Text(
                  'Configuracion de captura rapida',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: CFSpacing.xs),
                Text(
                  'Elige como quieres anotar movimientos sin perder tiempo.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: CFSpacing.md),
                const CFYachayCard(
                  title: 'Yachay',
                  message:
                      'La burbuja no lee otras aplicaciones. Solo registra lo que escribes y lo guarda como captura pendiente.',
                  mood: YachayAvatarMood.thinking,
                  compact: true,
                ),
                const SizedBox(height: CFSpacing.md),
                const _SettingOptionCard(
                  icon: BrandIcons.add,
                  title: 'Mostrar en boton Nueva',
                  description: 'Disponible desde el boton central de la app.',
                  badge: 'Activo',
                  badgeColor: CFColors.success,
                  switchValue: true,
                ),
                const SizedBox(height: CFSpacing.sm),
                _SettingOptionCard(
                  icon: BrandIcons.quickCapture,
                  title: 'Burbuja flotante',
                  description:
                      'Guarda capturas pendientes desde un overlay externo mientras tu sesion esta disponible.',
                  badge: _bubbleStatusLabel,
                  badgeColor: _bubbleStatusColor,
                  switchValue: _bubbleActive,
                  onSwitchChanged: _loadingStatus || _changingBubble
                      ? null
                      : _toggleBubble,
                  trailing: !_overlayGranted
                      ? CFOutlinedButton(
                          label: 'Conceder permiso',
                          onPressed: _loadingStatus
                              ? null
                              : _openPermissionSettings,
                        )
                      : _bubbleActive
                      ? CFOutlinedButton(
                          label: 'Reiniciar burbuja',
                          onPressed: _changingBubble ? null : _restartBubble,
                        )
                      : null,
                ),
                const SizedBox(height: CFSpacing.sm),
                _SettingOptionCard(
                  icon: Icons.restart_alt_outlined,
                  title: 'Restaurar tras reinicio',
                  description:
                      'CronoFinanzas intentara recuperar la burbuja despues de reiniciar el dispositivo.',
                  badge: _restoreOnBoot ? 'Activa' : 'OFF por defecto',
                  badgeColor: _restoreOnBoot
                      ? CFColors.success
                      : CFColors.azulAndino,
                  switchValue: _restoreOnBoot,
                  onSwitchChanged: _loadingStatus ? null : _toggleRestoreOnBoot,
                ),
                const SizedBox(height: CFSpacing.sm),
                _StatusCard(
                  notificationGranted: _notificationGranted,
                  overlayGranted: _overlayGranted,
                  batteryUnrestricted: _batteryUnrestricted,
                  onRefresh: _loadingStatus ? null : _refreshStatus,
                  onBatterySettings: _openBatterySettings,
                ),
                const SizedBox(height: CFSpacing.md),
                CFCard(
                  color: CFColors.info.withValues(alpha: 0.08),
                  borderColor: CFColors.info.withValues(alpha: 0.24),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: CFColors.info),
                      SizedBox(width: CFSpacing.sm),
                      Expanded(
                        child: Text(
                          'Privacidad: la burbuja no lee el contenido de otras aplicaciones. Solo registra los datos que escribes.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool overlayGranted;
  final bool notificationGranted;
  final bool batteryUnrestricted;
  final VoidCallback? onRefresh;
  final VoidCallback onBatterySettings;

  const _StatusCard({
    required this.overlayGranted,
    required this.notificationGranted,
    required this.batteryUnrestricted,
    required this.onRefresh,
    required this.onBatterySettings,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                color: CFColors.verdeValle,
              ),
              const SizedBox(width: CFSpacing.sm),
              Expanded(
                child: Text(
                  'Estabilidad de la burbuja',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: CFSpacing.sm),
          _StatusRow(
            label: 'Permiso overlay',
            value: overlayGranted ? 'Permitido' : 'Requiere permiso',
            ok: overlayGranted,
          ),
          _StatusRow(
            label: 'Notificacion del servicio',
            value: notificationGranted ? 'Permitida' : 'Requiere permiso',
            ok: notificationGranted,
          ),
          _StatusRow(
            label: 'Bateria',
            value: batteryUnrestricted ? 'Sin restricciones' : 'Optimizada',
            ok: batteryUnrestricted,
          ),
          const SizedBox(height: CFSpacing.sm),
          Text(
            'Algunos dispositivos pueden detener la burbuja para ahorrar bateria. Puedes revisar la configuracion si notas cierres inesperados.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: CFSpacing.sm),
          Wrap(
            spacing: CFSpacing.sm,
            runSpacing: CFSpacing.sm,
            children: [
              CFOutlinedButton(
                label: 'Comprobar estado',
                icon: Icons.refresh_outlined,
                onPressed: onRefresh,
              ),
              CFOutlinedButton(
                label: 'Revisar configuracion',
                icon: Icons.battery_saver_outlined,
                onPressed: onBatterySettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool ok;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    final color = ok ? CFColors.success : CFColors.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CFSpacing.xxs),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.info_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: CFSpacing.xs),
          Expanded(child: Text(label)),
          const SizedBox(width: CFSpacing.xs),
          CFBadge(label: value, color: color),
        ],
      ),
    );
  }
}

class _SettingOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badge;
  final Color badgeColor;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Widget? trailing;

  const _SettingOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.switchValue,
    this.onSwitchChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CFCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: CFColors.verdeValle),
              const SizedBox(width: CFSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: CFSpacing.xxs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CFSpacing.xs),
              Switch(value: switchValue, onChanged: onSwitchChanged),
            ],
          ),
          const SizedBox(height: CFSpacing.sm),
          Row(
            children: [
              CFBadge(label: badge, color: badgeColor),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}
