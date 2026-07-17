import '../../../domain/entities/reporte.dart';

abstract class ReporteState {
  const ReporteState();
}

class ReporteInitial extends ReporteState {
  const ReporteInitial();
}

class ReporteLoading extends ReporteState {
  const ReporteLoading();
}

class ReporteLoaded extends ReporteState {
  final ReporteData data;
  final int mes;
  final int anio;

  const ReporteLoaded(this.data, {required this.mes, required this.anio});
}

class ReporteError extends ReporteState {
  final String message;

  const ReporteError(this.message);
}
