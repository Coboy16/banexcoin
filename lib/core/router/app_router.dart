import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/layout/layaout.dart';
import '/features/features.dart';
import '/core/bloc/blocs.dart';

class AppRouter {
  // Route paths
  static const String dashboard = '/';
  static const String tradingPairs = '/trading-pairs';
  static const String orderBook = '/order-book';
  static const String calculator = '/calculator';
  static const String portfolio = '/portfolio';
  static const String settings = '/settings';

  // Route names for easier reference
  static const String dashboardName = 'dashboard';
  static const String tradingPairsName = 'trading-pairs';
  static const String orderBookName = 'order-book';
  static const String calculatorName = 'calculator';
  static const String portfolioName = 'portfolio';
  static const String settingsName = 'settings';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: dashboard,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return BlocProvider(
              create: (context) => NavigationBloc(),
              child: MainLayoutPage(child: child),
            );
          },
          routes: [
            GoRoute(
              path: dashboard,
              name: dashboardName,
              pageBuilder: (context, state) {
                _updateNavigationState(context, dashboard, 0);
                return const NoTransitionPage(child: DashboardPage());
              },
            ),
            GoRoute(
              path: tradingPairs,
              name: tradingPairsName,
              pageBuilder: (context, state) {
                _updateNavigationState(context, tradingPairs, 1);
                return const NoTransitionPage(child: TradingPairDetailPage());
              },
            ),
            GoRoute(
              path: orderBook,
              name: orderBookName,
              pageBuilder: (context, state) {
                _updateNavigationState(context, orderBook, 2);
                return const NoTransitionPage(child: OrderBookPage());
              },
            ),
            GoRoute(
              path: calculator,
              name: calculatorName,
              pageBuilder: (context, state) {
                _updateNavigationState(context, calculator, 3);
                return const NoTransitionPage(child: TradingCalculatorPage());
              },
            ),
            // GoRoute(
            //   path: portfolio,
            //   name: portfolioName,
            //   pageBuilder: (context, state) {
            //     _updateNavigationState(context, portfolio, 4);
            //     return const NoTransitionPage(child: PortfolioPage());
            //   },
            // ),
            // GoRoute(
            //   path: settings,
            //   name: settingsName,
            //   pageBuilder: (context, state) {
            //     _updateNavigationState(context, settings, 5);
            //     return const NoTransitionPage(child: SettingsPage());
            //   },
            // ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(dashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _updateNavigationState(
    BuildContext context,
    String route,
    int index,
  ) {
    final navigationBloc = context.read<NavigationBloc>();
    navigationBloc.add(NavigateToPageEvent(route: route, index: index));
  }

  // Helper methods for navigation
  static void navigateTo(BuildContext context, String route) {
    context.go(route);
  }

  static void navigateToDashboard(BuildContext context) {
    context.goNamed(dashboardName);
  }

  static void navigateToTradingPairs(BuildContext context) {
    context.goNamed(tradingPairsName);
  }

  static void navigateToOrderBook(BuildContext context) {
    context.goNamed(orderBookName);
  }

  static void navigateToCalculator(BuildContext context) {
    context.goNamed(calculatorName);
  }

  // static void navigateToPortfolio(BuildContext context) {
  //   context.goNamed(portfolioName);
  // }

  // static void navigateToSettings(BuildContext context) {
  //   context.goNamed(settingsName);
  // }

  // Get route index for bottom navigation
  static int getRouteIndex(String route) {
    switch (route) {
      case dashboard:
        return 0;
      case tradingPairs:
        return 1;
      case orderBook:
        return 2;
      case calculator:
        return 3;
      // case portfolio:
      //   return 4;
      // case settings:
      //   return 5;
      default:
        return 0;
    }
  }

  // Get route from index
  static String getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return dashboard;
      case 1:
        return tradingPairs;
      case 2:
        return orderBook;
      case 3:
        return calculator;
      case 4:
        return portfolio;
      case 5:
        return settings;
      default:
        return dashboard;
    }
  }

  // Navigation items for sidebar/bottom navigation
  static List<NavigationItem> get navigationItems => [
    const NavigationItem(
      route: dashboard,
      name: dashboardName,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    const NavigationItem(
      route: tradingPairs,
      name: tradingPairsName,
      label: 'Trading Pairs',
      icon: Icons.candlestick_chart_outlined,
      activeIcon: Icons.candlestick_chart,
    ),
    const NavigationItem(
      route: orderBook,
      name: orderBookName,
      label: 'Order Book',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
    ),
    const NavigationItem(
      route: calculator,
      name: calculatorName,
      label: 'Calculator',
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate,
    ),
    // const NavigationItem(
    //   route: portfolio,
    //   name: portfolioName,
    //   label: 'Portfolio',
    //   icon: Icons.account_balance_wallet_outlined,
    //   activeIcon: Icons.account_balance_wallet,
    // ),
    // const NavigationItem(
    //   route: settings,
    //   name: settingsName,
    //   label: 'Settings',
    //   icon: Icons.settings_outlined,
    //   activeIcon: Icons.settings,
    // ),
  ];
}

class NavigationItem {
  const NavigationItem({
    required this.route,
    required this.name,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String route;
  final String name;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
