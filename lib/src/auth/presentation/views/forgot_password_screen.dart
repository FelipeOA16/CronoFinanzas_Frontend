import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/utils/validators.dart';
import '../../presentation/widgets/login_form.dart' show authRepositoryProvider;

// ── Provider ──────────────────────────────────────────────────────────────────

final _forgotPasswordLoadingProvider = StateProvider<bool>((_) => false);

// ── Screen ────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(_forgotPasswordLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.forgotPassword(_emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      // Always show success to prevent user enumeration
      if (mounted) setState(() => _sent = true);
    } finally {
      if (mounted) {
        ref.read(_forgotPasswordLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_forgotPasswordLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: CFResponsiveFormLayout(
        title: 'Recuperar contraseña',
        subtitle: 'Recibe un enlace seguro para recuperar el acceso.',
        child: _sent
            ? _SuccessView(email: _emailController.text.trim())
            : _FormView(
                formKey: _formKey,
                emailController: _emailController,
                isLoading: isLoading,
                onSubmit: _submit,
              ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
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
            Icons.lock_reset_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Ingresa el correo de tu cuenta y te enviaremos un enlace para restablecer tu contraseña.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),
          CFButton(
            label: 'Enviar enlace de recuperación',
            onPressed: isLoading ? null : onSubmit,
            loading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          '¡Correo enviado!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Si existe una cuenta con $email, recibirás un enlace para restablecer tu contraseña.\n\nRevisa también la carpeta de spam.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CFOutlinedButton(
          label: 'Volver al inicio de sesión',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
