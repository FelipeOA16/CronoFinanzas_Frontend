import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/di/providers.dart';
import '../../../data/datasources/reporte_remote_data_src.dart';
import '../../../data/repos/reporte_repo_impl.dart';
import '../../../domain/repos/reporte_repo.dart';
import 'reporte_state.dart';

// ─── DI providers ────────────────────────────────────────────────────────────

final reporteRemoteDataSourceProvider = Provider<ReporteRemoteDataSource>((
  ref,
) {
  return ReporteRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(dioProvider),
  );
});

final reporteRepositoryProvider = Provider<ReporteRepository>((ref) {
  return ReporteRepositoryImpl(ref.watch(reporteRemoteDataSourceProvider));
});

final reporteControllerProvider =
    StateNotifierProvider<ReporteController, ReporteState>((ref) {
      return ReporteController(ref.watch(reporteRepositoryProvider));
    });

// ─── Controller ──────────────────────────────────────────────────────────────

class ReporteController extends StateNotifier<ReporteState> {
  final ReporteRepository _repo;

  ReporteController(this._repo) : super(const ReporteInitial());

  Future<void> loadReporte({int? mes, int? anio, int mesesFlujo = 6}) async {
    state = const ReporteLoading();
    final result = await _repo.getReporte(
      mes: mes,
      anio: anio,
      mesesFlujo: mesesFlujo,
    );
    if (result.isFail) {
      state = ReporteError(result.failure.message);
      return;
    }
    final now = DateTime.now();
    state = ReporteLoaded(
      result.data,
      mes: mes ?? now.month,
      anio: anio ?? now.year,
    );
  }
}
