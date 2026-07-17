import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/brand/crono_brand_theme.dart';
import '../../../../core/design_system/components/components.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/app/riverpod/auth_state.dart';
import '../../../auth/presentation/widgets/login_form.dart'
    show authControllerProvider, authRepositoryProvider;
import '../app/riverpod/user_profile_controller.dart';
import '../app/riverpod/user_profile_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _ProfileContent(user: authState.user);
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final User user;
  const _ProfileContent({required this.user});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: MediaQuery.sizeOf(context).width < 600,
          tabAlignment: MediaQuery.sizeOf(context).width < 600
              ? TabAlignment.start
              : TabAlignment.fill,
          labelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Información'),
            Tab(icon: Icon(Icons.lock_outline), text: 'Contraseña'),
            Tab(icon: Icon(Icons.security_outlined), text: 'Seguridad'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EditPerfilTab(user: widget.user),
          _ChangePasswordTab(idUsuario: widget.user.idUsuario),
          _SeguridadTab(user: widget.user),
        ],
      ),
    );
  }
}

// ── Tab: Editar perfil ────────────────────────────────────────────────────────

class _EditPerfilTab extends ConsumerStatefulWidget {
  final User user;
  const _EditPerfilTab({required this.user});

  @override
  ConsumerState<_EditPerfilTab> createState() => _EditPerfilTabState();
}

