import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/stock_transaction.dart';
import '../providers/inventory_provider.dart';
import '../services/stock_service.dart';
import '../theme/app_theme.dart';
import 'animated_background.dart';
import 'gradient_widgets.dart';

/// Activity History (Core Feature 03). Dengan [limit] tampil sebagai
/// ringkasan di Dashboard; tanpa limit menampilkan seluruh riwayat.
class ActivityHistory extends StatelessWidget {
  final int? limit;

  const ActivityHistory({super.key, this.limit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final list = limit == null
        ? provider.transactions
        : provider.recentActivity(limit!);

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(),
        child: const Text('No activity yet. Add or adjust an item to begin.'),
      );
    }

    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          for (var i = 0; i < list.length; i++) ...[
            _ActivityTile(transaction: list[i]),
            if (i != list.length - 1)
              Divider(height: 1, color: AppColors.accent.withAlpha(90)),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final StockTransaction transaction;

  const _ActivityTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color = t.isIn ? AppColors.available : AppColors.lowStock;
    final sign = t.isIn ? '+' : '-';
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withAlpha(36),
        child: Icon(
          t.isIn ? Icons.arrow_downward : Icons.arrow_upward,
          size: 16,
          color: color,
        ),
      ),
      title: Text(
        t.itemName ?? 'Item #${t.itemId}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${t.isIn ? 'Stock In' : 'Stock Out'} · '
        '${DateFormat('d MMM, HH:mm').format(t.date)}',
      ),
      trailing: Text(
        '$sign${StockService.formatQuantity(t.quantity)} ${t.unit ?? ''}'.trim(),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Halaman "View All Activity".
class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const GradientText(
            text: 'Activity History',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: ActivityHistory(),
        ),
      ),
    );
  }
}
