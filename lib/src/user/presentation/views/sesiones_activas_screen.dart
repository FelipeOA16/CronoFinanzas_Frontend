import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/sesion_activa.dart';
import '../../../auth/presentation/widgets/login_form.dart'
    show authRepositoryProvider, authControllerProvider;
import '../../../auth/presentation/app/riverpod/auth_state.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _sessionsProvider = FutureProvider.autoDispose
    .family<List<SesionActiva>, int>((ref, userId) async {
      final repo = ref.watch(authRepositoryProvider);
      final result = await repo.listSessions(userId);
      if (result.isOk) return result.data;
      throw Exception(result.failure.message);
    });

// ── Screen ────────────────────────────────────────────────────────────────────

class SesionesActivasScreen extends ConsumerWidget {
  const SesionesActivasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final userId = authState.user.idUsuario;
    final sessionsAsync = ref.watch(_sessionsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones activas'),
        centerTitle: true,
        actions: [
          sessionsAsync.maybeWhen(
            data: (sessions) => sessions.length > 1
                ? IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    tooltip: 'Cerrar todas las demás sesiones',
                    onPressed: () => _confirmRevokeAll(context, ref, userId),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.gasto),
              const SizedBox(height: 12),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              CFOutlinedButton(
                label: 'Reintentar',
                onPressed: () => ref.invalidate(_sessionsProvider(userId)),
              ),
            ],
          ),
        ),
        data: (sessions) => sessions.isEmpty
            ? const CFEmptyState(
                title: 'Sin sesiones activas',
                message: 'No hay otros dispositivos conectados a tu cuenta.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _SesionCard(
                  sesion: sessions[i],
                  onRevoke: () =>
                      _revokeOne(context, ref, userId, sessions[i].uuid),
                ),
              ),
      ),
    );
  }

  Future<void> _revokeOne(
    BuildContext context,
    WidgetRef ref,
    int userId,
    String uuid,
  ) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.revokeSession(userId, uuid);
    if (!context.mounted) return;
    if (result.isOk) {
      ref.invalidate(_sessionsProvider(userId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _confirmRevokeAll(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar todas las sesiones'),
        content: const Text(
          '¿Deseas cerrar todas las sesiones activas?\nSe cerrarán todas las sesiones incluyendo la actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          CFButton(
            label: 'Cerrar todas',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.revokeAllSessions(userId);
    if (!context.mounted) return;
    if (result.isOk) {
      // Navigate back to login since current session was also revoked
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

// ── Session card widget ───────────────────────────────────────────────────────

class _SesionCard extends StatelessWidget {
  const _SesionCard({required this.sesion, required this.onRevoke});
  final SesionActiva sesion;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final platform = _platformLabel(sesion.sistemaOperativo, sesion.navegador);
    final lastActivity = _formatDate(sesion.ultimaActividad);

    return CFCard(
      elevated: true,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                _platformIcon(sesion.sistemaOperativo),
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    platform,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sesion.ip != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'IP: ${sesion.ip}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'Última actividad: $lastActivity',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Cerrar sesión',
              color: AppColors.gasto,
              onPressed: onRevoke,
            ),
          ],
        ),
      ),
    );
  }

  String _platformLabel(String? os, String? browser) {
    final parts = [
      if (browser != null && browser.isNotEmpty) browser,
      if (os != null && os.isNotEmpty) os,
    ];
    return parts.isEmpty ? 'Dispositivo desconocido' : parts.join(' • ');
  }

  IconData _platformIcon(String? os) {
    if (os == null) return Icons.devices_outlined;
    final lower = os.toLowerCase();
    if (lower.contains('android')) return Icons.phone_android_outlined;
    if (lower.contains('ios') || lower.contains('iphone')) {
      return Icons.phone_iphone_outlined;
    }
    if (lower.contains('windows')) return Icons.laptop_windows_outlined;
    if (lower.contains('mac')) return Icons.laptop_mac_outlined;
    return Icons.devices_outlined;
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
