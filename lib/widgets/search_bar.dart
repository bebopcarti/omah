import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

/// Search berdasarkan nama barang (nama kelas dibuat `ItemSearchBar`
/// agar tidak bentrok dengan `SearchBar` bawaan Material).
class ItemSearchBar extends StatefulWidget {
  const ItemSearchBar({super.key});

  @override
  State<ItemSearchBar> createState() => _ItemSearchBarState();
}

class _ItemSearchBarState extends State<ItemSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InventoryProvider>();
    return TextField(
      controller: _controller,
      onChanged: provider.setSearchQuery,
      decoration: AppTheme.inputDecoration('Search items').copyWith(
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  provider.setSearchQuery('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}
