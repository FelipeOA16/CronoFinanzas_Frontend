class Presupuesto {
  final int id;
  final int usuarioId;
  final int? categoriaId;
  final String? categoriaNombre;
  final String? categoriaColor;
  final int mes;
  final int anio;
  final double montoLimite;
  final double montoGastado;
  final double porcentaje;
  final String estado; // ok | alerta | excedido
  final String moneda;
  final DateTime? createdAt;

  const Presupuesto({
    required this.id,
    required this.usuarioId,
    this.categoriaId,
    this.categoriaNombre,
    this.categoriaColor,
    required this.mes,
    required this.anio,
    required this.montoLimite,
    required this.montoGastado,
    required this.porcentaje,
    required this.estado,
    required this.moneda,
    this.createdAt,
  });

  bool get esGlobal => categoriaId == null;
  double get montoDisponible => montoLimite - montoGastado;
}
