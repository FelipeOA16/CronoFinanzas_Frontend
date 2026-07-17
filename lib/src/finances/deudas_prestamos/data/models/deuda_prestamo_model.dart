import '../../domain/entities/deuda_prestamo.dart';

class DeudaPrestamoModel extends DeudaPrestamo {
  const DeudaPrestamoModel({
    required super.id,
    required super.usuarioId,
    required super.tipo,
    required super.nombre,
    required super.contraparte,
    super.descripcion,
    required super.montoOriginal,
    required super.saldoPendiente,
    required super.moneda,
    required super.fechaInicio,
    super.fechaProxima,
    super.montoProximo,
    required super.prioridad,
    required super.estado,
    super.cuentaId,
    super.categoriaId,
    super.color,
    super.icono,
    super.notas,
    super.createdAt,
    super.updatedAt,
    super.totalPagado,
  });

  factory DeudaPrestamoModel.fromJson(Map<String, dynamic> json) {
    return DeudaPrestamoModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      tipo: json['tipo'] as String,
      nombre: json['nombre'] as String,
      contraparte: json['contraparte'] as String,
      descripcion: json['descripcion'] as String?,
      montoOriginal: _toDouble(json['monto_original']),
      saldoPendiente: _toDouble(json['saldo_pendiente']),
      moneda: json['moneda'] as String? ?? 'PEN',
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaProxima: json['fecha_proxima'] != null
          ? DateTime.parse(json['fecha_proxima'] as String)
          : null,
      montoProximo: json['monto_proximo'] != null
          ? _toDouble(json['monto_proximo'])
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
      totalPagado: _toDouble(json['total_pagado']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
