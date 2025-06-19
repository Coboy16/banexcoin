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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(
          right: BorderSide(color: AppColors.borderPrimary, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo section
          _buildLogoSection(),

          const Divider(height: 1),

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
                  onTap: () => context.go(AppRouter.dashboard),
                ),
                _SidebarItem(
                  icon: LucideIcons.chartCandlestick,
                  title: 'Trading Pairs',
                  isActive: currentRoute == AppRouter.tradingPairs,
                  isExpanded: isExpanded,
                  onTap: () => context.go(AppRouter.tradingPairs),
                ),
                _SidebarItem(
                  icon: LucideIcons.bookOpen,
                  title: 'Order Book',
                  isActive: currentRoute == AppRouter.orderBook,
                  isExpanded: isExpanded,
                  onTap: () => context.go(AppRouter.orderBook),
                ),
                _SidebarItem(
                  icon: LucideIcons.calculator,
                  title: 'Calculator',
                  isActive: currentRoute == AppRouter.calculator,
                  isExpanded: isExpanded,
                  onTap: () => context.go(AppRouter.calculator),
                ),
                _SidebarItem(
                  icon: LucideIcons.wallet,
                  title: 'Portfolio',
                  isActive: currentRoute == AppRouter.portfolio,
                  isExpanded: isExpanded,
                  onTap: () => context.go(AppRouter.portfolio),
                ),

                const SizedBox(height: AppSpacing.lg),

                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'MARKETS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                _SidebarItem(
                  icon: LucideIcons.bitcoin,
                  title: 'BTC/USDT',
                  isExpanded: isExpanded,
                  subtitle: '\$43,250.00',
                  trailing: '+2.5%',
                  trailingColor: AppColors.buyGreen,
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: LucideIcons.hexagon,
                  title: 'ETH/USDT',
                  isExpanded: isExpanded,
                  subtitle: '\$2,650.00',
                  trailing: '-1.2%',
                  trailingColor: AppColors.sellRed,
                  onTap: () {},
                ),
                _SidebarItem(
                  icon: LucideIcons.circle,
                  title: 'BNB/USDT',
                  isExpanded: isExpanded,
                  subtitle: '\$315.50',
                  trailing: '+4.7%',
                  trailingColor: AppColors.buyGreen,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Bottom section
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: const Icon(
              LucideIcons.trendingUp,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('BanexCoin', style: AppTextStyles.h3)),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
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
            const SizedBox(height: AppSpacing.md),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => context.go(AppRouter.settings),
                icon: Icon(
                  LucideIcons.settings,
                  color: AppColors.textMuted,
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
                  color: AppColors.textMuted,
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
    this.isActive = false,
    this.subtitle,
    this.trailing,
    this.trailingColor,
  });

  final IconData icon;
  final String title;
  final bool isExpanded;
  final bool isActive;
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
            ? AppColors.primaryBlue.withOpacity(0.1)
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
                  color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
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
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                            fontWeight: isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                        if (subtitle != null)
                          Text(subtitle!, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    Text(
                      trailing!,
                      style: AppTextStyles.caption.copyWith(
                        color: trailingColor ?? AppColors.textMuted,
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
