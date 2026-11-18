import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_history.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/gradient_widgets.dart';
import '../widgets/hero_header.dart';
import '../widgets/item_form_sheet.dart';
import '../widgets/low_stock_section.dart';
import '../widgets/stock_summary_card.dart';

/// Home — Dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 18) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          FadeSlideIn(
            index: 0,
            child: HeroHeader(
              eyebrow: _greeting(),
              title: 'Your OmahSaya',
              subtitle: "Here's your household inventory overview.",
            ),
          ),
          const SizedBox(height: 18),

          // Stock Summary
          FadeSlideIn(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: StockSummaryCard(
                    label: 'Total',
                    value: provider.totalItems,
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StockSummaryCard(
                    label: 'Available',
                    value: provider.availableCount,
                    color: AppColors.available,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: StockSummaryCard(
                    label: 'Low Stock',
                    value: provider.lowStockCount,
                    color: AppColors.lowStock,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StockSummaryCard(
                    label: 'Out of Stock',
                    value: provider.outOfStockCount,
                    color: AppColors.outOfStock,
                    icon: Icons.error_outline_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Action
          FadeSlideIn(
            index: 3,
            child: SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Add Item',
                icon: Icons.add_rounded,
                onPressed: () => showItemFormSheet(context),
              ),
            ),
          ),
          const SizedBox(height: 26),

          const FadeSlideIn(index: 4, child: LowStockSection()),
          const SizedBox(height: 26),

          // Recent Activity
          FadeSlideIn(
            index: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionTitle('Recent Activity'),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChangeNotifierProvider<InventoryProvider>.value(
                            value: provider,
                            child: const ActivityHistoryPage(),
                          ),
                        ),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const ActivityHistory(limit: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
