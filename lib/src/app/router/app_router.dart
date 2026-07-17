import 'package:flutter/material.dart';
import '../../auth/presentation/views/login_screen.dart';
import '../../auth/presentation/views/register_screen.dart';
import '../../auth/presentation/views/forgot_password_screen.dart';
import '../../auth/presentation/views/reset_password_screen.dart';
import '../../auth/presentation/views/verify_email_screen.dart';
import '../../app/shell/main_shell.dart';
import '../../user/presentation/views/profile_screen.dart';
import '../../user/presentation/views/sesiones_activas_screen.dart';
import '../../finances/cuentas/domain/entities/cuenta.dart';
import '../../finances/cuentas/presentation/views/cuentas_screen.dart';
import '../../finances/cuentas/presentation/views/cuenta_form_screen.dart';
import '../../finances/transacciones/presentation/views/transacciones_screen.dart';
import '../../finances/transacciones/presentation/views/transaccion_form_screen.dart';
import '../../finances/captura_rapida/domain/entities/captura_rapida.dart';
import '../../finances/captura_rapida/presentation/views/capturas_rapidas_screen.dart';
import '../../finances/captura_rapida/presentation/views/completar_captura_rapida_screen.dart';
import '../../finances/captura_rapida/presentation/views/captura_rapida_settings_screen.dart';
import '../../finances/deudas_prestamos/presentation/views/deudas_prestamos_screen.dart';
import '../../finances/metas/presentation/views/metas_screen.dart';
import '../../education/domain/entities/financial_lesson.dart';
import '../../education/presentation/views/education_screen.dart';
import '../../education/presentation/views/lesson_detail_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String cuentas = '/cuentas';
  static const String cuentaForm = '/cuentas/form';
  static const String transacciones = '/transacciones';
  static const String transaccionForm = '/transacciones/form';
  static const String capturasRapidas = '/capturas-rapidas';
  static const String completarCapturaRapida = '/capturas-rapidas/completar';
  static const String capturaRapidaSettings = '/capturas-rapidas/settings';
  static const String deudasPrestamos = '/deudas-prestamos';
  static const String metas = '/metas';
  static const String education = '/education';
  static const String lessonDetail = '/education/lesson';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String sesionesActivas = '/sesiones-activas';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        final token = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );
      case verifyEmail:
        final token = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(token: token),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case sesionesActivas:
        return MaterialPageRoute(builder: (_) => const SesionesActivasScreen());
      case cuentas:
        return MaterialPageRoute(builder: (_) => const CuentasScreen());
      case cuentaForm:
        return MaterialPageRoute(
          builder: (_) =>
              CuentaFormScreen(cuenta: settings.arguments as Cuenta?),
        );
      case transacciones:
        return MaterialPageRoute(builder: (_) => const TransaccionesScreen());
      case transaccionForm:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TransaccionFormScreen(),
        );
      case capturasRapidas:
        return MaterialPageRoute(builder: (_) => const CapturasRapidasScreen());
      case completarCapturaRapida:
        final captura = settings.arguments;
        if (captura is! CapturaRapida) {
          return MaterialPageRoute(
            builder: (_) => const CapturasRapidasScreen(),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CompletarCapturaRapidaScreen(captura: captura),
        );
      case capturaRapidaSettings:
        return MaterialPageRoute(
          builder: (_) => const CapturaRapidaSettingsScreen(),
        );
      case deudasPrestamos:
        return MaterialPageRoute(builder: (_) => const DeudasPrestamosScreen());
      case metas:
        return MaterialPageRoute(builder: (_) => const MetasScreen());
      case education:
        return MaterialPageRoute(builder: (_) => const EducationScreen());
      case lessonDetail:
        final lesson = settings.arguments;
        if (lesson is! FinancialLesson) {
          return MaterialPageRoute(builder: (_) => const EducationScreen());
        }
        return MaterialPageRoute(
          builder: (_) => LessonDetailScreen(lesson: lesson),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
