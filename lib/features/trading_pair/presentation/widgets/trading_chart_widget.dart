import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';
import '/features/trading_pair/domain/entities/entities.dart';

class TradingChartTwoWidget extends StatefulWidget {
  const TradingChartTwoWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<TradingChartTwoWidget> createState() => _TradingChartTwoWidgetState();
}

class _TradingChartTwoWidgetState extends State<TradingChartTwoWidget> {
  ChartTimeframeTwo _selectedTimeframe = ChartTimeframeTwo.h1;
  ChartTypeTwo _selectedChartType = ChartTypeTwo.line;
  bool _showVolume = true;
  bool _showMA = false;
  bool _isTimeframeLoading = false;

  static const double _kVisibleCandleCount = 100.0;

  List<FlSpot> _priceData = [];
  List<FlSpot> _volumeData = [];
  double _minPrice = 0;
  double _maxPrice = 0;
  final SplayTreeMap<int, KlineEntity> _localKlines =
      SplayTreeMap<int, KlineEntity>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return BlocConsumer<TradingPairBloc, TradingPairState>(
          listener: (context, state) {
            if (state is TradingPairLoaded) {
              _updateChartData(state);
            }
          },
          builder: (context, state) {
            if (state is TradingPairLoaded) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(color: AppColors.getBorderPrimary(isDark)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDark, state.isStreaming, isDesktop),
                    const Divider(height: 1),
                    SizedBox(
                      height: 400,
                      child: _buildChart(isDark, state, isDesktop),
                    ),
                    if (_showVolume)
                      SizedBox(
                        height: 100,
                        child: _buildVolumeChart(isDark, state),
                      ),
                    _buildControls(isDark, isDesktop),
                  ],
                ),
              );
            }
            return _buildLoadingState(isDark);
          },
        );
      },
    );
  }

  void _updateChartData(TradingPairLoaded state) {
    if (state.klines.isEmpty) return;

    bool isFullRefresh = state.klines.length > 2;

    if (isFullRefresh) {
      _localKlines.clear();
      for (var kline in state.klines) {
        _localKlines[kline.openTime.millisecondsSinceEpoch] = kline;
      }
    } else {
      for (var kline in state.klines) {
        _localKlines[kline.openTime.millisecondsSinceEpoch] = kline;
      }
    }

    if (_localKlines.isEmpty) {
      if (mounted) setState(() => _isTimeframeLoading = false);
      return;
    }

    final klinesForChart = _localKlines.values.toList();
    final newPriceData = <FlSpot>[];
    final newVolumeData = <FlSpot>[];

    for (int i = 0; i < klinesForChart.length; i++) {
      final kline = klinesForChart[i];
      newPriceData.add(FlSpot(i.toDouble(), kline.closePrice));
      newVolumeData.add(FlSpot(i.toDouble(), kline.quoteVolume));
    }

    if (newPriceData.isEmpty) {
      if (mounted) setState(() => _isTimeframeLoading = false);
      return;
    }

    final newMinPrice = newPriceData
        .map((e) => e.y)
        .reduce((a, b) => a < b ? a : b);
    final newMaxPrice = newPriceData
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);

    if (mounted) {
      setState(() {
        _priceData = newPriceData;
        _volumeData = newVolumeData;
        _minPrice = newMinPrice;
        _maxPrice = newMaxPrice;
        _isTimeframeLoading = false;
      });
    }
  }

  // =================================================================
  // INICIO MODIFICACIÓN: Cabecera responsiva
  // =================================================================
  Widget _buildHeader(bool isDark, bool isStreaming, bool isDesktop) {
    final titleWidget = Row(
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
            color: isStreaming
                ? AppColors.getSuccess(isDark).withOpacity(0.1)
                : AppColors.getWarning(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(
              color: isStreaming
                  ? AppColors.getSuccess(isDark).withOpacity(0.3)
                  : AppColors.getWarning(isDark).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isStreaming
                      ? AppColors.getSuccess(isDark)
                      : AppColors.getWarning(isDark),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isStreaming ? 'LIVE' : 'OFFLINE',
                style: AppTextStyles.caption.copyWith(
                  color: isStreaming
                      ? AppColors.getSuccess(isDark)
                      : AppColors.getWarning(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );

    if (isDesktop) {
      // VISTA WEB/DESKTOP: Fila única
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: titleWidget),
            _buildChartControls(isDark),
          ],
        ),
      );
    } else {
      // VISTA MÓVIL: Columna
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget,
            const SizedBox(height: AppSpacing.md),
            _buildChartControls(isDark),
          ],
        ),
      );
    }
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
      case ChartTypeTwo.area:
        return LucideIcons.chartArea;
    }
  }

  Widget _buildChart(bool isDark, TradingPairLoaded state, bool isDesktop) {
    if (_isTimeframeLoading)
      return const Center(child: CircularProgressIndicator());

    if (_priceData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.chartLine,
              size: 48,
              color: AppColors.getTextMuted(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No chart data available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      );
    }

    final chartWidget = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: _selectedChartType == ChartTypeTwo.line
          ? _buildLineChart(isDark, state, isDesktop)
          : _selectedChartType == ChartTypeTwo.area
          ? _buildAreaChart(isDark, state, isDesktop)
          : _buildCandlestickChart(isDark, state, isDesktop),
    );

    if (isDesktop) {
      return chartWidget;
    } else {
      // VISTA MÓVIL: Añadir InteractiveViewer para zoom y pan
      return InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.5,
        maxScale: 4.0,
        child: chartWidget,
      );
    }
  }

  Widget _buildLineChart(bool isDark, TradingPairLoaded state, bool isDesktop) {
    final isPositive =
        _priceData.isNotEmpty && _priceData.last.y > _priceData.first.y;
    final priceRange = _maxPrice - _minPrice;
    final horizontalInterval = priceRange > 0 ? priceRange / 6 : 1.0;

    final double lastX = _priceData.isNotEmpty ? _priceData.last.x : 0.0;
    // MODIFICACIÓN: Rango del eje X diferente para móvil (zoom) y web (scroll)
    final double minX = isDesktop
        ? max(0.0, lastX - (_kVisibleCandleCount - 1))
        : 0.0;
    final double maxX = lastX;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getBorderSecondary(isDark),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(isDark, state),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: _minPrice > 0 ? _minPrice * 0.998 : _minPrice - 1,
        maxY: _maxPrice > 0 ? _maxPrice * 1.002 : _maxPrice + 1,
        lineBarsData: [
          LineChartBarData(
            spots: _priceData,
            isCurved: true,
            color: isPositive
                ? AppColors.getBuyGreen(isDark)
                : AppColors.getSellRed(isDark),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          if (_showMA && _priceData.length >= 20)
            _buildMovingAverageLine(isDark),
        ],
        lineTouchData: _buildLineTouchData(isDark, state),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildAreaChart(bool isDark, TradingPairLoaded state, bool isDesktop) {
    final isPositive =
        _priceData.isNotEmpty && _priceData.last.y > _priceData.first.y;
    final priceRange = _maxPrice - _minPrice;
    final horizontalInterval = priceRange > 0 ? priceRange / 6 : 1.0;

    final double lastX = _priceData.isNotEmpty ? _priceData.last.x : 0.0;
    // MODIFICACIÓN: Rango del eje X diferente para móvil (zoom) y web (scroll)
    final double minX = isDesktop
        ? max(0.0, lastX - (_kVisibleCandleCount - 1))
        : 0.0;
    final double maxX = lastX;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getBorderSecondary(isDark),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(isDark, state),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: _minPrice > 0 ? _minPrice * 0.998 : _minPrice - 1,
        maxY: _maxPrice > 0 ? _maxPrice * 1.002 : _maxPrice + 1,
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
        lineTouchData: _buildLineTouchData(isDark, state),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildCandlestickChart(
    bool isDark,
    TradingPairLoaded state,
    bool isDesktop,
  ) {
    final klines = _localKlines.values.toList();
    List<CandleStickChartBarData> candleBars = [];
    for (int i = 0; i < klines.length; i++) {
      final kline = klines[i];
      candleBars.add(
        CandleStickChartBarData(
          x: i.toDouble(),
          data: CandleStickChartCandleData(
            open: kline.openPrice,
            high: kline.highPrice,
            low: kline.lowPrice,
            close: kline.closePrice,
          ),
        ),
      );
    }
    final priceRange = _maxPrice - _minPrice;
    final horizontalInterval = priceRange > 0 ? priceRange / 6 : 1.0;

    final double lastX = klines.isNotEmpty
        ? (klines.length - 1).toDouble()
        : 0.0;
    // MODIFICACIÓN: Rango del eje X diferente para móvil (zoom) y web (scroll)
    final double minX = isDesktop
        ? max(0.0, lastX - (_kVisibleCandleCount - 1))
        : 0.0;
    final double maxX = lastX;

    return CandleStickChart(
      CandleStickChartData(
        minX: minX,
        maxX: maxX,
        candleTouchData: CandleStickChartTouchData(
          touchTooltipData: CandleStickChartTouchTooltipData(
            tooltipBgColor: AppColors.getCardBackground(isDark),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getBorderSecondary(isDark),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(isDark, state),
        borderData: FlBorderData(show: false),
        minY: _minPrice > 0 ? _minPrice * 0.998 : _minPrice - 1,
        maxY: _maxPrice > 0 ? _maxPrice * 1.002 : _maxPrice + 1,
        candlesData: candleBars,
      ),
    );
  }

  LineChartBarData _buildMovingAverageLine(bool isDark) {
    List<FlSpot> maData = [];
    const period = 20;
    if (_priceData.length < period)
      return LineChartBarData(spots: [], color: Colors.transparent);
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
      dashArray: [5, 5],
    );
  }

  FlTitlesData _buildTitlesData(bool isDark, TradingPairLoaded state) {
    final dataLength = _priceData.length;
    final interval = dataLength > 10 ? (dataLength / 5).floorToDouble() : 2.0;
    final priceRange = _maxPrice - _minPrice;
    final priceInterval = priceRange > 0 ? priceRange / 5 : 1.0;
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: interval,
          getTitlesWidget: (value, meta) => Text(
            _formatTimeLabel(value.toInt()),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: priceInterval,
          reservedSize: 80,
          getTitlesWidget: (value, meta) => Text(
            '\$${value.toStringAsFixed(value >= 1000 ? 0 : 2)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ),
      ),
    );
  }

  LineTouchData _buildLineTouchData(bool isDark, TradingPairLoaded state) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBorder: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        getTooltipItems: (touchedSpots) => touchedSpots
            .map(
              (spot) => LineTooltipItem(
                '\$${spot.y.toStringAsFixed(spot.y >= 1 ? 2 : 4)}',
                TextStyle(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
            .toList(),
      ),
      handleBuiltInTouches: true,
    );
  }

  String _formatTimeLabel(int index) {
    if (index < 0 || index >= _localKlines.length) return '';
    final kline = _localKlines.values.elementAt(index);
    final time = kline.openTime;
    switch (_selectedTimeframe) {
      case ChartTimeframeTwo.m15:
      case ChartTimeframeTwo.h1:
      case ChartTimeframeTwo.h4:
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      case ChartTimeframeTwo.d1:
        return '${time.day}/${time.month}';
      case ChartTimeframeTwo.w1:
        return 'W${(time.day / 7).ceil()}';
    }
  }

  Widget _buildVolumeChart(bool isDark, TradingPairLoaded state) {
    if (_volumeData.isEmpty) return const SizedBox.shrink();
    final maxVolume = _volumeData
        .map((e) => e.y)
        .reduce((a, b) => a > b ? a : b);
    final volumeInterval = maxVolume > 0 ? maxVolume / 3 : 1000000.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVolume * 1.1,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: BorderSide(
                color: AppColors.getBorderPrimary(isDark),
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    'Volume: ${_formatVolume(rod.toY)}',
                    TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _volumeData.asMap().entries.map((entry) {
            final index = entry.key;
            final volume = entry.value;
            final isGreen =
                index > 0 &&
                index < _priceData.length &&
                _priceData[index].y > _priceData[index - 1].y;
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
            horizontalInterval: volumeInterval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.getBorderSecondary(isDark),
              strokeWidth: 0.5,
            ),
          ),
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000)
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    if (volume >= 1000000) return '${(volume / 1000000).toStringAsFixed(1)}M';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}K';
    return volume.toStringAsFixed(0);
  }

  Widget _buildControls(bool isDark, bool isDesktop) {
    final timeframeButtons = ChartTimeframeTwo.values.map((timeframe) {
      final isSelected = timeframe == _selectedTimeframe;
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: GestureDetector(
          onTap: () {
            if (_isTimeframeLoading) return;
            setState(() {
              _selectedTimeframe = timeframe;
              _isTimeframeLoading = true;
            });
            context.read<TradingPairBloc>().add(
              ChangeKlineInterval(interval: _getTimeframeInterval(timeframe)),
            );
          },
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: isDesktop
          ? Row(
              children: [
                Text(
                  'Timeframe:',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ...timeframeButtons,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeframe:',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: timeframeButtons),
                ),
              ],
            ),
    );
  }
  // =================================================================
  // FIN MODIFICACIÓN
  // =================================================================

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

  String _getTimeframeInterval(ChartTimeframeTwo timeframe) {
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

  Widget _buildLoadingState(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
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
                const Spacer(),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading chart data...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.getTextMuted(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ChartTimeframeTwo { m15, h1, h4, d1, w1 }

enum ChartTypeTwo { line, area }

// Placeholder para CandleStickChart
class CandleStickChart extends StatelessWidget {
  final CandleStickChartData data;
  const CandleStickChart(this.data, {super.key});
  @override
  Widget build(BuildContext context) =>
      const Placeholder(child: Text('CandleStickChart'));
}

class CandleStickChartData {
  final List<CandleStickChartBarData> candlesData;
  final FlGridData gridData;
  final FlTitlesData titlesData;
  final FlBorderData borderData;
  final double? minY, maxY, minX, maxX;
  final CandleStickChartTouchData candleTouchData;
  CandleStickChartData({
    this.candlesData = const [],
    this.gridData = const FlGridData(),
    this.titlesData = const FlTitlesData(),
    FlBorderData? borderData,
    this.minY,
    this.maxY,
    this.minX,
    this.maxX,
    this.candleTouchData = const CandleStickChartTouchData(),
  }) : borderData = borderData ?? FlBorderData();
}

class CandleStickChartBarData {
  final double x;
  final CandleStickChartCandleData data;
  CandleStickChartBarData({required this.x, required this.data});
}

class CandleStickChartCandleData {
  final double? open, high, low, close;
  CandleStickChartCandleData({this.open, this.high, this.low, this.close});
}

class CandleStickChartTouchData {
  final CandleStickChartTouchTooltipData touchTooltipData;
  const CandleStickChartTouchData({
    this.touchTooltipData = const CandleStickChartTouchTooltipData(),
  });
}

class CandleStickChartTouchTooltipData {
  final Color tooltipBgColor;
  const CandleStickChartTouchTooltipData({this.tooltipBgColor = Colors.blue});
}
