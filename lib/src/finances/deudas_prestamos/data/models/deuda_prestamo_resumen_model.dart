import '../../domain/entities/deuda_prestamo_resumen.dart';

class DeudaPrestamoResumenItemModel extends DeudaPrestamoResumenItem {
  const DeudaPrestamoResumenItemModel({
    required super.id,
    required super.tipo,
    required super.nombre,
    required super.contraparte,
    required super.saldoPendiente,
    super.montoProximo,
    super.fechaProxima,
    required super.prioridad,
  });

  factory DeudaPrestamoResumenItemModel.fromJson(Map<String, dynamic> json) {
    return DeudaPrestamoResumenItemModel(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      nombre: json['nombre'] as String,
      contraparte: json['contraparte'] as String,
      saldoPendiente: _toDouble(json['saldo_pendiente']),
      montoProximo: json['monto_proximo'] != null
          ? _toDouble(json['monto_proximo'])
          : null,
      fechaProxima: json['fecha_proxima'] != null
          ? DateTime.parse(json['fecha_proxima'] as String)
          : null,
      prioridad: json['prioridad'] as String? ?? 'media',
    );
  }
}

class DeudaPrestamoResumenModel extends DeudaPrestamoResumen {
  const DeudaPrestamoResumenModel({
    required super.totalDebo,
    required super.totalMeDeben,
    required super.balanceNeto,
    required super.cantidadActivas,
    required super.cantidadCriticas,
    required super.proximas,
  });

  factory DeudaPrestamoResumenModel.fromJson(Map<String, dynamic> json) {
    final proximas = (json['proximas'] as List<dynamic>? ?? [])
        .map(
          (e) =>
              DeudaPrestamoResumenItemModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
    return DeudaPrestamoResumenModel(
      totalDebo: _toDouble(json['total_debo']),
      totalMeDeben: _toDouble(json['total_me_deben']),
      balanceNeto: _toDouble(json['balance_neto']),
      cantidadActivas: json['cantidad_activas'] as int? ?? 0,
      cantidadCriticas: json['cantidad_criticas'] as int? ?? 0,
      proximas: proximas,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
