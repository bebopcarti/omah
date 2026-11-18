import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Latar gradasi yang bergerak sangat pelan (siklus 28 detik) dengan
/// gumpalan cahaya dan "debu" yang melayang naik. Warna tetap lembut
/// supaya teks nyaman dibaca.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // Konten tidak ikut dibangun ulang setiap frame.
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        final k = (math.sin(t) + 1) / 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(math.cos(t), math.sin(t)),
                  end: Alignment(-math.cos(t), -math.sin(t)),
                  colors: [
                    AppColors.background,
                    Color.lerp(AppColors.blush, AppColors.lilac, k)!,
                    Color.lerp(AppColors.oatWarm, AppColors.blush, 1 - k)!,
                    Color.lerp(
                      AppColors.lilac,
                      AppColors.accent,
                      0.15 + 0.55 * k,
                    )!,
                  ],
                  stops: const [0.0, 0.38, 0.7, 1.0],
                ),
              ),
            ),
            CustomPaint(painter: _AtmospherePainter(_controller.value)),
            child!,
          ],
        );
      },
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  final double progress;

  _AtmospherePainter(this.progress);

  // (x, y, radius relatif, warna, fase)
  static const _blobs = <(double, double, double, Color, double)>[
    (0.10, 0.12, 0.62, AppColors.accent, 0.0),
    (0.95, 0.35, 0.55, AppColors.secondary, 2.1),
    (0.20, 0.80, 0.60, AppColors.lilac, 4.0),
    (0.85, 0.95, 0.50, AppColors.accent, 5.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    // Gumpalan cahaya yang melayang pelan.
    for (final b in _blobs) {
      final center = Offset(
        size.width * (b.$1 + 0.07 * math.sin(t + b.$5)),
        size.height * (b.$2 + 0.05 * math.cos(t + b.$5)),
      );
      final radius = size.shortestSide * b.$3;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [b.$4.withAlpha(95), b.$4.withAlpha(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    // Butiran halus yang naik perlahan.
    for (var i = 0; i < 14; i++) {
      final seed = i / 14;
      final p = (progress * 2 + seed) % 1.0;
      final x = size.width * ((i * 0.37) % 1.0) + 12 * math.sin(t * 2 + i);
      final y = size.height * (1.05 - p * 1.1);
      final fade = math.sin(p * math.pi);
      final paint = Paint()
        ..color = AppColors.primary.withAlpha((70 * fade).round());
      canvas.drawCircle(Offset(x, y), 2 + (i % 4) * 1.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) =>
      old.progress != progress;
}
