import '../../domain/entities/categoria.dart';

class CategoriaModel extends Categoria {
  const CategoriaModel({
    required super.id,
    super.usuarioId,
    required super.nombre,
    required super.tipo,
    super.color,
    super.icono,
    super.padreId,
    super.hijas = const [],
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    final hijasRaw = json['hijas'] as List<dynamic>? ?? [];
    return CategoriaModel(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int?,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      color: json['color'] as String?,
      icono: json['icono'] as String?,
      padreId: json['padre_id'] as int?,
      hijas: hijasRaw
          .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'tipo': tipo,
    if (color != null) 'color': color,
    if (icono != null) 'icono': icono,
    if (padreId != null) 'padre_id': padreId,
  };
}
