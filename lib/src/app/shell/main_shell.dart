import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/design_system/brand/brand_icons.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/tokens/theme_tokens.dart';
import '../../auth/presentation/app/riverpod/auth_state.dart';
import '../../auth/presentation/widgets/login_form.dart'
    show authControllerProvider;
import '../../education/presentation/views/education_screen.dart';
import '../../finances/categorias/presentation/views/categorias_screen.dart';
import '../../finances/captura_rapida/platform/quick_capture_platform_service.dart';
import '../../finances/captura_rapida/presentation/app/riverpod/captura_rapida_controller.dart';
import '../../finances/captura_rapida/presentation/widgets/captura_rapida_sheet.dart';
import '../../finances/cuentas/domain/entities/cuenta.dart';
import '../../finances/cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../finances/cuentas/presentation/app/riverpod/cuenta_state.dart';
import '../../finances/cuentas/presentation/views/cuentas_screen.dart';
import '../../finances/deudas_prestamos/presentation/views/deudas_prestamos_screen.dart';
import '../../finances/metas/presentation/views/metas_screen.dart';
import '../../finances/notificaciones/presentation/app/riverpod/notificacion_controller.dart';
import '../../finances/notificaciones/presentation/views/notificaciones_screen.dart';
import '../../finances/presupuestos/presentation/views/presupuestos_screen.dart';
import '../../finances/reportes/presentation/views/reportes_screen.dart';
import '../../finances/transacciones/presentation/views/transacciones_screen.dart';
import '../../home/presentation/views/home_screen.dart';
import '../../user/presentation/views/profile_screen.dart';
import '../di/providers.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final _quickCapturePlatform = QuickCapturePlatformService();
  bool _checkingExternalQuickCapture = false;

  static const _labels = [
    'Inicio',
    'Cuentas',
    'Movimientos',
    'Categorias',
    'Deudas',
    'Metas',
    'Presupuestos',
    'Reportes',
    'Educacion',
    'Alertas',
    'Perfil',
  ];

  static const _icons = [
    BrandIcons.home,
    BrandIcons.accounts,
    BrandIcons.transactions,
    BrandIcons.categories,
    BrandIcons.debts,
    BrandIcons.goals,
    BrandIcons.budget,
    BrandIcons.reports,
    BrandIcons.education,
    BrandIcons.alerts,
    BrandIcons.profile,
  ];

  static const _activeIcons = [
    BrandIcons.home,
    BrandIcons.accounts,
    BrandIcons.transactions,
    BrandIcons.categories,
    BrandIcons.debts,
    BrandIcons.goals,
    BrandIcons.budget,
    BrandIcons.reports,
    BrandIcons.education,
    BrandIcons.alerts,
    BrandIcons.profile,
  ];

  static const int _homeIndex = 0;
  static const int _accountsIndex = 1;
  static const int _movementsIndex = 2;
  static const int _categoriesIndex = 3;
  static const int _debtsIndex = 4;
  static const int _goalsIndex = 5;
  static const int _budgetsIndex = 6;
  static const int _reportsIndex = 7;
  static const int _educationIndex = 8;
  static const int _alertasIndex = 9;
  static const int _profileIndex = 10;

  final _pages = const [
    _HomeTab(),
    _CuentasTab(),
    _MovimientosTab(),
    _CategoriasTab(),
    _DeudasTab(),
    _MetasTab(),
    _PresupuestosTab(),
    _ReportesTab(),
    _EducationTab(),
    _AlertasTab(),
    _PerfilTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificacionControllerProvider.notifier).loadAlertas();
      _quickCapturePlatform.configureSessionProvider(
        getAccessToken: () => ref.read(tokenStorageProvider).getAccessToken(),
        apiBaseUrl: Env.baseUrl,
        getAccounts: _quickCaptureAccounts,
        onCaptureCreated: _refreshExternalQuickCaptures,
      );
      _syncQuickCaptureSnapshot();
      _consumeExternalQuickCaptureRequest();
    });
  }

  @override
  void dispose() {
    _quickCapturePlatform.clearSessionProvider();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refreshExternalQuickCaptures() {
    ref.invalidate(capturaRapidaResumenProvider);
    ref
        .read(capturaRapidaControllerProvider.notifier)
        .load(estado: 'pendiente', force: true);
  }

  List<Map<String, Object>> _quickCaptureAccounts() {
    final state = ref.read(cuentaControllerProvider);
    final accounts = switch (state) {
      CuentaLoaded(:final cuentas) => cuentas,
      CuentaOperationSuccess(:final cuentas) => cuentas,
      CuentaError(:final previousCuentas) => previousCuentas,
      _ => <Cuenta>[],
    };
    return [
      for (final account in accounts.where((item) => item.esActiva))
        <String, Object>{
          'id': account.id,
          'name': account.nombre,
          'currency': account.moneda,
        },
    ];
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncQuickCaptureSnapshot();
      _consumeExternalQuickCaptureRequest();
    }
  }

  Future<void> _syncQuickCaptureSnapshot() async {
    if (!_quickCapturePlatform.isAndroid) return;
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    await _quickCapturePlatform.syncSessionSnapshot(
      accessToken: token,
      apiBaseUrl: Env.baseUrl,
      accounts: _quickCaptureAccounts(),
    );
  }

  Future<void> _consumeExternalQuickCaptureRequest() async {
    if (_checkingExternalQuickCapture || !_quickCapturePlatform.isAndroid) {
      return;
    }
    _checkingExternalQuickCapture = true;
    final launchData = await _quickCapturePlatform
        .consumeOpenQuickCaptureRequest();
    _checkingExternalQuickCapture = false;
    if (launchData != null && mounted) {
      await _openCapturaRapida(
        initialTipo: launchData.tipo,
        initialMonto: launchData.monto,
        initialNota: launchData.nota,
      );
    }
  }

  void _openNuevaTransaccion() {
    Navigator.of(context).pushNamed('/transacciones/form');
  }

  Future<void> _openCapturaRapida({
    String? initialTipo,
    String? initialMonto,
    String? initialNota,
  }) async {
    final submission = await CapturaRapidaSheet.show(
      context,
      initialTipo: initialTipo,
      initialMonto: initialMonto,
      initialNota: initialNota,
    );
    if (submission == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Captura guardada como pendiente.')),
    );
    final saved = await submission.completion;
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar. Intenta nuevamente.'),
        ),
      );
    }
  }

  Future<void> _showNewMovementMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(CFSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Que deseas registrar?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: CFSpacing.sm),
            CFButton(
              label: 'Captura rapida',
              icon: BrandIcons.quickCapture,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _openCapturaRapida();
                });
              },
            ),
            const SizedBox(height: CFSpacing.sm),
            CFOutlinedButton(
              label: 'Nueva transaccion completa',
              icon: BrandIcons.transactions,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _openNuevaTransaccion();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (_quickCapturePlatform.isAndroid) {
      await _quickCapturePlatform.stopBubble();
    }
    await ref.read(authControllerProvider.notifier).logoutUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La burbuja se desactivo al cerrar sesion.'),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  String _userName() {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) return authState.user.displayName;
    return 'Usuario';
  }

  String _userEmail() {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) return authState.user.email;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CuentaState>(cuentaControllerProvider, (_, __) {
      _syncQuickCaptureSnapshot();
    });
    ref.listen<int>(tokenRefreshSignalProvider, (_, __) {
      _syncQuickCaptureSnapshot();
    });
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthAuthenticated) {
        _syncQuickCaptureSnapshot();
      }
    });
    final alertCount = ref.watch(notificacionCountProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return _buildDesktopLayout(alertCount);
        }
        if (constraints.maxWidth >= 840) {
          return _buildTabletLayout(alertCount);
        }
        return _buildMobileLayout(alertCount);
      },
    );
  }

  Widget _buildDesktopLayout(int alertCount) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(alertCount),
          const VerticalDivider(width: 1, thickness: 1, color: CFColors.border),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(int alertCount) {
    return Container(
      width: 236,
      color: CFColors.surface,
      child: Column(
        children: [
          _SidebarHeader(name: _userName(), email: _userEmail()),
          const SizedBox(height: CFSpacing.xs),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _labels.length,
              itemBuilder: (context, i) {
                final selected = _currentIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CFSpacing.sm,
                    vertical: 3,
                  ),
                  child: _SidebarItem(
                    label: _labels[i],
                    icon: selected ? _activeIcons[i] : _icons[i],
                    selected: selected,
                    badgeCount: i == _alertasIndex ? alertCount : 0,
                    onTap: () => _selectPage(i),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 24, indent: 18, endIndent: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CFSpacing.sm),
            child: _SidebarItem(
              label: 'Nueva transaccion',
              icon: BrandIcons.add,
              selected: false,
              accent: CFColors.verdeValle,
              onTap: _openNuevaTransaccion,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CFSpacing.sm),
            child: _SidebarItem(
              label: 'Captura rapida',
              icon: BrandIcons.quickCapture,
              selected: false,
              accent: CFColors.azulAndino,
              onTap: _openCapturaRapida,
            ),
          ),
          const Divider(height: 1, indent: 18, endIndent: 18),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CFSpacing.sm,
              vertical: CFSpacing.xs,
            ),
            child: _SidebarItem(
              label: 'Cerrar sesion',
              icon: CFIcons.logout,
              selected: false,
              accent: CFColors.terracota,
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(int alertCount) {
    return Scaffold(
      body: Row(
        children: [
          _buildCompactNavigation(alertCount),
          const VerticalDivider(width: 1, thickness: 1, color: CFColors.border),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavigation(int alertCount) {
    return Container(
      width: 80,
      color: CFColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: CFSpacing.sm),
            const _CompactBrandMark(),
            const SizedBox(height: CFSpacing.sm),
            CFIconButton(
              icon: BrandIcons.add,
              onPressed: _showNewMovementMenu,
              tooltip: 'Nuevo movimiento',
              color: CFColors.verdeValle,
            ),
            const Divider(height: CFSpacing.lg),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: CFSpacing.xs),
                itemCount: _labels.length,
                itemBuilder: (context, index) {
                  final selected = _currentIndex == index;
                  return _CompactNavItem(
                    label: _labels[index],
                    icon: selected ? _activeIcons[index] : _icons[index],
                    selected: selected,
                    badgeCount: index == _alertasIndex ? alertCount : 0,
                    onTap: () => _selectPage(index),
                  );
                },
              ),
            ),
            const Divider(height: CFSpacing.md),
            Padding(
              padding: const EdgeInsets.only(bottom: CFSpacing.sm),
              child: CFIconButton(
                icon: CFIcons.logout,
                onPressed: _logout,
                tooltip: 'Cerrar sesion',
                color: CFColors.terracota,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(int alertCount) {
    final mobileCurrentIndex = _mobileDestinationIndex(_currentIndex);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
          NavigationBar(
            selectedIndex: mobileCurrentIndex,
            onDestinationSelected: (index) =>
                _onMobileDestinationSelected(index, alertCount),
            destinations: const [
              NavigationDestination(
                icon: Icon(BrandIcons.home),
                selectedIcon: Icon(BrandIcons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(BrandIcons.accounts),
                selectedIcon: Icon(BrandIcons.accounts),
                label: 'Cuentas',
              ),
              NavigationDestination(
                icon: Icon(BrandIcons.add),
                selectedIcon: Icon(BrandIcons.add),
                label: 'Nueva',
              ),
              NavigationDestination(
                icon: Icon(BrandIcons.budget),
                selectedIcon: Icon(BrandIcons.budget),
                label: 'Presupuesto',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_rounded),
                selectedIcon: Icon(Icons.menu_open_rounded),
                label: 'Mas',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPage(int index) {
    setState(() => _currentIndex = index);
  }

  int _mobileDestinationIndex(int pageIndex) {
    return switch (pageIndex) {
      _homeIndex => 0,
      _accountsIndex => 1,
      _budgetsIndex => 3,
      _ => 4,
    };
  }

  void _onMobileDestinationSelected(int index, int alertCount) {
    switch (index) {
      case 0:
        _selectPage(_homeIndex);
        return;
      case 1:
        _selectPage(_accountsIndex);
        return;
      case 2:
        _showNewMovementMenu();
        return;
      case 3:
        _selectPage(_budgetsIndex);
        return;
      case 4:
        _showMoreMenu(alertCount);
        return;
    }
  }

  Future<void> _showMoreMenu(int alertCount) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: CFColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CFRadius.xl)),
      ),
      builder: (sheetContext) {
        final menuIndexes = [
          _movementsIndex,
          _debtsIndex,
          _goalsIndex,
          _reportsIndex,
          _educationIndex,
          _categoriesIndex,
          _alertasIndex,
          _profileIndex,
        ];
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Column(
            children: [
              const _MoreMenuHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    CFSpacing.sm,
                    0,
                    CFSpacing.sm,
                    CFSpacing.sm,
                  ),
                  children: [
                    for (final index in menuIndexes)
                      _MoreMenuItem(
                        label: _labels[index],
                        icon: _currentIndex == index
                            ? _activeIcons[index]
                            : _icons[index],
                        selected: _currentIndex == index,
                        badgeCount: index == _alertasIndex ? alertCount : 0,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          _selectPage(index);
                        },
                      ),
                    const Divider(height: CFSpacing.lg),
                    _MoreMenuItem(
                      label: 'Cerrar sesion',
                      icon: CFIcons.logout,
                      color: CFColors.terracota,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _logout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompactBrandMark extends StatelessWidget {
  const _CompactBrandMark();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'CronoFinanzas',
      child: const CFBrandMark(size: 44, elevated: false),
    );
  }
}

class _CompactNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _CompactNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? CFColors.verdeValle : CFColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: CFSpacing.xxs),
      child: Tooltip(
        message: label,
        child: Material(
          color: selected
              ? CFColors.verdeValle.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(CFRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CFRadius.md),
            child: SizedBox(
              height: 52,
              child: Center(
                child: badgeCount > 0
                    ? Badge(
                        label: Text('$badgeCount'),
                        child: Icon(icon, color: color, size: 22),
                      )
                    : Icon(icon, color: color, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreMenuHeader extends StatelessWidget {
  const _MoreMenuHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CFSpacing.md,
        CFSpacing.sm,
        CFSpacing.sm,
        CFSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mas opciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: CFColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          CFIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final int badgeCount;
  final Color? color;

  const _MoreMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.badgeCount = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        color ?? (selected ? CFColors.verdeValle : CFColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(bottom: CFSpacing.xxs),
      child: ListTile(
        minTileHeight: 52,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFRadius.md),
        ),
        tileColor: selected
            ? CFColors.verdeValle.withValues(alpha: 0.10)
            : Colors.transparent,
        leading: badgeCount > 0
            ? Badge(
                label: Text('$badgeCount'),
                child: Icon(icon, color: foreground),
              )
            : Icon(icon, color: foreground),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: foreground,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: CFColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String name;
  final String email;

  const _SidebarHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CFColors.verdeValle, CFColors.azulAndino],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CFBrandMark(size: 50, elevated: false),
          const SizedBox(height: CFSpacing.sm),
          const Text(
            'CronoFinanzas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Cultiva hoy el futuro que imaginas',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: CFSpacing.md),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int badgeCount;
  final Color? accent;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        accent ?? (selected ? CFColors.verdeValle : CFColors.textSecondary);
    return Material(
      color: selected
          ? CFColors.verdeValle.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(CFRadius.md),
      child: InkWell(
        onTap: onTap,
        hoverColor: CFColors.surfaceAlt,
        borderRadius: BorderRadius.circular(CFRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CFSpacing.sm,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CFRadius.md),
            border: selected
                ? Border.all(color: CFColors.verdeValle.withValues(alpha: 0.22))
                : null,
          ),
          child: Row(
            children: [
              badgeCount > 0
                  ? Badge(
                      label: Text('$badgeCount'),
                      child: Icon(icon, color: color, size: 20),
                    )
                  : Icon(icon, color: color, size: 20),
              const SizedBox(width: CFSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) => const HomeScreen();
}

class _CuentasTab extends StatelessWidget {
  const _CuentasTab();
  @override
  Widget build(BuildContext context) => const CuentasScreen();
}

class _MovimientosTab extends StatelessWidget {
  const _MovimientosTab();
  @override
  Widget build(BuildContext context) => const TransaccionesScreen();
}

class _CategoriasTab extends StatelessWidget {
  const _CategoriasTab();
  @override
  Widget build(BuildContext context) => const CategoriasScreen();
}

class _DeudasTab extends StatelessWidget {
  const _DeudasTab();
  @override
  Widget build(BuildContext context) => const DeudasPrestamosScreen();
}

class _MetasTab extends StatelessWidget {
  const _MetasTab();
  @override
  Widget build(BuildContext context) => const MetasScreen();
}

class _PresupuestosTab extends StatelessWidget {
  const _PresupuestosTab();
  @override
  Widget build(BuildContext context) => const PresupuestosScreen();
}

class _ReportesTab extends StatelessWidget {
  const _ReportesTab();
  @override
  Widget build(BuildContext context) => const ReportesScreen();
}

class _EducationTab extends StatelessWidget {
  const _EducationTab();
  @override
  Widget build(BuildContext context) => const EducationScreen();
}

class _AlertasTab extends StatelessWidget {
  const _AlertasTab();
  @override
  Widget build(BuildContext context) => const NotificacionesScreen();
}

class _PerfilTab extends StatelessWidget {
  const _PerfilTab();
  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
