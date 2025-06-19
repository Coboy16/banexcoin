import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '/core/router/app_router.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.currentRoute,
  });

  final Widget child;
  final int currentIndex;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.trendingUp,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('BanexCoin', style: AppTextStyles.h4),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Search functionality
            },
            icon: const Icon(LucideIcons.search),
          ),
          IconButton(
            onPressed: () {
              context.read<ThemeBloc>().add(const ToggleThemeEvent());
            },
            icon: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Icon(
                  state.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              // Notifications
            },
            icon: const Icon(LucideIcons.bell),
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: child),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondaryBackground,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: currentIndex.clamp(0, 3), // Only show 4 main items
        onTap: (index) {
          final routes = [
            AppRouter.dashboard,
            AppRouter.tradingPairs,
            AppRouter.orderBook,
            AppRouter.calculator,
          ];

          if (index < routes.length) {
            context.go(routes[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.chartCandlestick),
            label: 'Trading',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bookOpen),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calculator),
            label: 'Calculator',
          ),
        ],
      ),
      drawer: _buildMobileDrawer(context),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.secondaryBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.trendingUp,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('BanexCoin', style: AppTextStyles.h3),
                ],
              ),
            ),

            const Divider(),

            // Navigation items
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.user,
                    title: 'Portfolio',
                    route: AppRouter.portfolio,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    route: AppRouter.settings,
                  ),
                  const Divider(),
                  ListTile(
                    leading: BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        return Icon(
                          state.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                          color: AppColors.textMuted,
                        );
                      },
                    ),
                    title: Text(
                      'Toggle Theme',
                      style: AppTextStyles.bodyMedium,
                    ),
                    onTap: () {
                      context.read<ThemeBloc>().add(const ToggleThemeEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // User info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text('Premium User', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isActive ? AppColors.primaryBlue : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primaryBlue.withOpacity(0.1),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop();
      },
    );
  }
}
