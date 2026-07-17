import '../../domain/entities/meta_financiera.dart';

class MetaFinancieraModel extends MetaFinanciera {
  const MetaFinancieraModel({
    required super.id,
    required super.usuarioId,
    required super.nombre,
    super.descripcion,
    required super.montoObjetivo,
    required super.montoActual,
    required super.moneda,
    required super.fechaInicio,
    super.fechaObjetivo,
    required super.prioridad,
    required super.estado,
    super.cuentaId,
    super.categoriaId,
    super.color,
    super.icono,
    super.notas,
    super.createdAt,
    super.updatedAt,
    super.porcentaje,
    super.faltante,
  });

  factory MetaFinancieraModel.fromJson(Map<String, dynamic> json) {
    return MetaFinancieraModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      montoObjetivo: _toDouble(json['monto_objetivo']),
      montoActual: _toDouble(json['monto_actual']),
      moneda: json['moneda'] as String? ?? 'PEN',
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaObjetivo: json['fecha_objetivo'] != null
          ? DateTime.parse(json['fecha_objetivo'] as String)
          : null,
      prioridad: json['prioridad'] as String? ?? 'media',
      estado: json['estado'] as String? ?? 'activa',
      cuentaId: json['cuenta_id'] as int?,
      categoriaId: json['categoria_id'] as int?,
      color: json['color'] as String?,
      icono: json['icono'] as String?,
      notas: json['notas'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      porcentaje: _toDouble(json['porcentaje']),
      faltante: _toDouble(json['faltante']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
