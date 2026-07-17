import '../../domain/entities/cuenta.dart';

class CuentaModel extends Cuenta {
  const CuentaModel({
    required super.id,
    required super.usuarioId,
    required super.nombre,
    required super.tipo,
    required super.moneda,
    required super.saldoInicial,
    required super.saldoActual,
    super.color,
    super.icono,
    super.institucion,
    required super.esActiva,
    required super.incluirEnTotal,
    super.notas,
    super.createdAt,
    super.updatedAt,
  });

  factory CuentaModel.fromJson(Map<String, dynamic> json) {
    return CuentaModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      moneda: json['moneda'] as String? ?? 'PEN',
      saldoInicial: _toDouble(json['saldo_inicial']),
      saldoActual: _toDouble(json['saldo_actual']),
      color: json['color'] as String?,
      icono: json['icono'] as String?,
      institucion: json['institucion'] as String?,
      esActiva: json['es_activa'] as bool? ?? true,
      incluirEnTotal: json['incluir_en_total'] as bool? ?? true,
      notas: json['notas'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
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
    'nombre': nombre,
    'tipo': tipo,
    'moneda': moneda,
    'saldo_inicial': saldoInicial,
    'saldo_actual': saldoActual,
    'color': color,
    'icono': icono,
    'institucion': institucion,
    'es_activa': esActiva,
    'incluir_en_total': incluirEnTotal,
    'notas': notas,
  };
}
