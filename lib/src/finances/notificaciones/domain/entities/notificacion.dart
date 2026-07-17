class Notificacion {
  final String tipo; // "alerta" | "excedido"
  final String titulo;
  final String mensaje;
  final int presupuestoId;
  final double porcentaje;

  const Notificacion({
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.presupuestoId,
    required this.porcentaje,
  });

  bool get isExcedido => tipo == 'excedido';
}
