import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({
    super.key,
    required this.onMenuPressed,
    required this.onThemeToggle,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.getSecondaryBackground(isDark),
            border: Border(
              bottom: BorderSide(
                color: AppColors.getBorderPrimary(isDark),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                IconButton(
                  onPressed: onMenuPressed,
                  icon: Icon(
                    LucideIcons.menu,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),

                const SizedBox(width: AppSpacing.lg),

                // Search bar
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(isDark),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: AppColors.getBorderPrimary(isDark),
                      ),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search pairs, markets...',
                        hintStyle: TextStyle(
                          color: AppColors.getTextMuted(isDark),
                        ),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          color: AppColors.getTextMuted(isDark),
                          size: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                      ),
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
                    color: AppColors.getSuccess(isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: AppColors.getSuccess(isDark).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.getSuccess(isDark),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Market Open',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.getSuccess(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Theme toggle
                IconButton(
                  onPressed: onThemeToggle,
                  icon: Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  tooltip: isDark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                ),

                // Notifications
                IconButton(
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                  icon: Stack(
                    children: [
                      Icon(
                        LucideIcons.bell,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.getError(isDark),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  tooltip: 'Notifications',
                ),

                // Settings
                IconButton(
                  onPressed: () {
                    // TODO: Implement quick settings
                  },
                  icon: Icon(
                    LucideIcons.settings,
                    color: AppColors.getTextMuted(isDark),
                  ),
                  tooltip: 'Settings',
                ),

                const SizedBox(width: AppSpacing.sm),

                // User menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        // TODO: Navigate to profile
                        break;
                      case 'settings':
                        // TODO: Navigate to settings
                        break;
                      case 'logout':
                        // TODO: Implement logout
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(LucideIcons.user, size: 16),
                          SizedBox(width: 8),
                          Text('Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(LucideIcons.settings, size: 16),
                          SizedBox(width: 8),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(LucideIcons.logOut, size: 16),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: AppColors.getBorderPrimary(isDark),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.getPrimaryBlue(isDark),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.user,
                            color: AppColors.getTextPrimary(isDark),
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          LucideIcons.chevronDown,
                          color: AppColors.getTextMuted(isDark),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
