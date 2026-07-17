import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../app/di/providers.dart';
import '../../data/datasources/auth_remote_data_src.dart';
import '../../data/repos/auth_repo_impl.dart';
import '../../domain/usecases/get_me.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../app/riverpod/auth_controller.dart';
import '../app/riverpod/auth_state.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(dioProvider),
  );
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return Register(ref.watch(authRepositoryProvider));
});

final getMeUseCaseProvider = Provider((ref) {
  return GetMe(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      login: ref.watch(loginUseCaseProvider),
      register: ref.watch(registerUseCaseProvider),
      getMe: ref.watch(getMeUseCaseProvider),
      logout: ref.watch(logoutUseCaseProvider),
      tokenStorage: ref.watch(tokenStorageProvider),
    );
  },
);

// ── Widget ───────────────────────────────────────────────────────────────────

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authControllerProvider.notifier)
        .loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthError) {
        final msg = next.message;
        // 429 — cuenta bloqueada por múltiples intentos fallidos
        if (msg.toLowerCase().contains('bloqueada') ||
            msg.toLowerCase().contains('bloqueado')) {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              icon: const Icon(
                Icons.lock_clock_outlined,
                size: 40,
                color: CFColors.warning,
              ),
              title: const Text('Cuenta bloqueada temporalmente'),
              content: const Text(
                'Has superado el número de intentos permitidos.\n\n'
                'Por seguridad, tu cuenta ha sido bloqueada durante 30 minutos. '
                'Vuelve a intentarlo más tarde.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
      // Navigation is handled reactively by main.dart:
      // AuthAuthenticated → home: MainShell()
    });

    final isLoading = authState is AuthLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            enabled: !isLoading,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 24),
          CFButton(
            label: 'Iniciar sesión',
            onPressed: isLoading ? null : _handleLogin,
            loading: isLoading,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).pushNamed('/forgot-password'),
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).pushNamed('/register'),
            child: const Text('¿No tienes cuenta? Regístrate'),
          ),
        ],
      ),
    );
  }
}
