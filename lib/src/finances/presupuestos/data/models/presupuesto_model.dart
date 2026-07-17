import '../../domain/entities/presupuesto.dart';

class PresupuestoModel extends Presupuesto {
  const PresupuestoModel({
    required super.id,
    required super.usuarioId,
    super.categoriaId,
    super.categoriaNombre,
    super.categoriaColor,
    required super.mes,
    required super.anio,
    required super.montoLimite,
    required super.montoGastado,
    required super.porcentaje,
    required super.estado,
    required super.moneda,
    super.createdAt,
  });

  factory PresupuestoModel.fromJson(Map<String, dynamic> json) {
    final cat = json['categoria'] as Map<String, dynamic>?;
    return PresupuestoModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      categoriaId: json['categoria_id'] as int?,
      categoriaNombre: cat?['nombre'] as String?,
      categoriaColor: cat?['color'] as String?,
      mes: json['mes'] as int,
      anio: json['anio'] as int,
      montoLimite: _toDouble(json['monto_limite']),
      montoGastado: _toDouble(json['monto_gastado']),
      porcentaje: _toDouble(json['porcentaje']),
      estado: json['estado'] as String? ?? 'ok',
      moneda: json['moneda'] as String? ?? 'PEN',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    if (categoriaId != null) 'categoria_id': categoriaId,
    'mes': mes,
    'anio': anio,
    'monto_limite': montoLimite,
    'moneda': moneda,
  };
}
