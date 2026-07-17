import 'package:flutter/material.dart';
import '../../../../../core/design_system/tokens/theme_tokens.dart';
import '../../domain/entities/categoria.dart';

/// A bottom-sheet grid that lets the user pick a Categoria.
class CategoriaPickerWidget extends StatelessWidget {
  final List<Categoria> categorias;
  final int? selectedId;
  final ValueChanged<Categoria> onSelected;

  const CategoriaPickerWidget({
    super.key,
    required this.categorias,
    required this.onSelected,
    this.selectedId,
  });

  static Future<Categoria?> show(
    BuildContext context, {
    required List<Categoria> categorias,
    int? selectedId,
  }) {
    return showModalBottomSheet<Categoria>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CFRadius.xl)),
      ),
      builder: (_) => CategoriaPickerWidget(
        categorias: categorias,
        selectedId: selectedId,
        onSelected: (cat) => Navigator.of(context).pop(cat),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return CFColors.textMuted;
    final clean = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return CFColors.textMuted;
    }
  }

  IconData _parseIcon(String? name) {
    const map = <String, IconData>{
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'movie': Icons.movie,
      'checkroom': Icons.checkroom,
      'school': Icons.school,
      'work': Icons.work,
      'freelancer': Icons.laptop_mac,
      'trending_up': Icons.trending_up,
      'card_giftcard': Icons.card_giftcard,
      'category': Icons.category,
    };
    return map[name] ?? Icons.label_outline;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CFColors.border,
              borderRadius: BorderRadius.circular(CFRadius.pill),
            ),
          ),
          const SizedBox(height: 12),
          Text('Categoría', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: categorias.length,
              itemBuilder: (_, i) {
                final cat = categorias[i];
                final isSelected = cat.id == selectedId;
                final color = _parseColor(cat.color);
                return GestureDetector(
                  onTap: () => onSelected(cat),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          _parseIcon(cat.icono),
                          color: isSelected ? Colors.white : color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.nombre,
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
