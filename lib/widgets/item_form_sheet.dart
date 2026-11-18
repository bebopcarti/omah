import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';

/// Form Add Item / Edit Item dalam Bottom Sheet.
/// Jumlah stok hanya bisa diisi saat menambah barang; perubahan berikutnya
/// dilakukan lewat Stock Adjustment agar tercatat di Activity History.
Future<void> showItemFormSheet(BuildContext context, {Item? item}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ChangeNotifierProvider<InventoryProvider>.value(
      value: context.read<InventoryProvider>(),
      child: ItemFormSheet(item: item),
    ),
  );
}

class ItemFormSheet extends StatefulWidget {
  final Item? item;

  const ItemFormSheet({super.key, this.item});

  @override
  State<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _minimum;
  int? _categoryId;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _quantity = TextEditingController();
    _unit = TextEditingController(text: item?.unit ?? '');
    _minimum = TextEditingController(
      text: item != null ? StockService.formatQuantity(item.minimumStock) : '',
    );
    _categoryId = item?.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    _unit.dispose();
    _minimum.dispose();
    super.dispose();
  }

  String? _requiredText(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _number(String? v) {
    final parsed = StockService.parseQuantity(v ?? '');
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<InventoryProvider>();
    final navigator = Navigator.of(context);
    final minimum = StockService.parseQuantity(_minimum.text)!;

    if (_isEdit) {
      final category = provider.categories.firstWhere((c) => c.id == _categoryId);
      await provider.updateItem(widget.item!.copyWith(
        name: _name.text.trim(),
        categoryId: category.id,
        category: category.name,
        unit: _unit.text.trim(),
        minimumStock: minimum,
      ));
    } else {
      await provider.addItem(
        name: _name.text,
        categoryId: _categoryId!,
        quantity: StockService.parseQuantity(_quantity.text)!,
        unit: _unit.text,
        minimumStock: minimum,
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<InventoryProvider>().categories;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? 'Edit Item' : 'Add Item',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: AppTheme.inputDecoration('Item Name'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: AppTheme.inputDecoration('Category'),
                items: [
                  for (final c in categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isEdit) ...[
                    Expanded(
                      child: TextFormField(
                        controller: _quantity,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: AppTheme.inputDecoration('Quantity'),
                        validator: _number,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: _unit,
                      decoration:
                          AppTheme.inputDecoration('Unit', hint: 'kg, L, pcs'),
                      validator: _requiredText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minimum,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: AppTheme.inputDecoration('Minimum Stock'),
                validator: _number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(_isEdit ? 'Save Changes' : 'Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
