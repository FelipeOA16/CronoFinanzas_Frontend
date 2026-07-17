import '../../../domain/entities/presupuesto.dart';

abstract class PresupuestoState {
  const PresupuestoState();
}

class PresupuestoInitial extends PresupuestoState {
  const PresupuestoInitial();
}

class PresupuestoLoading extends PresupuestoState {
  const PresupuestoLoading();
}

class PresupuestoLoaded extends PresupuestoState {
  final List<Presupuesto> presupuestos;
  const PresupuestoLoaded(this.presupuestos);
}

class PresupuestoError extends PresupuestoState {
  final String message;
  final List<Presupuesto> previous;
  const PresupuestoError(this.message, {this.previous = const []});
}
