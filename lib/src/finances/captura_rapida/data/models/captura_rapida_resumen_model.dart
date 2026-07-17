import '../../domain/entities/captura_rapida_resumen.dart';
import 'captura_rapida_model.dart';
import 'captura_rapida_parsers.dart';

class CapturaRapidaResumenModel extends CapturaRapidaResumen {
  const CapturaRapidaResumenModel({
    required super.pendientes,
    required super.totalPendiente,
    super.ultimaCaptura,
  });

  factory CapturaRapidaResumenModel.fromJson(Map<String, dynamic> json) {
    final ultima = json['ultima_captura'];
    return CapturaRapidaResumenModel(
      pendientes: capturaInt(json['pendientes']),
      totalPendiente: capturaDouble(json['total_pendiente']),
      ultimaCaptura: ultima is Map<String, dynamic>
          ? CapturaRapidaModel.fromJson(ultima)
          : null,
    );
  }
}
