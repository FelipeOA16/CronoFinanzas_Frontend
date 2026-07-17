import '../../domain/entities/aporte_meta.dart';

class AporteMetaModel extends AporteMeta {
  const AporteMetaModel({
    required super.id,
    required super.metaId,
    required super.usuarioId,
    required super.transaccionId,
    required super.cuentaId,
    required super.monto,
    required super.moneda,
    required super.fechaAporte,
    super.notas,
    super.createdAt,
  });

  factory AporteMetaModel.fromJson(Map<String, dynamic> json) {
    return AporteMetaModel(
      id: json['id'] as int,
      metaId: json['meta_id'] as int,
      usuarioId: json['usuario_id'] as int,
      transaccionId: json['transaccion_id'] as int,
      cuentaId: json['cuenta_id'] as int,
      monto: _toDouble(json['monto']),
      moneda: json['moneda'] as String? ?? 'PEN',
      fechaAporte: DateTime.parse(json['fecha_aporte'] as String),
      notas: json['notas'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
