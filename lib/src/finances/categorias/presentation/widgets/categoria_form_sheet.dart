import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../finances/transacciones/domain/entities/categoria.dart';
import '../app/riverpod/categoria_controller.dart';

class CategoriaFormSheet extends ConsumerStatefulWidget {
  /// Si se pasa [categoria], es edición; si no, es creación.
  final Categoria? categoria;

  /// Si se pasa [padreId], la nueva categoría será subcategoría.
  final int? padreId;

  const CategoriaFormSheet({super.key, this.categoria, this.padreId});

  static Future<bool?> show(
    BuildContext context, {
    Categoria? categoria,
    int? padreId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CategoriaFormSheet(categoria: categoria, padreId: padreId),
    );
  }

  @override
  ConsumerState<CategoriaFormSheet> createState() => _CategoriaFormSheetState();
}

class _CategoriaFormSheetState extends ConsumerState<CategoriaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  String _tipo = 'gasto';
  String _colorSeleccionado = '#607D8B';
  String _iconoSeleccionado = 'category';
  bool _saving = false;

  static const _colores = [
    '#EF4444',
    '#F97316',
    '#F59E0B',
    '#22C55E',
    '#10B981',
    '#3B82F6',
    '#6366F1',
    '#9C27B0',
    '#E91E63',
    '#607D8B',
    '#795548',
    '#00BCD4',
    '#FF5722',
    '#4CAF50',
    '#2196F3',
  ];

  static const _iconos = [
    'restaurant',
    'directions_car',
    'home',
    'local_hospital',
    'movie',
    'checkroom',
    'school',
    'work',
    'laptop',
    'trending_up',
    'card_giftcard',
    'category',
    'sports_esports',
    'fitness_center',
    'flight',
    'shopping_cart',
    'local_cafe',
    'pets',
    'attach_money',
    'savings',
  ];

  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'local_hospital': Icons.local_hospital,
    'movie': Icons.movie,
    'checkroom': Icons.checkroom,
    'school': Icons.school,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'trending_up': Icons.trending_up,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'shopping_cart': Icons.shopping_cart,
    'local_cafe': Icons.local_cafe,
    'pets': Icons.pets,
    'attach_money': Icons.attach_money,
    'savings': Icons.savings,
  };

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.categoria?.nombre ?? '');
    if (widget.categoria != null) {
      _tipo = widget.categoria!.tipo;
      _colorSeleccionado = widget.categoria!.color ?? '#607D8B';
      _iconoSeleccionado = widget.categoria!.icono ?? 'category';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Color _hex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.tryParse('FF$clean', radix: 16) ?? 0xFF607D8B);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ctrl = ref.read(categoriaControllerProvider.notifier);
    bool ok;
    if (widget.categoria != null) {
      ok = await ctrl.updateCategoria(
        widget.categoria!.id,
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        color: _colorSeleccionado,
        icono: _iconoSeleccionado,
      );
    } else {
      ok = await ctrl.createCategoria(
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipo,
        color: _colorSeleccionado,
        icono: _iconoSeleccionado,
        padreId: widget.padreId,
      );
    }
    if (mounted) Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final isEdicion = widget.categoria != null;
    final isSubcategoria = widget.padreId != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              CFFormHeader(
                title: isEdicion
                    ? 'Editar categoría'
                    : isSubcategoria
                    ? 'Nueva subcategoría'
                    : 'Nueva categoría',
                subtitle: isEdicion
                    ? 'Actualiza la apariencia de esta categoría.'
                    : 'Organiza tus movimientos con una categoría clara.',
              ),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Tipo (solo si es categoría raíz)
              if (!isSubcategoria) ...[
                Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                CFFormSegmented<String>(
                  segments: const [
                    ButtonSegment(value: 'gasto', label: Text('Gasto')),
                    ButtonSegment(value: 'ingreso', label: Text('Ingreso')),
                    ButtonSegment(value: 'ambos', label: Text('Ambos')),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (values) =>
                      setState(() => _tipo = values.first),
                ),
                const SizedBox(height: 16),
              ],

              // Color
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colores.map((hex) {
                  final selected = _colorSeleccionado == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _colorSeleccionado = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _hex(hex),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: AppColors.textPrimary,
                                width: 2.5,
                              )
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: _hex(hex).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Icono
              Text('Icono', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconos.map((key) {
                  final selected = _iconoSeleccionado == key;
                  final iconData = _iconMap[key] ?? Icons.category;
                  return GestureDetector(
                    onTap: () => setState(() => _iconoSeleccionado = key),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? _hex(_colorSeleccionado)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        iconData,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Guardar
              SizedBox(
                width: double.infinity,
                child: CFButton(
                  label: isEdicion ? 'Guardar cambios' : 'Crear',
                  onPressed: _saving ? null : _submit,
                  loading: _saving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
