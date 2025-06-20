import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PortfolioOverviewWidget extends StatefulWidget {
  const PortfolioOverviewWidget({super.key});

  @override
  State<PortfolioOverviewWidget> createState() =>
      _PortfolioOverviewWidgetState();
}

class _PortfolioOverviewWidgetState extends State<PortfolioOverviewWidget> {
  final Random _random = Random();

  // Posiciones simuladas del portfolio
  final Map<String, PortfolioPosition> _positions = {
    'BTCUSDT': PortfolioPosition(
      symbol: 'BTC/USDT',
      quantity: 0.2845,
      averagePrice: 41500.0,
      currentPrice: 0.0,
    ),
    'ETHUSDT': PortfolioPosition(
      symbol: 'ETH/USDT',
      quantity: 4.125,
      averagePrice: 2580.0,
      currentPrice: 0.0,
    ),
    'BNBUSDT': PortfolioPosition(
      symbol: 'BNB/USDT',
      quantity: 18.5,
      averagePrice: 310.0,
      currentPrice: 0.0,
    ),
    'ADAUSDT': PortfolioPosition(
      symbol: 'ADA/USDT',
      quantity: 1250.0,
      averagePrice: 0.55,
      currentPrice: 0.0,
    ),
    'SOLUSDT': PortfolioPosition(
      symbol: 'SOL/USDT',
      quantity: 12.3,
      averagePrice: 138.0,
      currentPrice: 0.0,
    ),
  };

