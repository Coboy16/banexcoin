import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';
import '/features/trading_pair/domain/entities/entities.dart';

class PriceDisplayWidget extends StatefulWidget {
  const PriceDisplayWidget({
    super.key,
    required this.tradingPair,
    required this.priceStats,
  });

  final TradingPairEntity tradingPair;
  final PriceStatsEntity priceStats;

  @override
  State<PriceDisplayWidget> createState() => _PriceDisplayWidgetState();
}

class _PriceDisplayWidgetState extends State<PriceDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _priceAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  TradingPairEntity? _previousTradingPair;
  bool _isPriceIncreasing = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _previousTradingPair = widget.tradingPair;
  }

  @override
  void didUpdateWidget(PriceDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_previousTradingPair != null &&
        widget.tradingPair.currentPrice != _previousTradingPair!.currentPrice) {
      _isPriceIncreasing =
          widget.tradingPair.currentPrice > _previousTradingPair!.currentPrice;
      _animatePriceChange();
    }
    _previousTradingPair = widget.tradingPair;
  }

  void _setupAnimations() {
    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _priceAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_priceAnimationController);
  }

  void _animatePriceChange() {
    setState(() {
      _isAnimating = true;
    });

    _priceAnimationController.forward().then((_) {
      if (mounted) {
        _priceAnimationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _priceAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return BlocBuilder<TradingPairBloc, TradingPairState>(
          builder: (context, state) {
            // Always use the latest data from the BLoC if available
            final currentTradingPair = state is TradingPairLoaded
                ? state.tradingPair
                : widget.tradingPair;
            final currentPriceStats = state is TradingPairLoaded
                ? state.priceStats
                : widget.priceStats;

            // Update color animation based on current theme
            _colorAnimation = ColorTween(
              begin: Colors.transparent,
              end:
                  (_isPriceIncreasing
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.1),
            ).animate(_priceAnimationController);

            return AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(isDark),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(
                      color: _isAnimating
                          ? (_isPriceIncreasing
                                    ? AppColors.getBuyGreen(isDark)
                                    : AppColors.getSellRed(isDark))
                                .withOpacity(0.5)
                          : AppColors.getBorderPrimary(isDark),
                      width: _isAnimating ? 2 : 1,
                    ),
                    boxShadow: _isAnimating
                        ? [
                            BoxShadow(
                              color:
                                  (_isPriceIncreasing
                                          ? AppColors.getBuyGreen(isDark)
                                          : AppColors.getSellRed(isDark))
                                      .withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      if (isDesktop)
                        _buildDesktopLayout(
                          isDark,
                          currentTradingPair,
                          currentPriceStats,
                          state,
                        )
                      else
                        _buildMobileLayout(
                          isDark,
                          currentTradingPair,
                          currentPriceStats,
                          state,
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(
    bool isDark,
    TradingPairEntity tradingPair,
    PriceStatsEntity priceStats,
    TradingPairState state,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildMainPrice(isDark, tradingPair, priceStats, state),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(flex: 3, child: _buildPriceStats(isDark, priceStats, true)),
      ],
    );
  }

  Widget _buildMobileLayout(
    bool isDark,
    TradingPairEntity tradingPair,
    PriceStatsEntity priceStats,
    TradingPairState state,
  ) {
    return Column(
      children: [
        _buildMainPrice(isDark, tradingPair, priceStats, state),
        const SizedBox(height: AppSpacing.lg),
        _buildPriceStats(isDark, priceStats, false),
      ],
    );
  }

  Widget _buildMainPrice(
    bool isDark,
    TradingPairEntity tradingPair,
    PriceStatsEntity priceStats,
    TradingPairState state,
  ) {
    final isStreaming = state is TradingPairLoaded ? state.isStreaming : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Current Price',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildTrendIcon(isDark, priceStats),
            const Spacer(),
            _buildLastUpdateIndicator(isDark, priceStats, isStreaming),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: AutoSizeText(
                  '\$${tradingPair.currentPrice.toStringAsFixed(tradingPair.currentPrice >= 1 ? 2 : 4)}',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 42,
                    color: _isAnimating
                        ? (_isPriceIncreasing
                              ? AppColors.getBuyGreen(isDark)
                              : AppColors.getSellRed(isDark))
                        : AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPriceChange(isDark, tradingPair),
      ],
    );
  }

  Widget _buildTrendIcon(bool isDark, PriceStatsEntity priceStats) {
    final trend = priceStats.trend;
    IconData icon;
    Color color;

    switch (trend) {
      case PriceTrend.bullish:
        icon = LucideIcons.trendingUp;
        color = AppColors.getBuyGreen(isDark);
        break;
      case PriceTrend.bearish:
        icon = LucideIcons.trendingDown;
        color = AppColors.getSellRed(isDark);
        break;
      case PriceTrend.neutral:
        icon = LucideIcons.minus;
        color = AppColors.getTextMuted(isDark);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  Widget _buildLastUpdateIndicator(
    bool isDark,
    PriceStatsEntity priceStats,
    bool isStreaming,
  ) {
    return Container(
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
    );
  }

  Widget _buildPriceChange(bool isDark, TradingPairEntity tradingPair) {
    final isPositive = tradingPair.isPriceChangePositive;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                (isPositive
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark))
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(
              color:
                  (isPositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark))
                      .withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                color: isPositive
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${isPositive ? '+' : ''}\$${tradingPair.priceChange24h.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isPositive
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color:
                (isPositive
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark))
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Text(
            '${isPositive ? '+' : ''}${tradingPair.priceChangePercent24h.toStringAsFixed(2)}%',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isPositive
                  ? AppColors.getBuyGreen(isDark)
                  : AppColors.getSellRed(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceStats(
    bool isDark,
    PriceStatsEntity priceStats,
    bool isDesktop,
  ) {
    final stats = [
      PriceStatData(
        label: '24h Open',
        value:
            '\$${priceStats.openPrice.toStringAsFixed(priceStats.openPrice >= 1 ? 2 : 4)}',
        icon: LucideIcons.clock,
        color: AppColors.getInfo(isDark),
      ),
      PriceStatData(
        label: '24h High',
        value:
            '\$${priceStats.highPrice.toStringAsFixed(priceStats.highPrice >= 1 ? 2 : 4)}',
        icon: LucideIcons.trendingUp,
        color: AppColors.getBuyGreen(isDark),
      ),
      PriceStatData(
        label: '24h Low',
        value:
            '\$${priceStats.lowPrice.toStringAsFixed(priceStats.lowPrice >= 1 ? 2 : 4)}',
        icon: LucideIcons.trendingDown,
        color: AppColors.getSellRed(isDark),
      ),
      PriceStatData(
        label: '24h Volume',
        value: _formatVolume(priceStats.quoteVolume),
        icon: LucideIcons.chartBar,
        color: AppColors.getPrimaryBlue(isDark),
      ),
    ];

    if (isDesktop) {
      return Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: stats
            .map(
              (stat) => SizedBox(
                width: 150,
                child: PriceStatCard(stat: stat, isDark: isDark),
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
                child: PriceStatCard(stat: stats[0], isDark: isDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PriceStatCard(stat: stats[1], isDark: isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PriceStatCard(stat: stats[2], isDark: isDark),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PriceStatCard(stat: stats[3], isDark: isDark),
              ),
            ],
          ),
        ],
      );
    }
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
}

class PriceStatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  PriceStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class PriceStatCard extends StatefulWidget {
  const PriceStatCard({super.key, required this.stat, required this.isDark});

  final PriceStatData stat;
  final bool isDark;

  @override
  State<PriceStatCard> createState() => _PriceStatCardState();
}

class _PriceStatCardState extends State<PriceStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(widget.isDark),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: _isHovered
                      ? widget.stat.color.withOpacity(0.3)
                      : AppColors.getBorderSecondary(widget.isDark),
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.stat.color.withOpacity(0.1),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: widget.stat.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.sm,
                          ),
                        ),
                        child: Icon(
                          widget.stat.icon,
                          color: widget.stat.color,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          widget.stat.label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.getTextSecondary(widget.isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.stat.value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.getTextPrimary(widget.isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
