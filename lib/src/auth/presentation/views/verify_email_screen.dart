import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/design_system/tokens/theme_tokens.dart';
import '../widgets/login_form.dart' show authRepositoryProvider;

class VerifyEmailScreen extends ConsumerStatefulWidget {
  /// Token passed as route argument (extracted from email link URL by main.dart).
  final String token;

  const VerifyEmailScreen({super.key, required this.token});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

enum _VerifyState { loading, success, error }

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  _VerifyState _state = _VerifyState.loading;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    // Resolve token: prefer constructor arg, fall back to URL on web.
    var token = widget.token;
    if (token.isEmpty && kIsWeb) {
      token = Uri.base.queryParameters['token'] ?? '';
    }

    if (token.isEmpty) {
      setState(() {
        _state = _VerifyState.error;
        _errorMessage = 'Enlace de verificación inválido o expirado.';
      });
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyEmail(token);
    if (!mounted) return;

    if (result.isOk) {
      setState(() => _state = _VerifyState.success);
    } else {
      setState(() {
        _state = _VerifyState.error;
        _errorMessage = result.failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CFResponsiveFormLayout(
        title: 'Verificación de correo',
        subtitle: 'Confirmamos que tu correo pertenece a tu cuenta.',
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _VerifyState.loading:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Verificando tu correo…'),
          ],
        );

      case _VerifyState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 72,
              color: CFColors.success,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Correo verificado!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu cuenta está completamente activada.',
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

      case _VerifyState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error de verificación',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(_errorMessage, textAlign: TextAlign.center),
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
}
