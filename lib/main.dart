import 'package:banexcoin/features/features.dart';
import 'package:flutter/material.dart';

import 'package:responsive_framework/responsive_framework.dart';

import '/core/core.dart';

void main() {
  runApp(const BanexCoinApp());
}

class BanexCoinApp extends StatelessWidget {
  const BanexCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BanexCoin',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const MainAppScreen(),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    TradingPairDetailPage(),
    OrderBookPage(),
    TradingCalculatorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: _currentIndex,
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}
