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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: AppColors.getPrimaryBackground(isDark),
          appBar: AppBar(
            backgroundColor: AppColors.getSecondaryBackground(isDark),
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryBlue(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.trendingUp,
                    color: AppColors.getTextPrimary(!isDark),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'BanexCoin',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  /* Search functionality */
                },
                icon: Icon(
                  LucideIcons.search,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(const ToggleThemeEvent());
                },
                icon: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Icon(
                      state.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                      color: AppColors.getTextSecondary(isDark),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  /* Notifications */
                },
                icon: Icon(
                  LucideIcons.bell,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
          body: Padding(padding: const EdgeInsets.all(0), child: child),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.getSecondaryBackground(isDark),
            selectedItemColor: AppColors.getPrimaryBlue(isDark),
            unselectedItemColor: AppColors.getTextMuted(isDark),
            currentIndex: currentIndex.clamp(0, 3),
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
          drawer: _buildMobileDrawer(context, isDark),
        );
      },
    );
  }

  Widget _buildMobileDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: AppColors.getSecondaryBackground(isDark),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryBlue(isDark),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.trendingUp,
                      color: AppColors.getTextPrimary(!isDark),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'BanexCoin',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.getBorderPrimary(isDark)),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.user,
                    title: 'Portfolio',
                    route: AppRouter.portfolio,
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    route: AppRouter.settings,
                    isDark: isDark,
                  ),
                  Divider(color: AppColors.getBorderPrimary(isDark)),
                  ListTile(
                    leading: BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        return Icon(
                          state.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                          color: AppColors.getTextMuted(isDark),
                        );
                      },
                    ),
                    title: Text(
                      'Toggle Theme',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    onTap: () {
                      context.read<ThemeBloc>().add(const ToggleThemeEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.getBorderPrimary(isDark)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryBlue(isDark),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        LucideIcons.user,
                        color: AppColors.getTextPrimary(!isDark),
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
                              color: AppColors.getTextPrimary(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Premium User',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
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
    required bool isDark,
  }) {
    final isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive
            ? AppColors.getPrimaryBlue(isDark)
            : AppColors.getTextMuted(isDark),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isActive
              ? AppColors.getPrimaryBlue(isDark)
              : AppColors.getTextPrimary(isDark),
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.getPrimaryBlue(isDark).withOpacity(0.1),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop();
      },
    );
  }
}
