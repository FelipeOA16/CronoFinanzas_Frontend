import '../../domain/entities/meta_financiera_resumen.dart';

class MetaFinancieraResumenItemModel extends MetaFinancieraResumenItem {
  const MetaFinancieraResumenItemModel({
    required super.id,
    required super.nombre,
    required super.montoObjetivo,
    required super.montoActual,
    required super.porcentaje,
    required super.prioridad,
    super.fechaObjetivo,
  });

  factory MetaFinancieraResumenItemModel.fromJson(Map<String, dynamic> json) {
    return MetaFinancieraResumenItemModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      montoObjetivo: _toDouble(json['monto_objetivo']),
      montoActual: _toDouble(json['monto_actual']),
      porcentaje: _toDouble(json['porcentaje']),
      prioridad: json['prioridad'] as String? ?? 'media',
      fechaObjetivo: json['fecha_objetivo'] != null
          ? DateTime.parse(json['fecha_objetivo'] as String)
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

class MetaFinancieraResumenModel extends MetaFinancieraResumen {
  const MetaFinancieraResumenModel({
    required super.totalObjetivo,
    required super.totalActual,
    required super.porcentajeGlobal,
    required super.cantidadActivas,
    required super.cantidadCompletadas,
    required super.topMetas,
  });

  factory MetaFinancieraResumenModel.fromJson(Map<String, dynamic> json) {
    return MetaFinancieraResumenModel(
      totalObjetivo: _toDouble(json['total_objetivo']),
      totalActual: _toDouble(json['total_actual']),
      porcentajeGlobal: _toDouble(json['porcentaje_global']),
      cantidadActivas: json['cantidad_activas'] as int? ?? 0,
      cantidadCompletadas: json['cantidad_completadas'] as int? ?? 0,
      topMetas: (json['top_metas'] as List<dynamic>? ?? [])
          .map(
            (e) => MetaFinancieraResumenItemModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
