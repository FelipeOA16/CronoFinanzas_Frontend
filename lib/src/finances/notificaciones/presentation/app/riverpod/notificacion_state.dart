import '../../../domain/entities/notificacion.dart';

abstract class NotificacionState {
  const NotificacionState();
}

class NotificacionInitial extends NotificacionState {
  const NotificacionInitial();
}

class NotificacionLoading extends NotificacionState {
  const NotificacionLoading();
}

class NotificacionLoaded extends NotificacionState {
  final List<Notificacion> alertas;
  const NotificacionLoaded(this.alertas);
}

class NotificacionError extends NotificacionState {
  final String message;
  const NotificacionError(this.message);
}
