import '../../../../transacciones/domain/entities/categoria.dart';

abstract class CategoriaState {
  const CategoriaState();
}

class CategoriaInitial extends CategoriaState {
  const CategoriaInitial();
}

class CategoriaLoading extends CategoriaState {
  const CategoriaLoading();
}

class CategoriaLoaded extends CategoriaState {
  final List<Categoria> categorias; // árbol (solo raíces con .hijas)
  const CategoriaLoaded(this.categorias);
}

class CategoriaError extends CategoriaState {
  final String message;
  const CategoriaError(this.message);
}
