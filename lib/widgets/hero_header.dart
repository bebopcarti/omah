import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kartu sambutan di Home: gradasi plum yang bergeser pelan dan ilustrasi
/// rumah yang dilukis dengan kode (jendela berkedip, bintang berkelip).
class HeroHeader extends StatefulWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const HeroHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  State<HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        final k = (math.sin(t) + 1) / 2;
        return Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment(-1 + 0.6 * math.cos(t), -1 + 0.6 * math.sin(t)),
              end: Alignment(1 - 0.6 * math.cos(t), 1 - 0.6 * math.sin(t)),
              colors: [
                Color.lerp(AppColors.plumDeep, AppColors.primary, k)!,
                AppColors.primary,
                Color.lerp(AppColors.secondary, AppColors.plumSoft, 1 - k)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.plumDeep.withAlpha(90),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HeroArtPainter(_controller.value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 128, 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.eyebrow,
                        style: AppText.eyebrow.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: AppText.display.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withAlpha(215),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroArtPainter extends CustomPainter {
  final double progress;

  _HeroArtPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final c = Offset(size.width * 0.80, size.height * 0.52);

    // Cincin orbit.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withAlpha(30);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(c, 38.0 * i + 4 * math.sin(t + i), ring);
    }

    // Cahaya di belakang rumah.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withAlpha(140),
          AppColors.accent.withAlpha(0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: 90));
    canvas.drawCircle(c, 90, glow);

    // Rumah (naik-turun pelan).
    canvas.save();
    canvas.translate(0, 3 * math.sin(t * 2));

    // Cerobong.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx + 16, c.dy - 40, 10, 22),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.secondary,
    );

    // Badan rumah.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, 18), width: 70, height: 50),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.background,
    );

    // Atap.
    final roof = Path()
      ..moveTo(c.dx - 48, c.dy - 4)
      ..lineTo(c.dx, c.dy - 46)
      ..lineTo(c.dx + 48, c.dy - 4)
      ..close();
    canvas.drawPath(roof, Paint()..color = AppColors.accent);

    // Pintu.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - 8, c.dy + 22, 16, 21),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.primary,
    );

    // Jendela yang berpendar.
    final windowPaint = Paint()
      ..color = AppColors.lowStock.withAlpha(
        (190 + 50 * math.sin(t * 3)).round(),
      );
    for (final dx in const [-22.0, 22.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c.translate(dx, 12), width: 14, height: 14),
          const Radius.circular(3),
        ),
        windowPaint,
      );
    }
    canvas.restore();

    // Bintang yang mengorbit dan berkelip.
    for (var i = 0; i < 7; i++) {
      final angle = i * (2 * math.pi / 7) + t;
      final r = 70.0 + 18 * (i % 3);
      final p = Offset(
        c.dx + math.cos(angle) * r,
        c.dy + math.sin(angle) * r * 0.7,
      );
      final twinkle = (math.sin(t * 3 + i * 1.3) + 1) / 2;
      _star(
        canvas,
        p,
        3 + 4 * twinkle,
        Paint()..color = Colors.white.withAlpha((80 + 150 * twinkle).round()),
      );
    }
  }

  void _star(Canvas canvas, Offset p, double r, Paint paint) {
    final path = Path()
      ..moveTo(p.dx, p.dy - r)
      ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
      ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroArtPainter old) =>
      old.progress != progress;
}
