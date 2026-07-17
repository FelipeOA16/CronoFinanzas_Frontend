import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/di/providers.dart';
import '../../../data/datasources/notificacion_remote_data_src.dart';
import '../../../data/repos/notificacion_repo_impl.dart';
import '../../../domain/repos/notificacion_repo.dart';
import 'notificacion_state.dart';

// ─── DI providers ────────────────────────────────────────────────────────────

final notificacionRemoteDataSourceProvider =
    Provider<NotificacionRemoteDataSource>((ref) {
      return NotificacionRemoteDataSource(
        ref.watch(apiClientProvider),
        ref.watch(dioProvider),
      );
    });

final notificacionRepositoryProvider = Provider<NotificacionRepository>((ref) {
  return NotificacionRepositoryImpl(
    ref.watch(notificacionRemoteDataSourceProvider),
  );
});

final notificacionControllerProvider =
    StateNotifierProvider<NotificacionController, NotificacionState>((ref) {
      return NotificacionController(ref.watch(notificacionRepositoryProvider));
    });

/// Derived provider: number of active alerts (for badge).
final notificacionCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificacionControllerProvider);
  if (state is NotificacionLoaded) return state.alertas.length;
  return 0;
});

// ─── Controller ──────────────────────────────────────────────────────────────

class NotificacionController extends StateNotifier<NotificacionState> {
  final NotificacionRepository _repo;

  NotificacionController(this._repo) : super(const NotificacionInitial());

  Future<void> loadAlertas() async {
    state = const NotificacionLoading();
    final result = await _repo.getAlertas();
    if (result.isFail) {
      state = NotificacionError(result.failure.message);
      return;
    }
    state = NotificacionLoaded(result.data);
  }
}
