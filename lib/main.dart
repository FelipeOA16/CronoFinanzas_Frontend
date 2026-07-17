import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'src/app/di/providers.dart';
import 'src/app/router/app_router.dart';
import 'src/app/theme/app_theme.dart';
import 'src/app/shell/main_shell.dart';
import 'src/auth/presentation/app/riverpod/auth_state.dart';
import 'src/auth/presentation/views/login_screen.dart';
import 'src/auth/presentation/widgets/login_form.dart';

void main() {
  usePathUrlStrategy(); // Clean URLs — no hash (#) prefix, nginx serves index.html
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).loadSession();
      _handleDeepLink();
    });
  }

  /// Handles deep links from emails (reset-password, verify-email).
  /// Reads the token from the current URL (web) and navigates to the
  /// appropriate screen. Safe no-op on non-web platforms.
  void _handleDeepLink() {
    if (!kIsWeb) return;
    final uri = Uri.base;
    final token = uri.queryParameters['token'] ?? '';
    if (token.isEmpty) return;
    final path = uri.path;
    if (path == '/reset-password' || path.startsWith('/reset-password')) {
      _navigatorKey.currentState?.pushNamed(
        AppRouter.resetPassword,
        arguments: token,
      );
    } else if (path == '/verify-email' || path.startsWith('/verify-email')) {
      _navigatorKey.currentState?.pushNamed(
        AppRouter.verifyEmail,
        arguments: token,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (_) => false,
        );
      } else if (next is AuthIdle || next is AuthError) {
        // Only redirect to login if we were previously authenticated (logout)
        if (previous is AuthAuthenticated) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (_) => false,
          );
        }
      }
    });

    // When the auth interceptor fails to refresh a token, reload session
    // (which finds no valid token and transitions to AuthIdle → login screen).
    ref.listen<int>(unauthSignalProvider, (_, __) {
      ref.read(authControllerProvider.notifier).loadSession();
    });

    return MaterialApp(
      title: 'CronoFinanzas',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: _buildInitialScreen(authState),
    );
  }

  /// Only used for the very first frame before any navigation happens.
  Widget _buildInitialScreen(AuthState authState) {
    if (authState is AuthLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState is AuthAuthenticated) {
      return const MainShell();
    }
    return const LoginScreen();
  }
}
