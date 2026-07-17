import '../../domain/entities/transaccion.dart';
import 'categoria_model.dart';

class TransaccionModel extends Transaccion {
  const TransaccionModel({
    required super.id,
    required super.usuarioId,
    required super.cuentaId,
    super.cuentaDestinoId,
    required super.tipo,
    required super.monto,
    required super.moneda,
    required super.fecha,
    super.categoriaId,
    super.descripcion,
    super.pagadoA,
    super.notas,
    required super.esRecurrente,
    super.createdAt,
    super.updatedAt,
    super.categoriaNombre,
    super.categoriaColor,
    super.categoriaIcono,
  });

  factory TransaccionModel.fromJson(Map<String, dynamic> json) {
    final categoriaJson = json['categoria'] as Map<String, dynamic>?;
    CategoriaModel? cat;
    if (categoriaJson != null) {
      cat = CategoriaModel.fromJson(categoriaJson);
    }

    return TransaccionModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int,
      cuentaId: json['cuenta_id'] as int,
      cuentaDestinoId: json['cuenta_destino_id'] as int?,
      tipo: json['tipo'] as String,
      monto: _toDouble(json['monto']),
      moneda: json['moneda'] as String? ?? 'PEN',
      fecha: DateTime.parse(json['fecha'] as String),
      categoriaId: json['categoria_id'] as int?,
      descripcion: json['descripcion'] as String?,
      pagadoA: json['pagado_a'] as String?,
      notas: json['notas'] as String?,
      esRecurrente: json['es_recurrente'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      categoriaNombre: cat?.nombre,
      categoriaColor: cat?.color,
      categoriaIcono: cat?.icono,
    );
  }

  Map<String, dynamic> toJson() => {
    'cuenta_id': cuentaId,
    'tipo': tipo,
    'monto': monto,
    'moneda': moneda,
    'fecha': fecha.toIso8601String().substring(0, 10), // YYYY-MM-DD
    if (categoriaId != null) 'categoria_id': categoriaId,
    if (cuentaDestinoId != null) 'cuenta_destino_id': cuentaDestinoId,
    if (descripcion != null) 'descripcion': descripcion,
    if (pagadoA != null) 'pagado_a': pagadoA,
    if (notas != null) 'notas': notas,
    'es_recurrente': esRecurrente,
  };

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
