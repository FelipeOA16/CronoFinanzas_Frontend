import '../../domain/entities/pago_deuda_prestamo.dart';

class PagoDeudaPrestamoModel extends PagoDeudaPrestamo {
  const PagoDeudaPrestamoModel({
    required super.id,
    required super.deudaPrestamoId,
    required super.usuarioId,
    required super.transaccionId,
    required super.cuentaId,
    required super.monto,
    required super.moneda,
    required super.fechaPago,
    super.notas,
    super.createdAt,
  });

  factory PagoDeudaPrestamoModel.fromJson(Map<String, dynamic> json) {
    return PagoDeudaPrestamoModel(
      id: json['id'] as int,
      deudaPrestamoId: json['deuda_prestamo_id'] as int,
      usuarioId: json['usuario_id'] as int,
      transaccionId: json['transaccion_id'] as int,
      cuentaId: json['cuenta_id'] as int,
      monto: _toDouble(json['monto']),
      moneda: json['moneda'] as String? ?? 'PEN',
      fechaPago: DateTime.parse(json['fecha_pago'] as String),
      notas: json['notas'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
