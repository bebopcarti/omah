import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Teks dengan warna gradasi (untuk judul halaman).
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const GradientText({
    super.key,
    required this.text,
    this.style = AppText.display,
    this.colors = const [AppColors.plumDeep, AppColors.secondary],
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

/// Tombol dengan gradasi plum dan bayangan.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.plumDeep, AppColors.primary, AppColors.plumSoft],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Judul bagian dengan penanda gradasi di kiri.
class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.plumSoft, AppColors.accent],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: AppText.title),
      ],
    );
  }
}
