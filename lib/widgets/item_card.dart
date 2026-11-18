import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';
import 'item_form_sheet.dart';
import 'stock_adjustment_sheet.dart';

/// Ikon per kategori.
IconData categoryIcon(String category) {
  switch (category) {
    case 'Kitchen':
      return Icons.soup_kitchen_rounded;
    case 'Cleaning':
      return Icons.cleaning_services_rounded;
    case 'Bathroom':
      return Icons.bathtub_rounded;
    case 'Essentials':
      return Icons.lightbulb_rounded;
    case 'Food & Beverages':
      return Icons.restaurant_rounded;
    default:
      return Icons.inventory_2_rounded;
  }
}

/// Avatar bergradasi dengan ikon kategori.
class CategoryAvatar extends StatelessWidget {
  final String category;
  final double size;

  const CategoryAvatar({super.key, required this.category, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.plumDeep],
        ),
      ),
      child: Icon(categoryIcon(category), color: Colors.white, size: size * 0.5),
    );
  }
}

/// Penanda status stok berwarna semantik.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Kartu satu barang pada Inventory List.
class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.forStatus(item.status);
    return Container(
      decoration: AppTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showStockAdjustmentSheet(context, item),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Garis status di sisi kiri.
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [statusColor, statusColor.withAlpha(110)],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 2, 12),
                    child: Row(
                      children: [
                        CategoryAvatar(category: item.category),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.text.withAlpha(150),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    '${StockService.formatQuantity(item.quantity)} ${item.unit}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  StatusChip(status: item.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) => _onMenu(context, value),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'adjust',
                              child: Text('Adjust stock'),
                            ),
                            PopupMenuItem(
                              value: 'shopping',
                              child: Text('Add to Shopping List'),
                            ),
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onMenu(BuildContext context, String value) async {
    final provider = context.read<InventoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    switch (value) {
      case 'adjust':
        showStockAdjustmentSheet(context, item);
        break;
      case 'shopping':
        final added = await provider.addToShoppingList(item);
        messenger.showSnackBar(SnackBar(
          content: Text(added
              ? '${item.name} added to Shopping List'
              : '${item.name} is already in Shopping List'),
        ));
        break;
      case 'edit':
        showItemFormSheet(context, item: item);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete item?'),
            content: Text(
              '${item.name} will be removed from Inventory. '
              'Its activity history is kept.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.outOfStock),
                ),
              ),
            ],
          ),
        );
        if (confirm == true) await provider.deleteItem(item);
        break;
    }
  }
}