class _EditPerfilTabState extends ConsumerState<_EditPerfilTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoCtrl;
  late final TextEditingController _nombreMostrarCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _paisCtrl;
  late final TextEditingController _zonaHorariaCtrl;
  late final TextEditingController _idiomaCtrl;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nombreCtrl = TextEditingController(text: u.nombre ?? '');
    _apellidoCtrl = TextEditingController(text: u.apellido ?? '');
    _nombreMostrarCtrl = TextEditingController(text: u.nombreMostrar ?? '');
    _telefonoCtrl = TextEditingController(text: u.telefono ?? '');
    _paisCtrl = TextEditingController(text: u.pais ?? '');
    _zonaHorariaCtrl = TextEditingController(text: u.zonaHoraria);
    _idiomaCtrl = TextEditingController(text: u.idioma);
  }

  @override
  void dispose() {
    for (final c in [
      _nombreCtrl,
      _apellidoCtrl,
      _nombreMostrarCtrl,
      _telefonoCtrl,
      _paisCtrl,
      _zonaHorariaCtrl,
      _idiomaCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save(User user) {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(userProfileControllerProvider.notifier)
        .updatePerfil(
          user.idUsuario,
          nombre: _nombreCtrl.text.trim().isNotEmpty
              ? _nombreCtrl.text.trim()
              : null,
          apellido: _apellidoCtrl.text.trim().isNotEmpty
              ? _apellidoCtrl.text.trim()
              : null,
          nombreMostrar: _nombreMostrarCtrl.text.trim().isNotEmpty
              ? _nombreMostrarCtrl.text.trim()
              : null,
          telefono: _telefonoCtrl.text.trim().isNotEmpty
              ? _telefonoCtrl.text.trim()
              : null,
          pais: _paisCtrl.text.trim().isNotEmpty ? _paisCtrl.text.trim() : null,
          zonaHoraria: _zonaHorariaCtrl.text.trim().isNotEmpty
              ? _zonaHorariaCtrl.text.trim()
              : null,
          idioma: _idiomaCtrl.text.trim().isNotEmpty
              ? _idiomaCtrl.text.trim()
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : widget.user;

    ref.listen<UserProfileState>(userProfileControllerProvider, (_, next) {
      if (next is UserProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(userProfileControllerProvider.notifier).reset();
      } else if (next is UserProfileSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message ?? 'Perfil actualizado'),
            backgroundColor: context.brandColors.verdeExito,
          ),
        );
        ref.read(userProfileControllerProvider.notifier).reset();
      }
    });

    final isLoading = profileState is UserProfileLoading;

    return CFResponsiveFormLayout(
      title: 'Información personal',
      subtitle: 'Mantén actualizados los datos de tu perfil.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: user.fotoUrl != null
                  ? NetworkImage(user.fotoUrl!)
                  : null,
              child: user.fotoUrl == null
                  ? Text(
                      user.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.brandColors.grisNeutro,
              ),
            ),
            const SizedBox(height: 20),
            _field(
              _nombreCtrl,
              'Nombre',
              Icons.person_outline,
              isLoading: isLoading,
              validator: Validators.validateNombre,
            ),
            const SizedBox(height: 14),
            _field(
              _apellidoCtrl,
              'Apellido',
              Icons.person_outline,
              isLoading: isLoading,
            ),
            const SizedBox(height: 14),
            _field(
              _nombreMostrarCtrl,
              'Nombre visible',
              Icons.badge_outlined,
              isLoading: isLoading,
            ),
            const SizedBox(height: 14),
            _field(
              _telefonoCtrl,
              'Teléfono',
              Icons.phone_outlined,
              isLoading: isLoading,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _field(
              _paisCtrl,
              'País',
              Icons.public_outlined,
              isLoading: isLoading,
            ),
            const SizedBox(height: 14),
            _field(
              _zonaHorariaCtrl,
              'Zona horaria',
              Icons.schedule_outlined,
              isLoading: isLoading,
            ),
            const SizedBox(height: 14),
            _field(
              _idiomaCtrl,
              'Idioma',
              Icons.language_outlined,
              isLoading: isLoading,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CFButton(
                label: 'Guardar cambios',
                onPressed: isLoading ? null : () => _save(user),
                icon: Icons.save_outlined,
                loading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isLoading = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: !isLoading,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}

// ── Tab: Cambiar contraseña ───────────────────────────────────────────────────

class _ChangePasswordTab extends ConsumerStatefulWidget {
  final int idUsuario;
  const _ChangePasswordTab({required this.idUsuario});

  @override
  ConsumerState<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends ConsumerState<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _newPwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(userProfileControllerProvider.notifier)
        .changePassword(widget.idUsuario, _newPwdCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileControllerProvider);

    ref.listen<UserProfileState>(userProfileControllerProvider, (_, next) {
      if (next is UserProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(userProfileControllerProvider.notifier).reset();
      } else if (next is PasswordChanged) {
        _newPwdCtrl.clear();
        _confirmCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contraseña actualizada correctamente'),
            backgroundColor: context.brandColors.verdeExito,
          ),
        );
        ref.read(userProfileControllerProvider.notifier).reset();
      }
    });

    final isLoading = profileState is UserProfileLoading;

    return CFResponsiveFormLayout(
      title: 'Cambiar contraseña',
      subtitle: 'Protege tu cuenta con una contraseña segura.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Icon(
              Icons.lock_reset_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cambiar contraseña',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _newPwdCtrl,
              enabled: !isLoading,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmCtrl,
              enabled: !isLoading,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) =>
                  Validators.validateConfirmPassword(v, _newPwdCtrl.text),
            ),
            const SizedBox(height: 28),
            CFButton(
              label: 'Actualizar contraseña',
              onPressed: isLoading ? null : _submit,
              icon: Icons.save_outlined,
              loading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Seguridad ────────────────────────────────────────────────────────────

class _SeguridadTab extends ConsumerStatefulWidget {
  final User user;
  const _SeguridadTab({required this.user});

  @override
  ConsumerState<_SeguridadTab> createState() => _SeguridadTabState();
}

class _SeguridadTabState extends ConsumerState<_SeguridadTab> {
  bool _sendingVerification = false;

  Future<void> _resendVerification() async {
    setState(() => _sendingVerification = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resendVerification();
    if (!mounted) return;
    setState(() => _sendingVerification = false);
    if (result.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Correo de verificación enviado. Revisa tu bandeja.',
          ),
          backgroundColor: context.brandColors.verdeExito,
        ),
      );
    } else {
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
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : widget.user;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        // ── Email verification status ──────────────────────────────────────
        CFCard(
          elevated: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      user.emailVerificado
                          ? Icons.verified_outlined
                          : Icons.warning_amber_outlined,
                      color: user.emailVerificado
                          ? context.brandColors.verdeExito
                          : context.brandColors.amarilloAdvertencia,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Correo electrónico',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  user.emailVerificado
                      ? 'Tu correo ha sido verificado.'
                      : 'Tu correo aún no ha sido verificado. Verifica para mayor seguridad.',
                  style: TextStyle(
                    color: user.emailVerificado
                        ? context.brandColors.verdeExito
                        : context.brandColors.amarilloAdvertencia,
                  ),
                ),
                if (!user.emailVerificado) ...[
                  const SizedBox(height: 12),
                  CFOutlinedButton(
                    label: 'Reenviar correo de verificación',
                    onPressed: _sendingVerification
                        ? null
                        : _resendVerification,
                    icon: Icons.send_outlined,
                    loading: _sendingVerification,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ── Active sessions ────────────────────────────────────────────────
        CFCard(
          elevated: true,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Sesiones activas'),
            subtitle: const Text('Gestiona los dispositivos conectados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/sesiones-activas'),
          ),
        ),
      ],
    );
  }
}
