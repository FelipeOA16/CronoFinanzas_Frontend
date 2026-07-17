import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../app/di/providers.dart';
import '../../../transacciones/domain/entities/categoria.dart';
import '../../../transacciones/data/models/categoria_model.dart';
import '../../domain/entities/presupuesto.dart';
import '../app/riverpod/presupuesto_controller.dart';
import '../app/riverpod/presupuesto_state.dart';

// ─── Provider de categorías ──────────────────────────────────────────────────

final _categoriasProvider = FutureProvider<List<Categoria>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final dio = ref.watch(dioProvider);
  final data = await apiClient.handleRequest(
    () => dio.get(Endpoints.categorias),
  );
  final list = data as List<dynamic>;
  return list
      .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class PresupuestoFormScreen extends ConsumerStatefulWidget {
  final Presupuesto? presupuesto; // null = crear
  final int defaultMes;
  final int defaultAnio;

  const PresupuestoFormScreen({
    super.key,
    this.presupuesto,
    required this.defaultMes,
    required this.defaultAnio,
  });

  @override
  ConsumerState<PresupuestoFormScreen> createState() =>
      _PresupuestoFormScreenState();
}

class _PresupuestoFormScreenState extends ConsumerState<PresupuestoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();

  late int _mes;
  late int _anio;
  int? _categoriaId; // null = global
  String _moneda = 'PEN';
  bool _loading = false;

  static const _meses = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  bool get _esEditar => widget.presupuesto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.presupuesto;
    _mes = p?.mes ?? widget.defaultMes;
    _anio = p?.anio ?? widget.defaultAnio;
    _categoriaId = p?.categoriaId;
    _moneda = p?.moneda ?? 'PEN';
    _montoCtrl.text = p != null ? p.montoLimite.toStringAsFixed(2) : '';
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final monto = double.parse(_montoCtrl.text.replaceAll(',', '.'));
    final notifier = ref.read(presupuestoControllerProvider.notifier);

    bool ok;
    if (_esEditar) {
      ok = await notifier.updatePresupuesto(
        id: widget.presupuesto!.id,
        montoLimite: monto,
        moneda: _moneda,
        mes: _mes,
        anio: _anio,
      );
    } else {
      ok = await notifier.createPresupuesto(
        categoriaId: _categoriaId,
        mes: _mes,
        anio: _anio,
        montoLimite: monto,
        moneda: _moneda,
      );
    }

    setState(() => _loading = false);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      final s = ref.read(presupuestoControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s is PresupuestoError ? s.message : 'Error al guardar'),
          backgroundColor: AppColors.gasto,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(_categoriasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _esEditar ? 'Editar presupuesto' : 'Nuevo presupuesto',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CFResponsiveFormLayout(
        title: _esEditar ? 'Editar presupuesto' : 'Nuevo presupuesto',
        subtitle: _esEditar
            ? 'Actualiza la información de este presupuesto.'
            : 'Define un límite para orientar tus gastos.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mes / año (solo en crear)
              if (!_esEditar) ...[
                _SectionLabel('Período'),
                const SizedBox(height: 8),
                CFResponsiveFormRow(
                  children: [
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _mes,
                      decoration: _inputDeco('Mes'),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(_meses[i + 1]),
                        ),
                      ),
                      onChanged: (v) => setState(() => _mes = v!),
                    ),
                    TextFormField(
                      initialValue: _anio.toString(),
                      decoration: _inputDeco('Año'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _anio = int.tryParse(v) ?? _anio,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 2000 || n > 2100) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionLabel('Tipo'),
                const SizedBox(height: 8),
                categoriasAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Text(
                    'Error al cargar categorías: $e',
                    style: const TextStyle(color: AppColors.gasto),
                  ),
                  data: (cats) {
                    final gastos = cats
                        .where((c) => c.tipo == 'gasto' || c.tipo == 'ambos')
                        .toList();
                    return Column(
                      children: [
                        _TipoTile(
                          selected: _categoriaId == null,
                          label: 'Presupuesto global',
                          subtitle: 'Cubre todos los gastos del mes',
                          icon: Icons.account_balance_wallet,
                          onTap: () => setState(() => _categoriaId = null),
                        ),
                        const SizedBox(height: 8),
                        ...gastos.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _TipoTile(
                              selected: _categoriaId == c.id,
                              label: c.nombre,
                              subtitle: 'Categoría de gasto',
                              icon: Icons.category,
                              color: _parseColor(c.color),
                              onTap: () => setState(() => _categoriaId = c.id),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Monto límite
              _SectionLabel('Monto límite'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _montoCtrl,
                decoration: _inputDeco('0.00'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (n == null || n <= 0) {
                    return 'Ingrese un monto válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Moneda
              _SectionLabel('Moneda'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _moneda,
                decoration: _inputDeco('Moneda'),
                items: const [
                  DropdownMenuItem(
                    value: 'PEN',
                    child: Text('PEN — Sol peruano'),
                  ),
                  DropdownMenuItem(value: 'USD', child: Text('USD — Dólar')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR — Euro')),
                ],
                onChanged: (v) => setState(() => _moneda = v!),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: CFButton(
                  label: _esEditar ? 'Guardar cambios' : 'Crear presupuesto',
                  onPressed: _loading ? null : _submit,
                  loading: _loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(hintText: hint);

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

// ─── Widgets auxiliares ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _TipoTile extends StatelessWidget {
  final bool selected;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _TipoTile({
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? fg.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? fg : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? fg : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: fg, size: 20),
          ],
        ),
      ),
    );
  }
}
