import '../../../domain/entities/categoria.dart';
import '../../../domain/entities/transaccion.dart';

abstract class TransaccionState {
  const TransaccionState();
}

class TransaccionInitial extends TransaccionState {
  const TransaccionInitial();
}

class TransaccionLoading extends TransaccionState {
  const TransaccionLoading();
}

class TransaccionLoaded extends TransaccionState {
  final List<Transaccion> items;
  final int total;
  final List<Categoria> categorias;
  const TransaccionLoaded({
    required this.items,
    required this.total,
    required this.categorias,
  });
}

class TransaccionOperationSuccess extends TransaccionState {
  final List<Transaccion> items;
  final int total;
  final List<Categoria> categorias;
  final String message;
  const TransaccionOperationSuccess({
    required this.items,
    required this.total,
    required this.categorias,
    required this.message,
  });
}

class TransaccionError extends TransaccionState {
  final String message;
  final List<Transaccion> previousItems;
  final List<Categoria> previousCategorias;
  const TransaccionError(
    this.message, {
    this.previousItems = const [],
    this.previousCategorias = const [],
  });
}
