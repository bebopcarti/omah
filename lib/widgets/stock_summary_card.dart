import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kartu ringkasan angka pada Dashboard. Angka menghitung naik saat muncul.
class StockSummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const StockSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
    this.icon = Icons.inventory_2_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withAlpha(70), color.withAlpha(0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(36),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    '${v.round()}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
