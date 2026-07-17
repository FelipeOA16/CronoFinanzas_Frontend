import '../../../domain/entities/captura_rapida.dart';

enum CapturaItemStatus { idle, saving, completing, deleting, error }

class CapturaRapidaState {
  final List<CapturaRapida> pendientes;
  final List<CapturaRapida> completadas;
  final bool pendientesLoaded;
  final bool completadasLoaded;
  final bool loadingPendientes;
  final bool loadingCompletadas;
  final Map<int, CapturaItemStatus> itemStatus;
  final String? errorMessage;

  const CapturaRapidaState({
    this.pendientes = const [],
    this.completadas = const [],
    this.pendientesLoaded = false,
    this.completadasLoaded = false,
    this.loadingPendientes = false,
    this.loadingCompletadas = false,
    this.itemStatus = const {},
    this.errorMessage,
  });

  List<CapturaRapida> itemsFor(String estado) =>
      estado == 'completada' ? completadas : pendientes;

  bool isLoading(String estado) =>
      estado == 'completada' ? loadingCompletadas : loadingPendientes;

  bool isLoaded(String estado) =>
      estado == 'completada' ? completadasLoaded : pendientesLoaded;

  CapturaItemStatus statusFor(int id) =>
      itemStatus[id] ?? CapturaItemStatus.idle;

  CapturaRapidaState copyWith({
    List<CapturaRapida>? pendientes,
    List<CapturaRapida>? completadas,
    bool? pendientesLoaded,
    bool? completadasLoaded,
    bool? loadingPendientes,
    bool? loadingCompletadas,
    Map<int, CapturaItemStatus>? itemStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CapturaRapidaState(
      pendientes: pendientes ?? this.pendientes,
      completadas: completadas ?? this.completadas,
      pendientesLoaded: pendientesLoaded ?? this.pendientesLoaded,
      completadasLoaded: completadasLoaded ?? this.completadasLoaded,
      loadingPendientes: loadingPendientes ?? this.loadingPendientes,
      loadingCompletadas: loadingCompletadas ?? this.loadingCompletadas,
      itemStatus: itemStatus ?? this.itemStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
