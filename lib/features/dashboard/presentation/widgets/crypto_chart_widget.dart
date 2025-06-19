import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class CryptoChartWidget extends StatefulWidget {
  const CryptoChartWidget({
    super.key,
    required this.symbol,
    this.height = 300,
    this.showControls = true,
  });

  final String symbol;
  final double height;
  final bool showControls;

  @override
  State<CryptoChartWidget> createState() => _CryptoChartWidgetState();
}

class _CryptoChartWidgetState extends State<CryptoChartWidget> {
  late Timer _updateTimer;
  final Random _random = Random();

  List<FlSpot> _chartData = [];
  List<FlSpot> _volumeData = [];
  int _dataIndex = 0;

  ChartTimeframe _selectedTimeframe = ChartTimeframe.h1;
  ChartType _selectedChartType = ChartType.line;

  double _minPrice = 0;
  double _maxPrice = 0;
  double _currentPrice = 0;
  double _priceChange = 0;
  bool _isPricePositive = true;

  @override
  void initState() {
    super.initState();
    _generateInitialData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _generateInitialData() {
    final basePrice = _getBasePriceForSymbol(widget.symbol);
    _currentPrice = basePrice;

    _chartData = List.generate(100, (index) {
      final variation = (_random.nextDouble() - 0.5) * 0.1;
      final price = basePrice * (1 + variation);
      return FlSpot(index.toDouble(), price);
    });

    _volumeData = List.generate(100, (index) {
      final volume = 500000 + _random.nextDouble() * 2000000;
      return FlSpot(index.toDouble(), volume);
    });

    _updatePriceStats();
    _dataIndex = 100;
  }

  double _getBasePriceForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC/USDT':
        return 43250.0;
      case 'ETH/USDT':
        return 2650.0;
      case 'BNB/USDT':
        return 315.0;
      case 'ADA/USDT':
        return 0.485;
      default:
        return 1000.0;
    }
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _addNewDataPoint();
      }
    });
  }

  void _addNewDataPoint() {
    // Remover datos antiguos si hay demasiados
    if (_chartData.length >= 200) {
      _chartData.removeAt(0);
      _volumeData.removeAt(0);

      // Reindexar los datos
      for (int i = 0; i < _chartData.length; i++) {
        _chartData[i] = FlSpot(i.toDouble(), _chartData[i].y);
        _volumeData[i] = FlSpot(i.toDouble(), _volumeData[i].y);
      }
      _dataIndex = _chartData.length;
    }

    // Generar nuevo precio realista
    final lastPrice = _chartData.isNotEmpty ? _chartData.last.y : _currentPrice;
    final priceChange = (_random.nextDouble() - 0.5) * 0.02; // ±1%
    final newPrice = lastPrice * (1 + priceChange);

    // Generar nuevo volumen
    final newVolume = 500000 + _random.nextDouble() * 2000000;

    setState(() {
      _chartData.add(FlSpot(_dataIndex.toDouble(), newPrice));
      _volumeData.add(FlSpot(_dataIndex.toDouble(), newVolume));
      _currentPrice = newPrice;
      _updatePriceStats();
      _dataIndex++;
    });
  }

  void _updatePriceStats() {
    if (_chartData.isNotEmpty) {
      _minPrice = _chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      _maxPrice = _chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

      if (_chartData.length > 1) {
        final firstPrice = _chartData.first.y;
        _priceChange = _currentPrice - firstPrice;
        _isPricePositive = _priceChange >= 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.getBorderPrimary(isDark)),
          ),
          child: Column(
            children: [
              if (widget.showControls) _buildHeader(isDark),
              Expanded(child: _buildChart(isDark)),
              if (widget.showControls) _buildControls(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text(
            widget.symbol,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '\$${_currentPrice.toStringAsFixed(_currentPrice >= 1 ? 2 : 4)}',
            style: AppTextStyles.priceMain.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color:
                  (_isPricePositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPricePositive
                      ? LucideIcons.trendingUp
                      : LucideIcons.trendingDown,
                  size: 12,
                  color: _isPricePositive
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${_isPricePositive ? '+' : ''}\$${_priceChange.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _isPricePositive
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildChartTypeToggle(isDark),
        ],
      ),
    );
  }

  Widget _buildChartTypeToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChartType.values.map((type) {
          final isSelected = type == _selectedChartType;
          return GestureDetector(
            onTap: () => setState(() => _selectedChartType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.getPrimaryBlue(isDark)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Icon(
                _getChartTypeIcon(type),
                size: 16,
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextMuted(isDark),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getChartTypeIcon(ChartType type) {
    switch (type) {
      case ChartType.line:
        return LucideIcons.chartLine;
      case ChartType.candle:
        return LucideIcons.chartCandlestick;
      case ChartType.area:
        return LucideIcons.chartArea;
    }
  }

  Widget _buildChart(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: _selectedChartType == ChartType.line
          ? _buildLineChart(isDark)
          : _selectedChartType == ChartType.area
          ? _buildAreaChart(isDark)
          : _buildCandleChart(isDark),
    );
  }

  Widget _buildLineChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxPrice - _minPrice) / 5,
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
              interval: (_maxPrice - _minPrice) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(value >= 1000 ? 0 : 2)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextMuted(isDark),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: _chartData.isNotEmpty ? _chartData.first.x : 0,
        maxX: _chartData.isNotEmpty ? _chartData.last.x : 100,
        minY: _minPrice * 0.995,
        maxY: _maxPrice * 1.005,
        lineBarsData: [
          LineChartBarData(
            spots: _chartData,
            isCurved: true,
            color: _isPricePositive
                ? AppColors.getBuyGreen(isDark)
                : AppColors.getSellRed(isDark),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
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
                  '\$${spot.y.toStringAsFixed(_currentPrice >= 1 ? 2 : 4)}',
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
    );
  }

  Widget _buildAreaChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxPrice - _minPrice) / 5,
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
              interval: (_maxPrice - _minPrice) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(value >= 1000 ? 0 : 2)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextMuted(isDark),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: _chartData.isNotEmpty ? _chartData.first.x : 0,
        maxX: _chartData.isNotEmpty ? _chartData.last.x : 100,
        minY: _minPrice * 0.995,
        maxY: _maxPrice * 1.005,
        lineBarsData: [
          LineChartBarData(
            spots: _chartData,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                _isPricePositive
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                (_isPricePositive
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark))
                    .withOpacity(0.7),
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
                  (_isPricePositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.3),
                  (_isPricePositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandleChart(bool isDark) {
    // Para simplificar, mostraremos el gráfico de línea con un estilo diferente
    // En una implementación real, usarías CandlestickChart
    return _buildLineChart(isDark);
  }

  Widget _buildControls(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Row(
        children: ChartTimeframe.values.map((timeframe) {
          final isSelected = timeframe == _selectedTimeframe;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeframe = timeframe),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.getPrimaryBlue(isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.getPrimaryBlue(isDark)
                        : AppColors.getBorderSecondary(isDark),
                  ),
                ),
                child: Text(
                  _getTimeframeLabel(timeframe),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.getTextSecondary(isDark),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTimeframeLabel(ChartTimeframe timeframe) {
    switch (timeframe) {
      case ChartTimeframe.m15:
        return '15m';
      case ChartTimeframe.h1:
        return '1h';
      case ChartTimeframe.h4:
        return '4h';
      case ChartTimeframe.d1:
        return '1d';
      case ChartTimeframe.w1:
        return '1w';
    }
  }
}

enum ChartTimeframe { m15, h1, h4, d1, w1 }

enum ChartType { line, candle, area }
