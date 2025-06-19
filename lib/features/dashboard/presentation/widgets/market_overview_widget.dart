import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class MarketOverviewWidget extends StatefulWidget {
  const MarketOverviewWidget({super.key});

  @override
  State<MarketOverviewWidget> createState() => _MarketOverviewWidgetState();
}

class _MarketOverviewWidgetState extends State<MarketOverviewWidget> {
  late Timer _updateTimer;
  final Random _random = Random();

  final List<MarketStatData> _marketStats = [
    MarketStatData(
      title: 'Market Cap',
      value: '\$2.1T',
      change: '+2.3%',
      isPositive: true,
      baseValue: 2.1,
    ),
    MarketStatData(
      title: '24h Volume',
      value: '\$89.5B',
      change: '+5.7%',
      isPositive: true,
      baseValue: 89.5,
    ),
    MarketStatData(
      title: 'BTC Dominance',
      value: '52.4%',
      change: '-0.8%',
      isPositive: false,
      baseValue: 52.4,
    ),
  ];

  List<FlSpot> _chartData = [];
  int _chartDataIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateInitialChartData();
    _startUpdates();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _generateInitialChartData() {
    _chartData = List.generate(50, (index) {
      return FlSpot(
        index.toDouble(),
        2.0 + (_random.nextDouble() * 0.4), // Entre 2.0 y 2.4
      );
    });
    _chartDataIndex = 50;
  }

  void _startUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _updateMarketStats();
          _updateChartData();
        });
      }
    });
  }

  void _updateMarketStats() {
    for (var stat in _marketStats) {
      double changePercent = (_random.nextDouble() - 0.5) * 0.02; // ±1%
      stat.baseValue = stat.baseValue * (1 + changePercent);

      if (stat.title == 'Market Cap') {
        stat.value = '\${stat.baseValue.toStringAsFixed(1)}T';
      } else if (stat.title == '24h Volume') {
        stat.value = '\${stat.baseValue.toStringAsFixed(1)}B';
      } else {
        stat.value = '${stat.baseValue.toStringAsFixed(1)}%';
      }

      // Simular cambios en porcentaje
      double newChange = (_random.nextDouble() - 0.5) * 10; // ±5%
      stat.isPositive = newChange >= 0;
      stat.change =
          '${newChange >= 0 ? '+' : ''}${newChange.toStringAsFixed(1)}%';
    }
  }

  void _updateChartData() {
    if (_chartData.length >= 100) {
      _chartData.removeAt(0);
      for (int i = 0; i < _chartData.length; i++) {
        _chartData[i] = FlSpot(i.toDouble(), _chartData[i].y);
      }
      _chartDataIndex = _chartData.length;
    }

    double lastValue = _chartData.isNotEmpty ? _chartData.last.y : 2.1;
    double newValue = lastValue + (_random.nextDouble() - 0.5) * 0.1;
    newValue = newValue.clamp(1.5, 3.0); // Mantener en rango realista

    _chartData.add(FlSpot(_chartDataIndex.toDouble(), newValue));
    _chartDataIndex++;
  }

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
              Text(
                'Market Overview',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildMarketStats(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildChart(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarketStats(bool isDark) {
    return Row(
      children: _marketStats
          .map(
            (stat) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: stat == _marketStats.last ? 0 : AppSpacing.md,
                ),
                child: MarketStatCard(stat: stat, isDark: isDark),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChart(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.2,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.getBorderSecondary(isDark),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 0.4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\${value.toStringAsFixed(1)}T',
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
            minX: _chartData.isNotEmpty ? _chartData.first.x : 0,
            maxX: _chartData.isNotEmpty ? _chartData.last.x : 50,
            minY: 1.5,
            maxY: 3.0,
            lineBarsData: [
              LineChartBarData(
                spots: _chartData,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.getPrimaryBlue(isDark),
                    AppColors.getPrimaryBlue(isDark).withOpacity(0.7),
                  ],
                ),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.getPrimaryBlue(isDark).withOpacity(0.1),
                      AppColors.getPrimaryBlue(isDark).withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBorder: BorderSide(
                  color: AppColors.getBorderPrimary(isDark),
                ),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '\${spot.y.toStringAsFixed(2)}T',
                      TextStyle(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarketStatData {
  final String title;
  String value;
  String change;
  bool isPositive;
  double baseValue;

  MarketStatData({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.baseValue,
  });
}

class MarketStatCard extends StatelessWidget {
  const MarketStatCard({super.key, required this.stat, required this.isDark});

  final MarketStatData stat;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stat.value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              stat.isPositive
                  ? LucideIcons.trendingUp
                  : LucideIcons.trendingDown,
              size: 12,
              color: stat.isPositive
                  ? AppColors.getBuyGreen(isDark)
                  : AppColors.getSellRed(isDark),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              stat.change,
              style: AppTextStyles.bodySmall.copyWith(
                color: stat.isPositive
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
