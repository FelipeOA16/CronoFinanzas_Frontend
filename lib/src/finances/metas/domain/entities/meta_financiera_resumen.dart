class MetaFinancieraResumenItem {
  final int id;
  final String nombre;
  final double montoObjetivo;
  final double montoActual;
  final double porcentaje;
  final String prioridad;
  final DateTime? fechaObjetivo;

  const MetaFinancieraResumenItem({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoActual,
    required this.porcentaje,
    required this.prioridad,
    this.fechaObjetivo,
  });
}

class MetaFinancieraResumen {
  final double totalObjetivo;
  final double totalActual;
  final double porcentajeGlobal;
  final int cantidadActivas;
  final int cantidadCompletadas;
  final List<MetaFinancieraResumenItem> topMetas;

  const MetaFinancieraResumen({
    required this.totalObjetivo,
    required this.totalActual,
    required this.porcentajeGlobal,
    required this.cantidadActivas,
    required this.cantidadCompletadas,
    required this.topMetas,
  });
}
