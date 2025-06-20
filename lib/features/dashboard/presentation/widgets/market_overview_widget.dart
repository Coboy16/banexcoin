import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '/features/dashboard/domain/entities/entities.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

class MarketOverviewWidget extends StatelessWidget {
  final MarketDataState? marketState;

  const MarketOverviewWidget({super.key, this.marketState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
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
              _buildContent(isDark),
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
          'Market Overview',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const Spacer(),
        if (marketState is MarketDataLoaded) _buildLastUpdated(isDark),
      ],
    );
  }

  Widget _buildLastUpdated(bool isDark) {
    final state = marketState as MarketDataLoaded;
    final lastUpdated = state.lastUpdated;
    final timeDiff = DateTime.now().difference(lastUpdated);

    String timeText;
    if (timeDiff.inMinutes < 1) {
      timeText = 'Just now';
    } else if (timeDiff.inMinutes < 60) {
      timeText = '${timeDiff.inMinutes}m ago';
    } else {
      timeText = '${timeDiff.inHours}h ago';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.clock,
            size: 12,
            color: AppColors.getTextMuted(isDark),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Updated $timeText',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (marketState is MarketDataLoading) {
      return _buildLoadingState(isDark);
    } else if (marketState is MarketDataLoaded) {
      return _buildLoadedState(marketState as MarketDataLoaded, isDark);
    } else if (marketState is MarketDataError) {
      return _buildErrorState(marketState as MarketDataError, isDark);
    } else {
      return _buildInitialState(isDark);
    }
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        _buildMarketStatsLoading(isDark),
        const SizedBox(height: AppSpacing.lg),
        _buildChartLoading(isDark),
      ],
    );
  }

  Widget _buildMarketStatsLoading(bool isDark) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? AppSpacing.md : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChartLoading(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.getPrimaryBlue(isDark),
        ),
      ),
    );
  }

  Widget _buildLoadedState(MarketDataLoaded state, bool isDark) {
    return Column(
      children: [
        _buildMarketStats(state, isDark),
        const SizedBox(height: AppSpacing.lg),
        _buildChart(state, isDark),
      ],
    );
  }

  Widget _buildMarketStats(MarketDataLoaded state, bool isDark) {
    final statistics = state.marketStatistics;
    final tickers = state.tickers.values.toList();

    // Calcular estadísticas en tiempo real si no tenemos desde la API
    final realTimeStats = _calculateRealTimeStats(tickers, statistics);

    return Row(
      children: [
        Expanded(
          child: MarketStatRealCard(
            title: 'Total Volume (24h)',
            value: realTimeStats['totalVolume'] as String,
            change: realTimeStats['volumeChange'] as String,
            isPositive: realTimeStats['volumeChangePositive'] as bool,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: MarketStatRealCard(
            title: 'Gainers',
            value: '${realTimeStats['gainers']} pairs',
            change: '${realTimeStats['gainersPercent']}%',
            isPositive: true,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: MarketStatRealCard(
            title: 'Losers',
            value: '${realTimeStats['losers']} pairs',
            change: '${realTimeStats['losersPercent']}%',
            isPositive: false,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateRealTimeStats(
    List<TickerEntity> tickers,
    MarketStatistics? statistics,
  ) {
    if (tickers.isEmpty) {
      return {
        'totalVolume': '\$0.00',
        'volumeChange': '+0.0%',
        'volumeChangePositive': true,
        'gainers': 0,
        'losers': 0,
        'gainersPercent': '0.0',
        'losersPercent': '0.0',
      };
    }

    // Calcular volumen total
    double totalVolume = 0;
    int gainers = 0;
    int losers = 0;

    for (final ticker in tickers) {
      final volume = double.tryParse(ticker.quoteVolume) ?? 0;
      totalVolume += volume;

      if (ticker.isPriceChangePositive) {
        gainers++;
      } else {
        losers++;
      }
    }

    final gainersPercent = ((gainers / tickers.length) * 100).toStringAsFixed(
      1,
    );
    final losersPercent = ((losers / tickers.length) * 100).toStringAsFixed(1);

    String volumeText;
    if (totalVolume >= 1000000000) {
      volumeText = '\$${(totalVolume / 1000000000).toStringAsFixed(2)}B';
    } else if (totalVolume >= 1000000) {
      volumeText = '\$${(totalVolume / 1000000).toStringAsFixed(2)}M';
    } else {
      volumeText = '\$${totalVolume.toStringAsFixed(2)}';
    }

    return {
      'totalVolume': volumeText,
      'volumeChange': '+2.5%', // Placeholder - en producción calcular real
      'volumeChangePositive': true,
      'gainers': gainers,
      'losers': losers,
      'gainersPercent': gainersPercent,
      'losersPercent': losersPercent,
    };
  }

  Widget _buildChart(MarketDataLoaded state, bool isDark) {
    final topGainers = state.getTopGainers(limit: 5);

    if (topGainers.isEmpty) {
      return _buildChartEmpty(isDark);
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performers (24h)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxChange(topGainers),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorder: BorderSide(
                        color: AppColors.getBorderPrimary(isDark),
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${topGainers[group.x.toInt()].symbol}\n${rod.toY.toStringAsFixed(2)}%',
                          TextStyle(
                            color: AppColors.getTextPrimary(isDark),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < topGainers.length) {
                            final symbol = topGainers[value.toInt()].symbol;
                            return Text(
                              symbol.length > 7
                                  ? symbol.substring(0, 7)
                                  : symbol,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.getTextMuted(isDark),
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getMaxChange(topGainers) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}%',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.getTextMuted(isDark),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topGainers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ticker = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: ticker.priceChangePercentAsDouble,
                          color: AppColors.getBuyGreen(isDark),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxChange(List<TickerEntity> tickers) {
    if (tickers.isEmpty) return 10.0;
    final maxChange = tickers
        .map((t) => t.priceChangePercentAsDouble)
        .reduce((a, b) => a > b ? a : b);
    return (maxChange * 1.2).clamp(5.0, double.infinity);
  }

  Widget _buildChartEmpty(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.chartBar,
              color: AppColors.getTextMuted(isDark),
              size: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No data available for chart',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(MarketDataError error, bool isDark) {
    return Column(
      children: [
        Icon(
          LucideIcons.triangleAlert,
          color: AppColors.getError(isDark),
          size: 48,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Failed to load market overview',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          error.friendlyMessage,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Column(
      children: [
        Icon(
          LucideIcons.trendingUp,
          color: AppColors.getTextMuted(isDark),
          size: 48,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Initialize market data to see overview',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.getTextMuted(isDark),
          ),
        ),
      ],
    );
  }
}

class MarketStatRealCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final bool isDark;

  const MarketStatRealCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
              size: 12,
              color: isPositive
                  ? AppColors.getBuyGreen(isDark)
                  : AppColors.getSellRed(isDark),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              change,
              style: AppTextStyles.bodySmall.copyWith(
                color: isPositive
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
