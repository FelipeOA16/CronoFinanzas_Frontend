import '../../../domain/entities/deuda_prestamo.dart';
import '../../../domain/entities/deuda_prestamo_resumen.dart';
import '../../../domain/entities/pago_deuda_prestamo.dart';

abstract class DeudaPrestamoState {
  const DeudaPrestamoState();
}

class DeudaPrestamoInitial extends DeudaPrestamoState {
  const DeudaPrestamoInitial();
}

class DeudaPrestamoLoading extends DeudaPrestamoState {
  const DeudaPrestamoLoading();
}

class DeudaPrestamoLoaded extends DeudaPrestamoState {
  final List<DeudaPrestamo> items;
  final DeudaPrestamoResumen? resumen;
  final DeudaPrestamo? selected;
  final List<PagoDeudaPrestamo> pagos;
  final String? message;

  const DeudaPrestamoLoaded({
    required this.items,
    this.resumen,
    this.selected,
    this.pagos = const [],
    this.message,
  });

  DeudaPrestamoLoaded copyWith({
    List<DeudaPrestamo>? items,
    DeudaPrestamoResumen? resumen,
    DeudaPrestamo? selected,
    List<PagoDeudaPrestamo>? pagos,
    String? message,
  }) {
    return DeudaPrestamoLoaded(
      items: items ?? this.items,
      resumen: resumen ?? this.resumen,
      selected: selected ?? this.selected,
      pagos: pagos ?? this.pagos,
      message: message,
    );
  }
}

class DeudaPrestamoError extends DeudaPrestamoState {
  final String message;
  final List<DeudaPrestamo> previousItems;
  final DeudaPrestamoResumen? previousResumen;

  const DeudaPrestamoError(
    this.message, {
    this.previousItems = const [],
    this.previousResumen,
  });
}
