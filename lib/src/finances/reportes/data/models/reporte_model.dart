import '../../domain/entities/reporte.dart';

class ResumenMesModel extends ResumenMes {
  const ResumenMesModel({
    required super.mes,
    required super.anio,
    required super.totalIngresos,
    required super.totalGastos,
    required super.neto,
    required super.balanceTotalCuentas,
  });

  factory ResumenMesModel.fromJson(Map<String, dynamic> json) {
    return ResumenMesModel(
      mes: json['mes'] as int,
      anio: json['anio'] as int,
      totalIngresos: _toDouble(json['total_ingresos']),
      totalGastos: _toDouble(json['total_gastos']),
      neto: _toDouble(json['neto']),
      balanceTotalCuentas: _toDouble(json['balance_total_cuentas']),
    );
  }
}

class GastoCategoriaModel extends GastoCategoria {
  const GastoCategoriaModel({
    super.categoriaId,
    required super.nombre,
    required super.color,
    required super.monto,
    required super.porcentaje,
  });

  factory GastoCategoriaModel.fromJson(Map<String, dynamic> json) {
    return GastoCategoriaModel(
      categoriaId: json['categoria_id'] as int?,
      nombre: json['nombre'] as String,
      color: json['color'] as String,
      monto: _toDouble(json['monto']),
      porcentaje: _toDouble(json['porcentaje']),
    );
  }
}

class FlujoMesModel extends FlujoMes {
  const FlujoMesModel({
    required super.mes,
    required super.anio,
    required super.ingresos,
    required super.gastos,
    required super.neto,
  });

  factory FlujoMesModel.fromJson(Map<String, dynamic> json) {
    return FlujoMesModel(
      mes: json['mes'] as int,
      anio: json['anio'] as int,
      ingresos: _toDouble(json['ingresos']),
      gastos: _toDouble(json['gastos']),
      neto: _toDouble(json['neto']),
    );
  }
}

class ReporteDataModel extends ReporteData {
  const ReporteDataModel({
    required super.resumen,
    required super.gastosPorCategoria,
    required super.flujoMensual,
  });

  factory ReporteDataModel.fromJson(Map<String, dynamic> json) {
    return ReporteDataModel(
      resumen: ResumenMesModel.fromJson(
        json['resumen'] as Map<String, dynamic>,
      ),
      gastosPorCategoria: (json['gastos_por_categoria'] as List<dynamic>)
          .map((e) => GastoCategoriaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      flujoMensual: (json['flujo_mensual'] as List<dynamic>)
          .map((e) => FlujoMesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
