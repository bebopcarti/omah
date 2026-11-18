import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/gradient_widgets.dart';
import '../widgets/item_card.dart';
import '../widgets/item_form_sheet.dart';
import '../widgets/search_bar.dart';

/// Inventory — Household Inventory Management.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final items = provider.filteredItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(heroTag: null, 
        onPressed: () => showItemFormSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientText(text: 'Inventory'),
                const SizedBox(height: 4),
                Text(
                  '${provider.totalItems} kinds of items in your home',
                  style: TextStyle(color: AppColors.text.withAlpha(170)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ItemSearchBar(),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CategoryFilter(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                provider.items.isEmpty
                                    ? Icons.inventory_2_outlined
                                    : Icons.search_off_rounded,
                                size: 56,
                                color: AppColors.accent,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                provider.items.isEmpty
                                    ? 'No items yet.\nTap "Add Item" to start.'
                                    : 'No items match your search.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => FadeSlideIn(
                          key: ValueKey(items[i].id),
                          index: i,
                          child: ItemCard(item: items[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
