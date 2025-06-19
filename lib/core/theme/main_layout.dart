import 'package:flutter/material.dart';

import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/theme/theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, required this.body, required this.currentIndex});

  final Widget body;
  final int currentIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
      return _MobileLayout(
        body: widget.body,
        currentIndex: widget.currentIndex,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarExpanded ? 280 : 80,
            child: _Sidebar(
              isExpanded: _isSidebarExpanded,
              currentIndex: widget.currentIndex,
              onToggle: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                _TopBar(
                  onMenuPressed: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),

                // Body
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: widget.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.isExpanded,
    required this.currentIndex,
    required this.onToggle,
  });

  final bool isExpanded;
  final int currentIndex;
  final VoidCallback onToggle;

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
          Container(
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
          ),

          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                _SidebarItem(
                  icon: LucideIcons.layoutDashboard,
                  title: 'Dashboard',
                  isActive: currentIndex == 0,
                  isExpanded: isExpanded,
                  onTap: () {
                    // Navigate to dashboard
                  },
                ),
                _SidebarItem(
                  icon: LucideIcons.chartCandlestick,
                  title: 'Trading Pairs',
                  isActive: currentIndex == 1,
                  isExpanded: isExpanded,
                  onTap: () {
                    // Navigate to trading pairs
                  },
                ),
                _SidebarItem(
                  icon: LucideIcons.bookOpen,
                  title: 'Order Book',
                  isActive: currentIndex == 2,
                  isExpanded: isExpanded,
                  onTap: () {
                    // Navigate to order book
                  },
                ),
                _SidebarItem(
                  icon: LucideIcons.calculator,
                  title: 'Calculator',
                  isActive: currentIndex == 3,
                  isExpanded: isExpanded,
                  onTap: () {
                    // Navigate to calculator
                  },
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
              ],
            ),
          ),

          // Bottom section
          Container(
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
                              Text(
                                'Premium User',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isExpanded
                        ? LucideIcons.panelLeftClose
                        : LucideIcons.panelLeftOpen,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.borderPrimary, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(LucideIcons.menu, color: AppColors.textMuted),
            ),

            const SizedBox(width: AppSpacing.lg),

            // Search bar
            Expanded(
              flex: 2,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search pairs, markets...',
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),

            const Spacer(),

            // Market status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Market Open',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Notifications
            IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.bell, color: AppColors.textMuted),
            ),

            // Settings
            IconButton(
              onPressed: () {},
              icon: const Icon(
                LucideIcons.settings,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.body, required this.currentIndex});

  final Widget body;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('BanexCoin'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.search)),
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell)),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: body),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondaryBackground,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: currentIndex,
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
    );
  }
}
