import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class TradingChartTwoWidget extends StatefulWidget {
  const TradingChartTwoWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<TradingChartTwoWidget> createState() => _TradingChartTwoWidgetState();
}

class _TradingChartTwoWidgetState extends State<TradingChartTwoWidget> {
  late Timer _updateTimer;
  final Random _random = Random();

  List<FlSpot> _priceData = [];
  List<FlSpot> _volumeData = [];
  List<CandleData> _candleData = [];
  int _dataIndex = 0;

  ChartTimeframeTwo _selectedTimeframe = ChartTimeframeTwo.h1;
  ChartTypeTwo _selectedChartType = ChartTypeTwo.line;
  bool _showVolume = true;
  bool _showMA = false; // Moving Average

  double _minPrice = 0;
  double _maxPrice = 0;
  double _currentPrice = 0;

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

    // Generar datos históricos realistas
    for (int i = 0; i < 100; i++) {
      final variation = (_random.nextDouble() - 0.5) * 0.02; // ±1%
      final price = basePrice * (1 + variation + (sin(i * 0.1) * 0.01));
      final volume = 500000 + _random.nextDouble() * 2000000;

      _priceData.add(FlSpot(i.toDouble(), price));
      _volumeData.add(FlSpot(i.toDouble(), volume));

      // Generar datos de candlestick
      final open = i == 0 ? basePrice : _candleData.last.close;
      final close = price;
      final high = max(open, close) * (1 + _random.nextDouble() * 0.005);
      final low = min(open, close) * (1 - _random.nextDouble() * 0.005);

      _candleData.add(
        CandleData(
          x: i.toDouble(),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );
    }

    _updatePriceRange();
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
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _addNewDataPoint();
      }
    });
  }

  void _addNewDataPoint() {
    // Remover datos antiguos si hay demasiados
    if (_priceData.length >= 200) {
      _priceData.removeAt(0);
      _volumeData.removeAt(0);
      _candleData.removeAt(0);

      // Reindexar
      for (int i = 0; i < _priceData.length; i++) {
        _priceData[i] = FlSpot(i.toDouble(), _priceData[i].y);
        _volumeData[i] = FlSpot(i.toDouble(), _volumeData[i].y);
        _candleData[i] = CandleData(
          x: i.toDouble(),
          open: _candleData[i].open,
          high: _candleData[i].high,
          low: _candleData[i].low,
          close: _candleData[i].close,
          volume: _candleData[i].volume,
        );
      }
      _dataIndex = _priceData.length;
    }

    // Generar nuevo punto de datos
    final lastPrice = _priceData.isNotEmpty ? _priceData.last.y : _currentPrice;
    final priceChange = (_random.nextDouble() - 0.5) * 0.015; // ±0.75%
    final newPrice = lastPrice * (1 + priceChange);
    final newVolume = 500000 + _random.nextDouble() * 2000000;

    // Generar nueva vela
    final lastCandle = _candleData.isNotEmpty ? _candleData.last : null;
    final open = lastCandle?.close ?? newPrice;
    final close = newPrice;
    final high = max(open, close) * (1 + _random.nextDouble() * 0.003);
    final low = min(open, close) * (1 - _random.nextDouble() * 0.003);

    setState(() {
      _priceData.add(FlSpot(_dataIndex.toDouble(), newPrice));
      _volumeData.add(FlSpot(_dataIndex.toDouble(), newVolume));
      _candleData.add(
        CandleData(
          x: _dataIndex.toDouble(),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: newVolume,
        ),
      );

      _currentPrice = newPrice;
      _updatePriceRange();
      _dataIndex++;
    });
  }

  void _updatePriceRange() {
    if (_priceData.isNotEmpty) {
      _minPrice = _priceData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      _maxPrice = _priceData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.getBorderPrimary(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Cambiar a min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const Divider(height: 1),
              SizedBox(
                height: 400, // Altura fija para el gráfico
                child: _buildChart(isDark),
              ),
              if (_showVolume)
                SizedBox(height: 100, child: _buildVolumeChart(isDark)),
              _buildControls(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            LucideIcons.chartCandlestick,
            color: AppColors.getPrimaryBlue(isDark),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Price Chart',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.getSuccess(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(
                color: AppColors.getSuccess(isDark).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.getSuccess(isDark),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'LIVE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getSuccess(isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildChartControls(isDark),
        ],
      ),
    );
  }

  Widget _buildChartControls(bool isDark) {
    return Row(
      children: [
        _buildToggleButton(
          icon: LucideIcons.chartBar,
          label: 'Volume',
          isSelected: _showVolume,
          onTap: () => setState(() => _showVolume = !_showVolume),
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildToggleButton(
          icon: LucideIcons.chartLine,
          label: 'MA',
          isSelected: _showMA,
          onTap: () => setState(() => _showMA = !_showMA),
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildChartTypeSelector(isDark),
      ],
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getPrimaryBlue(isDark)
              : AppColors.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: isSelected
                ? AppColors.getPrimaryBlue(isDark)
                : AppColors.getBorderSecondary(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.getTextMuted(isDark),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppColors.getTextMuted(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChartTypeTwo.values.map((type) {
          final isSelected = type == _selectedChartType;
          return GestureDetector(
            onTap: () => setState(() => _selectedChartType = type),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
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

  IconData _getChartTypeIcon(ChartTypeTwo type) {
    switch (type) {
      case ChartTypeTwo.line:
        return LucideIcons.chartLine;
      case ChartTypeTwo.candle:
        return LucideIcons.chartCandlestick;
      case ChartTypeTwo.area:
        return LucideIcons.chartArea;
    }
  }

  Widget _buildChart(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: _selectedChartType == ChartTypeTwo.line
          ? _buildLineChart(isDark)
          : _selectedChartType == ChartTypeTwo.area
          ? _buildAreaChart(isDark)
          : _buildCandlestickChart(isDark),
    );
  }

  Widget _buildLineChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxPrice - _minPrice) / 6,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getBorderSecondary(isDark),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(isDark),
        borderData: FlBorderData(show: false),
        minX: _priceData.isNotEmpty ? _priceData.first.x : 0,
        maxX: _priceData.isNotEmpty ? _priceData.last.x : 100,
        minY: _minPrice * 0.998,
        maxY: _maxPrice * 1.002,
        lineBarsData: [
          LineChartBarData(
            spots: _priceData,
            isCurved: true,
            color: AppColors.getPrimaryBlue(isDark),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          if (_showMA) _buildMovingAverageLine(isDark),
        ],
        lineTouchData: _buildLineTouchData(isDark),
      ),
    );
  }

  Widget _buildAreaChart(bool isDark) {
    final isPositive =
        _priceData.isNotEmpty && _priceData.last.y > _priceData.first.y;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxPrice - _minPrice) / 6,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getBorderSecondary(isDark),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(isDark),
        borderData: FlBorderData(show: false),
        minX: _priceData.isNotEmpty ? _priceData.first.x : 0,
        maxX: _priceData.isNotEmpty ? _priceData.last.x : 100,
        minY: _minPrice * 0.998,
        maxY: _maxPrice * 1.002,
        lineBarsData: [
          LineChartBarData(
            spots: _priceData,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                isPositive
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                (isPositive
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
                  (isPositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.3),
                  (isPositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: _buildLineTouchData(isDark),
      ),
    );
  }

  Widget _buildCandlestickChart(bool isDark) {
    // Implementación simplificada de candlestick usando líneas
    List<LineChartBarData> candleBars = [];

    for (var candle in _candleData) {
      final isGreen = candle.close > candle.open;
      final color = isGreen
          ? AppColors.getBuyGreen(isDark)
          : AppColors.getSellRed(isDark);

      // Línea del cuerpo de la vela
      candleBars.add(
        LineChartBarData(
          spots: [
            FlSpot(candle.x, candle.open),
            FlSpot(candle.x, candle.close),
          ],
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      );

      // Línea de la mecha (high-low)
      candleBars.add(
        LineChartBarData(
          spots: [FlSpot(candle.x, candle.low), FlSpot(candle.x, candle.high)],
          color: color.withOpacity(0.7),
          barWidth: 1,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (_maxPrice - _minPrice) / 6,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getBorderSecondary(isDark),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(isDark),
        borderData: FlBorderData(show: false),
        minX: _candleData.isNotEmpty ? _candleData.first.x : 0,
        maxX: _candleData.isNotEmpty ? _candleData.last.x : 100,
        minY: _minPrice * 0.998,
        maxY: _maxPrice * 1.002,
        lineBarsData: candleBars,
        lineTouchData: _buildLineTouchData(isDark),
      ),
    );
  }

  LineChartBarData _buildMovingAverageLine(bool isDark) {
    // Calcular media móvil simple de 20 períodos
    List<FlSpot> maData = [];
    const period = 20;

    for (int i = period - 1; i < _priceData.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += _priceData[j].y;
      }
      double ma = sum / period;
      maData.add(FlSpot(_priceData[i].x, ma));
    }

    return LineChartBarData(
      spots: maData,
      isCurved: true,
      color: AppColors.getAccentYellow(isDark),
      barWidth: 1.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      dashArray: [5, 5], // Línea punteada
    );
  }

  FlTitlesData _buildTitlesData(bool isDark) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: (_priceData.length / 5).floorToDouble(),
          getTitlesWidget: (value, meta) {
            return Text(
              _formatTimeLabel(value.toInt()),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: (_maxPrice - _minPrice) / 5,
          reservedSize: 80,
          getTitlesWidget: (value, meta) {
            return Text(
              '\${value.toStringAsFixed(value >= 1000 ? 0 : 2)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _buildLineTouchData(bool isDark) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBorder: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              '\${spot.y.toStringAsFixed(_currentPrice >= 1 ? 2 : 4)}',
              TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          }).toList();
        },
      ),
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        // Manejar interacciones táctiles si es necesario
      },
      handleBuiltInTouches: true,
    );
  }

  String _formatTimeLabel(int index) {
    // Simular etiquetas de tiempo basadas en el timeframe seleccionado
    switch (_selectedTimeframe) {
      case ChartTimeframeTwo.m15:
        return '${(index * 15) % 60}m';
      case ChartTimeframeTwo.h1:
        return '${index % 24}h';
      case ChartTimeframeTwo.h4:
        return '${(index * 4) % 24}h';
      case ChartTimeframeTwo.d1:
        return '${index % 7}d';
      case ChartTimeframeTwo.w1:
        return '${index}w';
    }
  }

  Widget _buildVolumeChart(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _volumeData.isNotEmpty
              ? _volumeData.map((e) => e.y).reduce((a, b) => a > b ? a : b) *
                    1.1
              : 1000000,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: BorderSide(
                color: AppColors.getBorderPrimary(isDark),
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Volume: ${_formatVolume(rod.toY)}',
                  TextStyle(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _volumeData.asMap().entries.map((entry) {
            final index = entry.key;
            final volume = entry.value;
            final isGreen =
                index > 0 && _priceData[index].y > _priceData[index - 1].y;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: volume.y,
                  color:
                      (isGreen
                              ? AppColors.getBuyGreen(isDark)
                              : AppColors.getSellRed(isDark))
                          .withOpacity(0.7),
                  width: 2,
                  borderRadius: BorderRadius.circular(1),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _volumeData.isNotEmpty
                ? _volumeData.map((e) => e.y).reduce((a, b) => a > b ? a : b) /
                      3
                : 500000,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.getBorderSecondary(isDark),
              strokeWidth: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
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
        children: [
          Text(
            'Timeframe:',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ...ChartTimeframeTwo.values.map((timeframe) {
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
        ],
      ),
    );
  }

  String _getTimeframeLabel(ChartTimeframeTwo timeframe) {
    switch (timeframe) {
      case ChartTimeframeTwo.m15:
        return '15m';
      case ChartTimeframeTwo.h1:
        return '1h';
      case ChartTimeframeTwo.h4:
        return '4h';
      case ChartTimeframeTwo.d1:
        return '1d';
      case ChartTimeframeTwo.w1:
        return '1w';
    }
  }
}

class CandleData {
  final double x;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

enum ChartTimeframeTwo { m15, h1, h4, d1, w1 }

enum ChartTypeTwo { line, candle, area }
