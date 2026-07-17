import 'captura_rapida.dart';

class CapturaRapidaResumen {
  final int pendientes;
  final double totalPendiente;
  final CapturaRapida? ultimaCaptura;

  const CapturaRapidaResumen({
    required this.pendientes,
    required this.totalPendiente,
    this.ultimaCaptura,
  });
}
