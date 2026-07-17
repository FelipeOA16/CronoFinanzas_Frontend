import '../../domain/entities/captura_rapida.dart';
import 'captura_rapida_parsers.dart';

class CapturaRapidaModel extends CapturaRapida {
  const CapturaRapidaModel({
    required super.id,
    required super.usuarioId,
    required super.tipo,
    required super.monto,
    required super.moneda,
    super.cuentaId,
    super.cuentaDestinoId,
    super.descripcion,
    super.notaRapida,
    required super.estado,
    super.transaccionId,
    required super.createdAt,
    super.updatedAt,
  });

  factory CapturaRapidaModel.fromJson(Map<String, dynamic> json) {
    return CapturaRapidaModel(
      id: capturaInt(json['id']),
      usuarioId: capturaInt(json['usuario_id']),
      tipo: json['tipo'] as String,
      monto: capturaDouble(json['monto']),
      moneda: json['moneda'] as String? ?? 'PEN',
      cuentaId: capturaNullableInt(json['cuenta_id']),
      cuentaDestinoId: capturaNullableInt(json['cuenta_destino_id']),
      descripcion: json['descripcion'] as String?,
      notaRapida: json['nota_rapida'] as String?,
      estado: json['estado'] as String,
      transaccionId: capturaNullableInt(json['transaccion_id']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }
}
