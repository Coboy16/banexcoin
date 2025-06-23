import 'package:banexcoin/core/bloc/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '/core/router/app_router.dart';
import '/core/core.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({
    super.key,
    required this.isExpanded,
    required this.currentIndex,
    required this.currentRoute,
  });

  final bool isExpanded;
  final int currentIndex;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.getSecondaryBackground(isDark),
            border: Border(
              right: BorderSide(
                color: AppColors.getBorderPrimary(isDark),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Logo section
              _buildLogoSection(isDark),

              Divider(height: 1, color: AppColors.getBorderPrimary(isDark)),

              // Navigation items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  children: [
                    _SidebarItem(
                      icon: LucideIcons.layoutDashboard,
                      title: 'Dashboard',
                      isActive: currentRoute == AppRouter.dashboard,
                      isExpanded: isExpanded,
                      isDark: isDark,
                      onTap: () => context.go(AppRouter.dashboard),
                    ),
                    _SidebarItem(
                      icon: LucideIcons.chartCandlestick,
                      title: 'Trading Pairs',
                      isActive: currentRoute == AppRouter.tradingPairs,
                      isExpanded: isExpanded,
                      isDark: isDark,
                      onTap: () => context.go(AppRouter.tradingPairs),
                    ),
                    _SidebarItem(
                      icon: LucideIcons.bookOpen,
                      title: 'Order Book',
                      isActive: currentRoute == AppRouter.orderBook,
                      isExpanded: isExpanded,
                      isDark: isDark,
                      onTap: () => context.go(AppRouter.orderBook),
                    ),

                    // _SidebarItem(
                    //   icon: LucideIcons.calculator,
                    //   title: 'Calculator',
                    //   isActive: currentRoute == AppRouter.calculator,
                    //   isExpanded: isExpanded,
                    //   isDark: isDark,
                    //   onTap: () => context.go(AppRouter.calculator),
                    // ),
                    const SizedBox(height: AppSpacing.lg),

                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'MARKETS',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.getTextMuted(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    _SidebarItem(
                      icon: LucideIcons.bitcoin,
                      title: 'BTC/USDT',
                      isExpanded: isExpanded,
                      isDark: isDark,
                      subtitle: '\$43,250.00',
                      trailing: '+2.5%',
                      trailingColor: AppColors.getBuyGreen(isDark),
                      onTap: () {},
                    ),
                    _SidebarItem(
                      icon: LucideIcons.hexagon,
                      title: 'ETH/USDT',
                      isExpanded: isExpanded,
                      isDark: isDark,
                      subtitle: '\$2,650.00',
                      trailing: '-1.2%',
                      trailingColor: AppColors.getSellRed(isDark),
                      onTap: () {},
                    ),
                    _SidebarItem(
                      icon: LucideIcons.circle,
                      title: 'BNB/USDT',
                      isExpanded: isExpanded,
                      isDark: isDark,
                      subtitle: '\$315.50',
                      trailing: '+4.7%',
                      trailingColor: AppColors.getBuyGreen(isDark),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Bottom section
              _buildBottomSection(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoSection(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getPrimaryBlue(isDark),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(
              LucideIcons.trendingUp,
              color: AppColors.getTextPrimary(isDark),
              size: 24,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'BanexCoin',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(isDark),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
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
                      color: AppColors.getTextPrimary(isDark),
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
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => context.go(AppRouter.settings),
                icon: Icon(
                  LucideIcons.settings,
                  color: AppColors.getTextMuted(isDark),
                  size: isExpanded ? 20 : 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<NavigationBloc>().add(
                    const ToggleSidebarEvent(),
                  );
                },
                icon: Icon(
                  isExpanded
                      ? LucideIcons.panelLeftClose
                      : LucideIcons.panelLeftOpen,
                  color: AppColors.getTextMuted(isDark),
                  size: isExpanded ? 20 : 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isExpanded,
    required this.onTap,
    required this.isDark,
    this.isActive = false,
    this.subtitle,
    this.trailing,
    this.trailingColor,
  });

  final IconData icon;
  final String title;
  final bool isExpanded;
  final bool isActive;
  final bool isDark;
  final String? subtitle;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Material(
        color: isActive
            ? AppColors.getPrimaryBlue(isDark).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.getPrimaryBlue(isDark)
                      : AppColors.getTextMuted(isDark),
                  size: 20,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isActive
                                ? AppColors.getPrimaryBlue(isDark)
                                : AppColors.getTextPrimary(isDark),
                            fontWeight: isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.getTextMuted(isDark),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: AppTextStyles.caption.copyWith(
                        color: trailingColor ?? AppColors.getTextMuted(isDark),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
