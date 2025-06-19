import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PortfolioOverviewWidget extends StatelessWidget {
  const PortfolioOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.getBorderPrimary(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildMetrics(isDesktop, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Text(
          'Portfolio Overview',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.getBuyGreen(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.trendingUp,
                color: AppColors.getBuyGreen(isDark),
                size: 12,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '+2.36%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getBuyGreen(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetrics(bool isDesktop, bool isDark) {
    final metrics = [
      PortfolioMetricData(
        title: 'Total Balance',
        value: '\$12,243.55',
        subtitle: 'USD 12,243.55',
        change: '+\$132.23',
        changePercent: '+2.36%',
        isPositive: true,
        icon: LucideIcons.wallet,
      ),
      PortfolioMetricData(
        title: 'Today\'s P&L',
        value: '+\$485.22',
        subtitle: 'Unrealized',
        change: '+\$65.12',
        changePercent: '+15.5%',
        isPositive: true,
        icon: LucideIcons.trendingUp,
      ),
      PortfolioMetricData(
        title: 'Active Positions',
        value: '8',
        subtitle: '5 profitable',
        change: '+2',
        changePercent: '+33.3%',
        isPositive: true,
        icon: LucideIcons.chartPie,
      ),
      PortfolioMetricData(
        title: 'Available Balance',
        value: '\$3,456.78',
        subtitle: 'For trading',
        change: '-\$234.56',
        changePercent: '-6.3%',
        isPositive: false,
        icon: LucideIcons.dollarSign,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: metrics
            .map(
              (metric) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: metric == metrics.last ? 0 : AppSpacing.md,
                  ),
                  child: PortfolioMetricCard(metric: metric, isDark: isDark),
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PortfolioMetricCard(metric: metrics[0], isDark: isDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PortfolioMetricCard(metric: metrics[1], isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PortfolioMetricCard(metric: metrics[2], isDark: isDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PortfolioMetricCard(metric: metrics[3], isDark: isDark),
              ),
            ],
          ),
        ],
      );
    }
  }
}

class PortfolioMetricData {
  final String title;
  final String value;
  final String subtitle;
  final String change;
  final String changePercent;
  final bool isPositive;
  final IconData icon;

  PortfolioMetricData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.change,
    required this.changePercent,
    required this.isPositive,
    required this.icon,
  });
}

class PortfolioMetricCard extends StatelessWidget {
  const PortfolioMetricCard({
    super.key,
    required this.metric,
    required this.isDark,
  });

  final PortfolioMetricData metric;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryBlue(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  metric.icon,
                  color: AppColors.getPrimaryBlue(isDark),
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  metric.title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AutoSizeText(
            metric.value,
            style: AppTextStyles.priceMain.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
            maxLines: 1,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            metric.subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                metric.change,
                style: AppTextStyles.bodySmall.copyWith(
                  color: metric.isPositive
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                metric.changePercent,
                style: AppTextStyles.bodySmall.copyWith(
                  color: metric.isPositive
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
