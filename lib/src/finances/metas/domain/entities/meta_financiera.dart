class MetaFinanciera {
  final int id;
  final int usuarioId;
  final String nombre;
  final String? descripcion;
  final double montoObjetivo;
  final double montoActual;
  final String moneda;
  final DateTime fechaInicio;
  final DateTime? fechaObjetivo;
  final String prioridad;
  final String estado;
  final int? cuentaId;
  final int? categoriaId;
  final String? color;
  final String? icono;
  final String? notas;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double porcentaje;
  final double faltante;

  const MetaFinanciera({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    this.descripcion,
    required this.montoObjetivo,
    required this.montoActual,
    required this.moneda,
    required this.fechaInicio,
    this.fechaObjetivo,
    required this.prioridad,
    required this.estado,
    this.cuentaId,
    this.categoriaId,
    this.color,
    this.icono,
    this.notas,
    this.createdAt,
    this.updatedAt,
    this.porcentaje = 0,
    this.faltante = 0,
  });

  bool get estaActiva => estado == 'activa';
  bool get estaCompletada => estado == 'completada';
  double get progreso => montoObjetivo <= 0
      ? 0
      : (montoActual / montoObjetivo).clamp(0, 1).toDouble();
}
