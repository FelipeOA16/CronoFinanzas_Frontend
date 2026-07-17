class ResumenMes {
  final int mes;
  final int anio;
  final double totalIngresos;
  final double totalGastos;
  final double neto;
  final double balanceTotalCuentas;

  const ResumenMes({
    required this.mes,
    required this.anio,
    required this.totalIngresos,
    required this.totalGastos,
    required this.neto,
    required this.balanceTotalCuentas,
  });
}

class GastoCategoria {
  final int? categoriaId;
  final String nombre;
  final String color;
  final double monto;
  final double porcentaje;

  const GastoCategoria({
    this.categoriaId,
    required this.nombre,
    required this.color,
    required this.monto,
    required this.porcentaje,
  });
}

class FlujoMes {
  final int mes;
  final int anio;
  final double ingresos;
  final double gastos;
  final double neto;

  const FlujoMes({
    required this.mes,
    required this.anio,
    required this.ingresos,
    required this.gastos,
    required this.neto,
  });
}

class ReporteData {
  final ResumenMes resumen;
  final List<GastoCategoria> gastosPorCategoria;
  final List<FlujoMes> flujoMensual;

  const ReporteData({
    required this.resumen,
    required this.gastosPorCategoria,
    required this.flujoMensual,
  });
}
