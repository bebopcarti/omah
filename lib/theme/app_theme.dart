import 'package:flutter/material.dart';

/// Palet utama "Dusty Plum & Oat Milk" + turunannya (lebih gelap / lebih
/// terang dari warna yang sama) untuk gradasi dan kedalaman.
class AppColors {
  AppColors._();

  // --- Palet utama (tidak berubah)
  static const primary = Color(0xFF655365);
  static const secondary = Color(0xFF917A8B);
  static const accent = Color(0xFFC1ACB4);
  static const background = Color(0xFFF7F2EC);
  static const surface = Color(0xFFF1EAE1);
  static const text = Color(0xFF453F43);

  // --- Turunan palet (untuk gradasi)
  static const plumDeep = Color(0xFF3D303E);
  static const plumSoft = Color(0xFF7D6580);
  static const blush = Color(0xFFEBDDE3);
  static const oatWarm = Color(0xFFEFE3D3);
  static const lilac = Color(0xFFE4D6E3);

  static const heroColors = <Color>[plumDeep, primary, secondary];

  // --- Warna semantik
  static const available = Color(0xFF64866A);
  static const lowStock = Color(0xFFC08B43);
  static const outOfStock = Color(0xFFB96861);

  static Color forStatus(String status) {
    switch (status) {
      case 'Out of Stock':
        return outOfStock;
      case 'Low Stock':
        return lowStock;
      default:
        return available;
    }
  }
}

/// Gaya teks terpusat.
class AppText {
  AppText._();

  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.1,
  );
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );
  static const eyebrow = TextStyle(
    fontSize: 11,
    letterSpacing: 2.4,
    fontWeight: FontWeight.w800,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.outOfStock,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.plumDeep,
      ),
    );
  }

  /// Dekorasi input konsisten untuk seluruh form.
  static InputDecoration inputDecoration(String label, {String? hint}) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withAlpha(170),
      border: border(AppColors.accent),
      enabledBorder: border(AppColors.accent),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.outOfStock),
      focusedErrorBorder: border(AppColors.outOfStock),
    );
  }

  /// Kartu semi-transparan berbingkai putih dengan bayangan lembut.
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface.withAlpha(225),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(170), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withAlpha(28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
