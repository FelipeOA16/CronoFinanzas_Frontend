class Categoria {
  final int id;
  final int? usuarioId; // null = categoría del sistema
  final String nombre;
  final String tipo; // ingreso | gasto | ambos
  final String? color;
  final String? icono;
  final int? padreId;
  final List<Categoria> hijas;

  const Categoria({
    required this.id,
    this.usuarioId,
    required this.nombre,
    required this.tipo,
    this.color,
    this.icono,
    this.padreId,
    this.hijas = const [],
  });

  bool get esSistema => usuarioId == null;
  bool get esPadre => hijas.isNotEmpty;
}
