import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/features/dashboard/presentation/widgets/widgets.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return Container(
          color: AppColors.getPrimaryBackground(isDark),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: AppSpacing.xl),
                PortfolioOverviewWidget(),
                const SizedBox(height: AppSpacing.xl),
                _buildMainContent(isDesktop),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trading Dashboard',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Monitor your portfolio and market trends',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.getPrimaryBlue(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: AppColors.getTextPrimary(!isDark),
                size: 16,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add to Watchlist',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.getTextPrimary(!isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    return ResponsiveRowColumn(
      layout: isDesktop
          ? ResponsiveRowColumnType.ROW
          : ResponsiveRowColumnType.COLUMN,
      rowSpacing: AppSpacing.lg,
      columnSpacing: AppSpacing.lg,
      children: [
        ResponsiveRowColumnItem(
          rowFlex: 2,
          child: Column(
            children: [
              const TradingPairsWidget(),
              const SizedBox(height: AppSpacing.lg),
              const MarketOverviewWidget(),
            ],
          ),
        ),
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Column(
            children: [
              const RecentActivitiesWidget(),
              const SizedBox(height: AppSpacing.lg),
              const PriceAlertsWidget(),
            ],
          ),
        ),
      ],
    );
  }
}
