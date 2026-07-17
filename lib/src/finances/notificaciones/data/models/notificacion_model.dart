import '../../domain/entities/notificacion.dart';

class NotificacionModel extends Notificacion {
  const NotificacionModel({
    required super.tipo,
    required super.titulo,
    required super.mensaje,
    required super.presupuestoId,
    required super.porcentaje,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      tipo: json['tipo'] as String,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      presupuestoId: json['presupuesto_id'] as int,
      porcentaje: _toDouble(json['porcentaje']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
