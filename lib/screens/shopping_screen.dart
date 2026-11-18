import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shopping_item.dart';
import '../providers/inventory_provider.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_widgets.dart';

/// Shopping — Shopping List.
class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final pending = provider.pendingShopping;
    final purchased = provider.purchasedShopping;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(heroTag: null, 
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: [
          const GradientText(text: 'Shopping List'),
          const SizedBox(height: 4),
          Text(
            'Plan what to buy next.',
            style: TextStyle(color: AppColors.text.withAlpha(170)),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: SectionTitle('To Buy'),
          ),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration(),
              child: const Text(
                'Nothing to buy. Add items from Inventory or tap "Add".',
              ),
            )
          else
            for (final s in pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ShoppingTile(item: s),
              ),
          if (purchased.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchased',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: provider.clearPurchased,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final s in purchased)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ShoppingTile(item: s),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final provider = context.read<InventoryProvider>();
    final name = TextEditingController();
    final qty = TextEditingController(text: '1');
    final unit = TextEditingController(text: 'pcs');
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Shopping List'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: AppTheme.inputDecoration('Item Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: qty,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: AppTheme.inputDecoration('Qty'),
                      validator: (v) {
                        final p = StockService.parseQuantity(v ?? '');
                        return (p == null || p <= 0) ? 'Invalid' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: unit,
                      decoration: AppTheme.inputDecoration('Unit'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await provider.addCustomShoppingItem(
        name: name.text,
        quantity: StockService.parseQuantity(qty.text)!,
        unit: unit.text,
      );
    }
    name.dispose();
    qty.dispose();
    unit.dispose();
  }
}

class _ShoppingTile extends StatelessWidget {
  final ShoppingItem item;

  const _ShoppingTile({required this.item});

  Future<void> _purchase(BuildContext context) async {
    final provider = context.read<InventoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final controller =
        TextEditingController(text: StockService.formatQuantity(item.quantity));
    String? error;

    final confirmed = await showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Purchased: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: AppTheme.inputDecoration('Purchased quantity')
                    .copyWith(suffixText: item.unit, errorText: error),
              ),
              const SizedBox(height: 10),
              Text(
                item.itemId != null
                    ? 'Inventory stock will be updated automatically.'
                    : 'This item is not in Inventory, so only the list is updated.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.text.withAlpha(170),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final q = StockService.parseQuantity(controller.text);
                if (q == null || q <= 0) {
                  setState(() => error = 'Enter a quantity greater than zero');
                  return;
                }
                Navigator.pop(ctx, q);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (confirmed != null) {
      await provider.purchaseShoppingItem(item, confirmed);
      messenger.showSnackBar(
        SnackBar(content: Text('${item.name} marked as purchased')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InventoryProvider>();
    final done = item.isPurchased;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.text.withAlpha(130) : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${StockService.formatQuantity(item.quantity)} ${item.unit}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          if (done)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.check_circle, color: AppColors.available),
            )
          else ...[
            TextButton(
              onPressed: () => _purchase(context),
              child: const Text('Purchased'),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.removeShoppingItem(item),
            ),
          ],
        ],
      ),
    );
  }
}
