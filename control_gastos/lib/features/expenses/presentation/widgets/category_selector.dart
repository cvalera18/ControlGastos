import 'package:flutter/material.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';

class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected?.id == category.id;
          return FilterChip(
            label: Text('${category.icon} ${category.name}'),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}
