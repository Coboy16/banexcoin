import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/features/features.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PairStatisticsWidget extends StatelessWidget {
  const PairStatisticsWidget({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return BlocBuilder<TradingPairBloc, TradingPairState>(
          builder: (context, state) {
            if (state is TradingPairLoaded) {
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
                    _buildHeader(isDark, state.isStreaming),
                    const SizedBox(height: AppSpacing.lg),
                    // MODIFICACIÓN: Pasar 'isDesktop' para renderizar la cuadrícula correcta
                    _buildStatisticsGrid(isDark, state, isDesktop),
                  ],
                ),
              );
            }

            // MODIFICACIÓN: Pasar 'isDesktop' al estado de carga
            return _buildLoadingState(isDark, isDesktop);
          },
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, bool isStreaming) {
    return Row(
      children: [
        Icon(
          LucideIcons.chartLine,
          color: AppColors.getPrimaryBlue(isDark),
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '24h Statistics',
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
      ],
    );
  }

  Widget _buildStatisticsGrid(
    bool isDark,
    TradingPairLoaded state,
    bool isDesktop,
  ) {
    final statistics = _generateStatistics(state);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        childAspectRatio: isDesktop ? 4.2 : 3.5,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
      ),
      itemCount: statistics.length,
      itemBuilder: (context, index) {
        return StatisticCard(statistic: statistics[index], isDark: isDark);
      },
    );
  }

  List<StatisticData> _generateStatistics(TradingPairLoaded state) {
    final tradingPair = state.tradingPair;
    final priceStats = state.priceStats;

    return [
      StatisticData(
        title: '24h Open',
        value:
            '\$${tradingPair.openPrice.toStringAsFixed(tradingPair.openPrice >= 1 ? 2 : 4)}',
        change: null,
        icon: LucideIcons.sunrise,
      ),
      StatisticData(
        title: '24h High',
        value:
            '\$${tradingPair.highPrice24h.toStringAsFixed(tradingPair.highPrice24h >= 1 ? 2 : 4)}',
        change: _calculatePercentChange(
          tradingPair.currentPrice,
          tradingPair.highPrice24h,
        ),
        isPositive: tradingPair.currentPrice >= tradingPair.openPrice,
        icon: LucideIcons.trendingUp,
      ),
      StatisticData(
        title: '24h Low',
        value:
            '\$${tradingPair.lowPrice24h.toStringAsFixed(tradingPair.lowPrice24h >= 1 ? 2 : 4)}',
        change: _calculatePercentChange(
          tradingPair.currentPrice,
          tradingPair.lowPrice24h,
        ),
        isPositive: tradingPair.currentPrice >= tradingPair.lowPrice24h,
        icon: LucideIcons.trendingDown,
      ),
      StatisticData(
        title: 'Current Price',
        value:
            '\$${tradingPair.currentPrice.toStringAsFixed(tradingPair.currentPrice >= 1 ? 2 : 4)}',
        change:
            '${tradingPair.priceChangePercent24h >= 0 ? '+' : ''}${tradingPair.priceChangePercent24h.toStringAsFixed(2)}%',
        isPositive: tradingPair.isPriceChangePositive,
        icon: LucideIcons.activity,
      ),
      StatisticData(
        title: 'Volume (${tradingPair.baseAsset})',
        value: _formatVolume(tradingPair.volume24h),
        change: '+${(tradingPair.volume24h / 1000000).toStringAsFixed(1)}M',
        isPositive: true,
        icon: LucideIcons.chartBar,
      ),
      StatisticData(
        title: 'Volume (${tradingPair.quoteAsset})',
        value: _formatVolume(tradingPair.quoteVolume24h),
        change:
            '+${(tradingPair.quoteVolume24h / 1000000).toStringAsFixed(1)}M',
        isPositive: true,
        icon: LucideIcons.dollarSign,
      ),
      StatisticData(
        title: 'Price Range',
        value:
            '\$${(tradingPair.highPrice24h - tradingPair.lowPrice24h).toStringAsFixed(2)}',
        change: _calculateRangePercent(
          tradingPair.highPrice24h,
          tradingPair.lowPrice24h,
        ),
        isPositive: true,
        icon: LucideIcons.chartPie,
      ),
      StatisticData(
        title: 'Market Trend',
        value: priceStats.trend.displayName,
        change: null,
        icon: _getTrendIcon(priceStats.trend),
        isPositive: priceStats.trend == PriceTrend.bullish,
      ),
    ];
  }

  String _calculatePercentChange(double current, double reference) {
    if (reference == 0) return '0.00%';
    final change = ((current - reference) / reference) * 100;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }

  String _calculateRangePercent(double high, double low) {
    if (low == 0) return '0.00%';
    final rangePercent = ((high - low) / low) * 100;
    return '${rangePercent.toStringAsFixed(2)}%';
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000)
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    if (volume >= 1000000) return '${(volume / 1000000).toStringAsFixed(2)}M';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(2);
  }

  IconData _getTrendIcon(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.bullish:
        return LucideIcons.trendingUp;
      case PriceTrend.bearish:
        return LucideIcons.trendingDown;
      case PriceTrend.neutral:
        return LucideIcons.minus;
    }
  }

  // =================================================================
  // INICIO MODIFICACIÓN: Estado de carga responsivo
  // =================================================================
  Widget _buildLoadingState(bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.chartLine,
                color: AppColors.getPrimaryBlue(isDark),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '24h Statistics',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // MODIFICACIÓN: Cambiar el número de columnas y el aspect ratio para móvil
              crossAxisCount: isDesktop ? 2 : 1,
              childAspectRatio: isDesktop ? 2.2 : 4.0,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(isDark),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(
                    color: AppColors.getBorderSecondary(isDark),
                  ),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StatisticData {
  final String title;
  final String value;
  final String? change;
  final bool? isPositive;
  final IconData icon;

  StatisticData({
    required this.title,
    required this.value,
    this.change,
    this.isPositive,
    required this.icon,
  });
}

class StatisticCard extends StatefulWidget {
  const StatisticCard({
    super.key,
    required this.statistic,
    required this.isDark,
  });

  final StatisticData statistic;
  final bool isDark;

  @override
  State<StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.getPrimaryBlue(widget.isDark).withOpacity(0.05),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    _colorAnimation.value ??
                    AppColors.getSurfaceColor(widget.isDark),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.getPrimaryBlue(widget.isDark).withOpacity(0.3)
                      : AppColors.getBorderSecondary(widget.isDark),
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.getPrimaryBlue(
                            widget.isDark,
                          ).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: AppSpacing.sm),
                            _buildValue(),
                          ],
                        ),
                      ),
                      if (widget.statistic.change != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _buildChange(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: _getIconColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(widget.statistic.icon, color: _getIconColor(), size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            widget.statistic.title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextSecondary(widget.isDark),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildValue() {
    return Text(
      widget.statistic.value,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.getTextPrimary(widget.isDark),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChange() {
    final isPositive = widget.statistic.isPositive ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color:
            (isPositive
                    ? AppColors.getBuyGreen(widget.isDark)
                    : AppColors.getSellRed(widget.isDark))
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? LucideIcons.arrowUp : LucideIcons.arrowDown,
            size: 12,
            color: isPositive
                ? AppColors.getBuyGreen(widget.isDark)
                : AppColors.getSellRed(widget.isDark),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.statistic.change!,
            style: AppTextStyles.caption.copyWith(
              color: isPositive
                  ? AppColors.getBuyGreen(widget.isDark)
                  : AppColors.getSellRed(widget.isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor() {
    switch (widget.statistic.title) {
      case '24h High':
        return AppColors.getBuyGreen(widget.isDark);
      case '24h Low':
        return AppColors.getSellRed(widget.isDark);
      case 'Current Price':
        return AppColors.getPrimaryBlue(widget.isDark);
      case 'Market Trend':
        if (widget.statistic.isPositive == true) {
          return AppColors.getBuyGreen(widget.isDark);
        }
        if (widget.statistic.isPositive == false) {
          return AppColors.getSellRed(widget.isDark);
        }
        return AppColors.getTextSecondary(widget.isDark);
      default:
        return AppColors.getAccentYellow(widget.isDark);
    }
  }
}
