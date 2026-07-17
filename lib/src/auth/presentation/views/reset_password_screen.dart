import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../presentation/widgets/login_form.dart' show authRepositoryProvider;

// ── Provider ──────────────────────────────────────────────────────────────────

final _resetPasswordStateProvider = StateProvider<_ResetState>(
  (_) => _ResetState.idle,
);

enum _ResetState { idle, loading, success }

// ── Screen ────────────────────────────────────────────────────────────────────

class ResetPasswordScreen extends ConsumerStatefulWidget {
  /// Token passed via deep link query param `?token=...`
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  late String _resolvedToken;

  @override
  void initState() {
    super.initState();
    // Prefer token from route arguments; fall back to URL query param on web.
    _resolvedToken = widget.token;
    if (_resolvedToken.isEmpty && kIsWeb) {
      _resolvedToken = Uri.base.queryParameters['token'] ?? '';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(_resetPasswordStateProvider.notifier).state = _ResetState.loading;
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      _resolvedToken,
      _passwordController.text,
    );
    if (!mounted) return;
    if (result.isOk) {
      ref.read(_resetPasswordStateProvider.notifier).state =
          _ResetState.success;
    } else {
      ref.read(_resetPasswordStateProvider.notifier).state = _ResetState.idle;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_resetPasswordStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: CFResponsiveFormLayout(
        title: 'Nueva contraseña',
        subtitle: 'Elige una contraseña segura para proteger tu cuenta.',
        child: state == _ResetState.success
            ? _SuccessView()
            : _FormView(
                formKey: _formKey,
                passwordController: _passwordController,
                confirmController: _confirmController,
                obscure1: _obscure1,
                obscure2: _obscure2,
                onToggle1: () => setState(() => _obscure1 = !_obscure1),
                onToggle2: () => setState(() => _obscure2 = !_obscure2),
                isLoading: state == _ResetState.loading,
                onSubmit: _submit,
              ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    required this.obscure1,
    required this.obscure2,
    required this.onToggle1,
    required this.onToggle2,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscure1;
  final bool obscure2;
  final VoidCallback onToggle1;
  final VoidCallback onToggle2;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.lock_outline,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Crea tu nueva contraseña',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: obscure1,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure1 ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggle1,
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmController,
            enabled: !isLoading,
            obscureText: obscure2,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure2 ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggle2,
              ),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          CFButton(
            label: 'Cambiar contraseña',
            onPressed: isLoading ? null : onSubmit,
            loading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.check_circle_outline,
          size: 72,
          color: CFColors.success,
        ),
        const SizedBox(height: 24),
        Text(
          '¡Contraseña cambiada!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Tu contraseña fue actualizada correctamente.\nTodas las sesiones activas han sido cerradas por seguridad.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CFButton(
          label: 'Ir al inicio de sesión',
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (_) => false),
        ),
      ],
    );
  }
}