  // Cash disponible simulado
  double _availableCash = 3456.78;
  double _initialPortfolioValue = 15000.0;
  DateTime _lastUpdate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, marketState) {
            // Actualizar precios sin setState
            if (marketState is MarketDataLoaded) {
              _updatePositionPrices(marketState);
            }

            final portfolioData = _calculatePortfolioMetrics(marketState);

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
                  _buildHeader(isDark, portfolioData),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMetrics(isDesktop, isDark, portfolioData, marketState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updatePositionPrices(MarketDataLoaded marketState) {
    // Solo actualizar precios sin setState
    for (final entry in _positions.entries) {
      final symbol = entry.key;
      final position = entry.value;
      final ticker = marketState.tickers[symbol];

      if (ticker != null) {
        final newPrice =
            double.tryParse(ticker.lastPrice) ?? position.currentPrice;
        position.currentPrice = newPrice;
      }
    }
  }

  PortfolioData _calculatePortfolioMetrics(MarketDataState marketState) {
    double totalValue = _availableCash;
    double totalPnL = 0.0;
    double todayPnL = 0.0;
    int profitablePositions = 0;
    int totalPositions = 0;

    for (final position in _positions.values) {
      if (position.currentPrice > 0) {
        final positionValue = position.quantity * position.currentPrice;
        final positionCost = position.quantity * position.averagePrice;
        final positionPnL = positionValue - positionCost;

        totalValue += positionValue;
        totalPnL += positionPnL;

        // Simular PnL del día basado en cambio de precio reciente
        final todayChange =
            position.currentPrice *
            0.015 *
            (_random.nextDouble() - 0.5); // ±1.5% random
        todayPnL += todayChange * position.quantity;

        if (positionPnL > 0) profitablePositions++;
        totalPositions++;
      }
    }

    final totalPnLPercent = totalPnL / _initialPortfolioValue * 100;
    final todayPnLPercent = todayPnL / totalValue * 100;

    return PortfolioData(
      totalBalance: totalValue,
      availableBalance: _availableCash,
      totalPnL: totalPnL,
      totalPnLPercent: totalPnLPercent,
      todayPnL: todayPnL,
      todayPnLPercent: todayPnLPercent,
      activePositions: totalPositions,
      profitablePositions: profitablePositions,
      lastUpdate: _lastUpdate,
      isConnected: marketState is MarketDataLoaded
          ? marketState.isConnected
          : false,
    );
  }

  Widget _buildHeader(bool isDark, PortfolioData data) {
    return Row(
      children: [
        Text(
          'Portfolio Overview',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const Spacer(),
        if (data.isConnected)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: data.totalPnLPercent >= 0
                  ? AppColors.getBuyGreen(isDark).withOpacity(0.1)
                  : AppColors.getSellRed(isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  data.totalPnLPercent >= 0
                      ? LucideIcons.trendingUp
                      : LucideIcons.trendingDown,
                  color: data.totalPnLPercent >= 0
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                  size: 12,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${data.totalPnLPercent >= 0 ? '+' : ''}${data.totalPnLPercent.toStringAsFixed(2)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: data.totalPnLPercent >= 0
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetrics(
    bool isDesktop,
    bool isDark,
    PortfolioData data,
    MarketDataState marketState,
  ) {
    final metrics = [
      PortfolioMetricData(
        title: 'Total Balance',
        value: '\$${_formatValue(data.totalBalance)}',
        subtitle: 'USD ${_formatValue(data.totalBalance)}',
        change:
            '${data.totalPnL >= 0 ? '+' : ''}\$${_formatValue(data.totalPnL.abs())}',
        changePercent:
            '${data.totalPnLPercent >= 0 ? '+' : ''}${data.totalPnLPercent.toStringAsFixed(2)}%',
        isPositive: data.totalPnL >= 0,
        icon: LucideIcons.wallet,
        isConnected: data.isConnected,
      ),
      PortfolioMetricData(
        title: 'Today\'s P&L',
        value:
            '${data.todayPnL >= 0 ? '+' : ''}\$${_formatValue(data.todayPnL.abs())}',
        subtitle: 'Unrealized',
        change:
            '${data.todayPnL >= 0 ? '+' : ''}\$${_formatValue(data.todayPnL.abs())}',
        changePercent:
            '${data.todayPnLPercent >= 0 ? '+' : ''}${data.todayPnLPercent.toStringAsFixed(2)}%',
        isPositive: data.todayPnL >= 0,
        icon: data.todayPnL >= 0
            ? LucideIcons.trendingUp
            : LucideIcons.trendingDown,
        isConnected: data.isConnected,
      ),
      PortfolioMetricData(
        title: 'Active Positions',
        value: '${data.activePositions}',
        subtitle: '${data.profitablePositions} profitable',
        change: data.activePositions > 0 ? '+${data.activePositions}' : '0',
        changePercent: data.activePositions > 0
            ? '${(data.profitablePositions / data.activePositions * 100).toStringAsFixed(1)}%'
            : '0%',
        isPositive: data.profitablePositions >= data.activePositions / 2,
        icon: LucideIcons.chartPie,
        isConnected: data.isConnected,
      ),
      PortfolioMetricData(
        title: 'Available Balance',
        value: '\$${_formatValue(data.availableBalance)}',
        subtitle: 'For trading',
        change: _getAvailableBalanceChange(),
        changePercent: _getAvailableBalanceChangePercent(),
        isPositive: _random.nextBool(), // Simular cambio aleatorio
        icon: LucideIcons.dollarSign,
        isConnected: data.isConnected,
      ),
    ];

    if (isDesktop) {
      // VISTA WEB/DESKTOP (SIN CAMBIOS)
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
        children: List.generate(metrics.length, (index) {
          final metric = metrics[index];
          return Column(
            children: [
              _buildMobileMetricRow(metric, isDark),
              if (index < metrics.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(
                    color: AppColors.getBorderSecondary(isDark),
                    height: 1,
                  ),
                ),
            ],
          );
        }),
      );
    }
  }

  Widget _buildMobileMetricRow(PortfolioMetricData metric, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Izquierdo: Título y Subtítulo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                metric.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
            ],
          ),
          // Lado Derecho: Valor y Cambio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AutoSizeText(
                metric.value,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    metric.isPositive
                        ? LucideIcons.arrowUp
                        : LucideIcons.arrowDown,
                    color: metric.isPositive
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark),
                    size: 12,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${metric.change} (${metric.changePercent})',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: metric.isPositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }

  String _getAvailableBalanceChange() {
    final change = (_random.nextDouble() - 0.5) * 500; // ±$250 random
    return '${change >= 0 ? '+' : ''}\$${change.abs().toStringAsFixed(2)}';
  }

  String _getAvailableBalanceChangePercent() {
    final changePercent = (_random.nextDouble() - 0.5) * 10; // ±5% random
    return '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%';
  }
}

// Clases de datos (SIN CAMBIOS)
class PortfolioPosition {
  final String symbol;
  final double quantity;
  final double averagePrice;
  double currentPrice;

  PortfolioPosition({
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
  });

  double get value => quantity * currentPrice;
  double get cost => quantity * averagePrice;
  double get pnl => value - cost;
  double get pnlPercent => cost > 0 ? (pnl / cost) * 100 : 0.0;
  bool get isProfitable => pnl > 0;
}

class PortfolioData {
  final double totalBalance;
  final double availableBalance;
  final double totalPnL;
  final double totalPnLPercent;
  final double todayPnL;
  final double todayPnLPercent;
  final int activePositions;
  final int profitablePositions;
  final DateTime lastUpdate;
  final bool isConnected;

  PortfolioData({
    required this.totalBalance,
    required this.availableBalance,
    required this.totalPnL,
    required this.totalPnLPercent,
    required this.todayPnL,
    required this.todayPnLPercent,
    required this.activePositions,
    required this.profitablePositions,
    required this.lastUpdate,
    required this.isConnected,
  });
}

class PortfolioMetricData {
  final String title;
  final String value;
  final String subtitle;
  final String change;
  final String changePercent;
  final bool isPositive;
  final IconData icon;
  final bool isConnected;

  PortfolioMetricData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.change,
    required this.changePercent,
    required this.isPositive,
    required this.icon,
    required this.isConnected,
  });
}

class PortfolioMetricCard extends StatefulWidget {
  const PortfolioMetricCard({
    super.key,
    required this.metric,
    required this.isDark,
  });

  final PortfolioMetricData metric;
  final bool isDark;

  @override
  State<PortfolioMetricCard> createState() => _PortfolioMetricCardState();
}

class _PortfolioMetricCardState extends State<PortfolioMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PortfolioMetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar cambio en el valor para animar
    if (oldWidget.metric.value != widget.metric.value) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(widget.isDark),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: AppColors.getBorderSecondary(widget.isDark),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryBlue(
                      widget.isDark,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(
                    widget.metric.icon,
                    color: AppColors.getPrimaryBlue(widget.isDark),
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    widget.metric.title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.getTextSecondary(widget.isDark),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.metric.isConnected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.getError(widget.isDark),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AutoSizeText(
              widget.metric.value,
              style: AppTextStyles.priceMain.copyWith(
                color: AppColors.getTextPrimary(widget.isDark),
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.metric.subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.getTextMuted(widget.isDark),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  widget.metric.isPositive
                      ? LucideIcons.arrowUp
                      : LucideIcons.arrowDown,
                  color: widget.metric.isPositive
                      ? AppColors.getBuyGreen(widget.isDark)
                      : AppColors.getSellRed(widget.isDark),
                  size: 12,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.metric.change,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: widget.metric.isPositive
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.metric.changePercent,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: widget.metric.isPositive
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
