import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PriceDisplayWidget extends StatefulWidget {
  const PriceDisplayWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<PriceDisplayWidget> createState() => _PriceDisplayWidgetState();
}

class _PriceDisplayWidgetState extends State<PriceDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _priceAnimationController;
  late Animation<double> _scaleAnimation;
  late Timer _priceUpdateTimer;

  final Random _random = Random();

  double _currentPrice = 43250.00;
  double _previousPrice = 43250.00;
  double _openPrice = 42194.50;
  double _highPrice = 44125.00;
  double _lowPrice = 41890.00;
  double _volume = 1200000000;
  bool _isPriceIncreasing = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializePriceData();
    _startPriceUpdates();
  }

  void _setupAnimations() {
    _priceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _priceAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _initializePriceData() {
    final basePrice = _getBasePriceForSymbol(widget.symbol);
    _currentPrice = basePrice;
    _previousPrice = basePrice;
    _openPrice = basePrice * (0.98 + _random.nextDouble() * 0.04); // ±2%
    _highPrice = basePrice * (1.01 + _random.nextDouble() * 0.03); // +1-4%
    _lowPrice = basePrice * (0.96 + _random.nextDouble() * 0.03); // -4-1%
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

  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _updatePrice();
      }
    });
  }

  void _updatePrice() {
    _previousPrice = _currentPrice;

    // Simular cambio realista de precio
    final changePercent = (_random.nextDouble() - 0.5) * 0.015; // ±0.75%
    _currentPrice = _currentPrice * (1 + changePercent);

    _isPriceIncreasing = _currentPrice > _previousPrice;

    // Actualizar high/low si es necesario
    if (_currentPrice > _highPrice) _highPrice = _currentPrice;
    if (_currentPrice < _lowPrice) _lowPrice = _currentPrice;

    // Simular cambio en volumen
    _volume = _volume * (0.98 + _random.nextDouble() * 0.04);

    setState(() {
      _isAnimating = true;
    });

    // Ejecutar animación
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
    _priceUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

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
                _buildDesktopLayout(isDark)
              else
                _buildMobileLayout(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildMainPrice(isDark)),
        const SizedBox(width: AppSpacing.xl),
        Expanded(flex: 3, child: _buildPriceStats(isDark, true)),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        _buildMainPrice(isDark),
        const SizedBox(height: AppSpacing.lg),
        _buildPriceStats(isDark, false),
      ],
    );
  }

  Widget _buildMainPrice(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Price',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
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
                  color: _isAnimating
                      ? (_isPriceIncreasing
                                ? AppColors.getBuyGreen(isDark)
                                : AppColors.getSellRed(isDark))
                            .withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: AutoSizeText(
                  '\$${_currentPrice.toStringAsFixed(_currentPrice >= 1 ? 2 : 4)}',
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
        _buildPriceChange(isDark),
      ],
    );
  }

  Widget _buildPriceChange(bool isDark) {
    final changeAmount = _currentPrice - _openPrice;
    final changePercent = ((changeAmount / _openPrice) * 100);
    final isPositive = changeAmount >= 0;

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
                '${isPositive ? '+' : ''}\$${changeAmount.toStringAsFixed(2)}',
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
            '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
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

  Widget _buildPriceStats(bool isDark, bool isDesktop) {
    final stats = [
      PriceStatData(
        label: '24h Open',
        value: '\$${_openPrice.toStringAsFixed(_openPrice >= 1 ? 2 : 4)}',
        icon: LucideIcons.clock,
        color: AppColors.getInfo(isDark),
      ),
      PriceStatData(
        label: '24h High',
        value: '\$${_highPrice.toStringAsFixed(_highPrice >= 1 ? 2 : 4)}',
        icon: LucideIcons.trendingUp,
        color: AppColors.getBuyGreen(isDark),
      ),
      PriceStatData(
        label: '24h Low',
        value: '\$${_lowPrice.toStringAsFixed(_lowPrice >= 1 ? 2 : 4)}',
        icon: LucideIcons.trendingDown,
        color: AppColors.getSellRed(isDark),
      ),
      PriceStatData(
        label: '24h Volume',
        value: _formatVolume(_volume),
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
      return '${(volume / 1000000000).toStringAsFixed(1)}B USDT';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M USDT';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K USDT';
    }
    return '${volume.toStringAsFixed(0)} USDT';
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

class PriceStatCard extends StatelessWidget {
  const PriceStatCard({super.key, required this.stat, required this.isDark});

  final PriceStatData stat;
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(stat.icon, color: stat.color, size: 14),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  stat.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stat.value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
