import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

/// Category chips: All + seluruh kategori.
class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    Widget chip(String label, int? id) {
      final selected = provider.selectedCategoryId == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(color: AppColors.accent.withAlpha(120)),
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => provider.setCategory(id),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip('All', null),
          for (final c in provider.categories) chip(c.name, c.id),
        ],
      ),
    );
  }
}
