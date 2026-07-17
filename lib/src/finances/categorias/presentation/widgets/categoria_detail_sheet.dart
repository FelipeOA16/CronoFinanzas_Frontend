import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../finances/transacciones/domain/entities/categoria.dart';
import '../app/riverpod/categoria_controller.dart';
import 'categoria_form_sheet.dart';

class CategoriaDetailSheet extends ConsumerWidget {
  final Categoria padre;

  const CategoriaDetailSheet({super.key, required this.padre});

  static Future<void> show(BuildContext context, Categoria padre) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoriaDetailSheet(padre: padre),
    );
  }

  Color _hex(String? hex) {
    if (hex == null) return AppColors.primary;
    final clean = hex.replaceAll('#', '');
    return Color(int.tryParse('FF$clean', radix: 16) ?? 0xFF4F46E5);
  }

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

  IconData _parseIcon(String? name) => _iconMap[name ?? ''] ?? Icons.category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hijas = padre.hijas;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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

          // Header padre
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _hex(padre.color),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _parseIcon(padre.icono),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      padre.nombre,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${hijas.length} subcategoría${hijas.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Añadir subcategoría (siempre disponible)
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                tooltip: 'Añadir subcategoría',
                onPressed: () async {
                  final ok = await CategoriaFormSheet.show(
                    context,
                    padreId: padre.id,
                  );
                  if (ok == true && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Lista subcategorías
          Flexible(
            child: hijas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        Icon(
                          Icons.account_tree_outlined,
                          size: 48,
                          color: AppColors.textHint.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sin subcategorías',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: hijas.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, i) {
                      final hija = hijas[i];
                      return _SubcategoriaRow(
                        hija: hija,
                        iconColor: _hex(padre.color),
                        onEdit: !hija.esSistema
                            ? () async {
                                final ok = await CategoriaFormSheet.show(
                                  context,
                                  categoria: hija,
                                );
                                if (ok == true && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        onDelete: !hija.esSistema
                            ? () async {
                                final confirm = await _confirmDelete(
                                  context,
                                  hija.nombre,
                                );
                                if (confirm == true) {
                                  await ref
                                      .read(
                                        categoriaControllerProvider.notifier,
                                      )
                                      .deleteCategoria(hija.id);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              }
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar subcategoría'),
        content: Text('¿Eliminar "$nombre"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.gasto),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _SubcategoriaRow extends StatelessWidget {
  final Categoria hija;
  final Color iconColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SubcategoriaRow({
    required this.hija,
    required this.iconColor,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.subdirectory_arrow_right, color: iconColor, size: 20),
      ),
      title: Text(
        hija.nombre,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: hija.esSistema
          ? const Text(
              'Sistema',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            )
          : null,
      trailing: hija.esSistema
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.gasto,
                    ),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
    );
  }
}
