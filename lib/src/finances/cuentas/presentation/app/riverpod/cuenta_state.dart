import '../../../domain/entities/cuenta.dart';

abstract class CuentaState {
  const CuentaState();
}

class CuentaInitial extends CuentaState {
  const CuentaInitial();
}

class CuentaLoading extends CuentaState {
  const CuentaLoading();
}

class CuentaLoaded extends CuentaState {
  final List<Cuenta> cuentas;
  const CuentaLoaded(this.cuentas);
}

class CuentaOperationSuccess extends CuentaState {
  final List<Cuenta> cuentas;
  final String message;
  const CuentaOperationSuccess(this.cuentas, this.message);
}

class CuentaError extends CuentaState {
  final String message;
  // Keep the previous list so the UI doesn't blank out on soft errors
  final List<Cuenta> previousCuentas;
  const CuentaError(this.message, {this.previousCuentas = const []});
}
