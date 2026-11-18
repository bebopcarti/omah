import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/inventory_provider.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/shopping_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_background.dart';
import 'widgets/bottom_navbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => InventoryProvider()..load(),
      child: const OmahSayaApp(),
    ),
  );
}

class OmahSayaApp extends StatelessWidget {
  const OmahSayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmahSaya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}

/// Kerangka utama: latar gradasi bergerak + Bottom Navigation mengambang.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    InventoryScreen(),
    ShoppingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(index: _index, children: _screens),
        ),
        bottomNavigationBar: BottomNavbar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
