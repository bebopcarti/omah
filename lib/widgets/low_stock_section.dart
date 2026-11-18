import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';
import 'fade_slide_in.dart';
import 'gradient_widgets.dart';
import 'item_card.dart';
import 'stock_adjustment_sheet.dart';

/// Bagian "Needs Attention": barang Low Stock dan Out of Stock.
class LowStockSection extends StatelessWidget {
  const LowStockSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<InventoryProvider>().needsAttention;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Needs Attention'),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(),
            child: const Row(
              children: [
                Icon(Icons.celebration_rounded, color: AppColors.available),
                SizedBox(width: 12),
                Expanded(
                  child: Text('All stocked up. Nothing needs attention.'),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < items.length; i++)
            FadeSlideIn(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AttentionTile(item: items[i]),
              ),
            ),
      ],
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final Item item;

  const _AttentionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(item.status);
    return Container(
      decoration: AppTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showStockAdjustmentSheet(context, item),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [color.withAlpha(34), color.withAlpha(0)],
              ),
            ),
            child: Row(
              children: [
                CategoryAvatar(category: item.category, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${StockService.formatQuantity(item.quantity)} ${item.unit} remaining',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text.withAlpha(170),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: item.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
