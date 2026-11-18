import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/stock_transaction.dart';
import '../providers/inventory_provider.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';

/// Quick Stock Adjustment (Core Feature 02) lewat Bottom Sheet.
Future<void> showStockAdjustmentSheet(BuildContext context, Item item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ChangeNotifierProvider<InventoryProvider>.value(
      value: context.read<InventoryProvider>(),
      child: StockAdjustmentSheet(item: item),
    ),
  );
}

class StockAdjustmentSheet extends StatefulWidget {
  final Item item;

  const StockAdjustmentSheet({super.key, required this.item});

  @override
  State<StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends State<StockAdjustmentSheet> {
  final _controller = TextEditingController();
  String _type = StockTransaction.typeIn;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _change => StockService.parseQuantity(_controller.text);

  String? get _preview {
    final change = _change;
    if (change == null || change <= 0) return null;
    if (StockService.validateStockAdjustment(
          current: widget.item.quantity,
          change: change,
          type: _type,
        ) !=
        null) {
      return null;
    }
    final next = StockService.calculateStockAfterAdjustment(
      widget.item.quantity,
      change,
      _type,
    );
    return '${StockService.formatQuantity(widget.item.quantity)} → '
        '${StockService.formatQuantity(next)} ${widget.item.unit}';
  }

  Future<void> _save() async {
    final provider = context.read<InventoryProvider>();
    final navigator = Navigator.of(context);
    final error = StockService.validateStockAdjustment(
      current: widget.item.quantity,
      change: _change,
      type: _type,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _saving = true);
    final result = await provider.adjustStock(
      item: widget.item,
      type: _type,
      change: _change,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _error = result;
        _saving = false;
      });
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final preview = _preview;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Current stock: ${StockService.formatQuantity(item.quantity)} ${item.unit}',
            style: TextStyle(color: AppColors.text.withAlpha(170)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: StockTransaction.typeIn,
                  label: Text('Stock In'),
                  icon: Icon(Icons.add),
                ),
                ButtonSegment(
                  value: StockTransaction.typeOut,
                  label: Text('Stock Out'),
                  icon: Icon(Icons.remove),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _error = null;
              }),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: AppTheme.inputDecoration('Quantity').copyWith(
              suffixText: item.unit,
              errorText: _error,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _save(),
          ),
          if (preview != null) ...[
            const SizedBox(height: 10),
            Text(
              'New stock: $preview',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
