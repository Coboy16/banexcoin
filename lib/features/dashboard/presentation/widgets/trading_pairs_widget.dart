import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class TradingPairsWidget extends StatefulWidget {
  const TradingPairsWidget({super.key});

  @override
  State<TradingPairsWidget> createState() => _TradingPairsWidgetState();
}

class _TradingPairsWidgetState extends State<TradingPairsWidget> {
  late Timer _priceUpdateTimer;
  final Random _random = Random();

  final List<TradingPairData> _pairs = [
    TradingPairData(
      symbol: 'BTC/USDT',
      basePrice: 43250.00,
      currentPrice: 43250.00,
      change: '+2.5%',
      changeAmount: '+1,055.50',
      volume: '1.2B',
      isPositive: true,
      icon: LucideIcons.bitcoin,
      marketCap: '847.2B',
      high24h: 44120.00,
      low24h: 42180.00,
    ),
    TradingPairData(
      symbol: 'ETH/USDT',
      basePrice: 2650.00,
      currentPrice: 2650.00,
      change: '-1.2%',
      changeAmount: '-32.15',
      volume: '850M',
      isPositive: false,
      icon: LucideIcons.hexagon,
      marketCap: '318.5B',
      high24h: 2720.00,
      low24h: 2580.00,
    ),
    TradingPairData(
      symbol: 'BNB/USDT',
      basePrice: 315.50,
      currentPrice: 315.50,
      change: '+4.7%',
      changeAmount: '+14.25',
      volume: '420M',
      isPositive: true,
      icon: LucideIcons.triangle,
      marketCap: '48.3B',
      high24h: 325.80,
      low24h: 301.20,
    ),
    TradingPairData(
      symbol: 'ADA/USDT',
      basePrice: 0.4850,
      currentPrice: 0.4850,
      change: '+8.3%',
      changeAmount: '+0.0372',
      volume: '280M',
      isPositive: true,
      icon: LucideIcons.circle,
      marketCap: '17.1B',
      high24h: 0.5120,
      low24h: 0.4580,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startPriceUpdates();
  }

  @override
  void dispose() {
    _priceUpdateTimer.cancel();
    super.dispose();
  }

  void _startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          for (var pair in _pairs) {
            _updatePairPrice(pair);
          }
        });
      }
    });
  }

  void _updatePairPrice(TradingPairData pair) {
    // Simular cambios de precio reales
    double changePercent = (_random.nextDouble() - 0.5) * 0.02; // ±1%
    pair.currentPrice = pair.currentPrice * (1 + changePercent);

    // Actualizar si el cambio es positivo o negativo
    double totalChange =
        ((pair.currentPrice - pair.basePrice) / pair.basePrice) * 100;
    pair.isPositive = totalChange >= 0;

    // Actualizar el porcentaje de cambio
    pair.change =
        '${totalChange >= 0 ? '+' : ''}${totalChange.toStringAsFixed(1)}%';

    // Actualizar el monto del cambio
    double changeAmount = pair.currentPrice - pair.basePrice;
    pair.changeAmount =
        '${changeAmount >= 0 ? '+' : ''}${changeAmount.toStringAsFixed(2)}';

    // Simular volumen cambiante
    double volumeMultiplier = 0.95 + (_random.nextDouble() * 0.1); // 95% - 105%
    String volumeStr = pair.volume;
    double volumeValue = double.parse(
      volumeStr.replaceAll(RegExp(r'[^\d.]'), ''),
    );
    String unit = volumeStr.replaceAll(RegExp(r'[\d.]'), '');
    pair.volume = '${(volumeValue * volumeMultiplier).toStringAsFixed(1)}$unit';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              _buildTableHeader(isDark),
              ...(_pairs.map(
                (pair) => TradingPairRow(
                  pair: pair,
                  isDark: isDark,
                  onTap: () => _navigateToPairDetail(pair),
                ),
              )),
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
          Text(
            'Trading Pairs',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // Navigate to all pairs page
            },
            icon: Icon(
              LucideIcons.externalLink,
              size: 16,
              color: AppColors.getPrimaryBlue(isDark),
            ),
            label: Text(
              'View All',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.getPrimaryBlue(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
          bottom: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Pair',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Price',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              '24h Change',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              'Volume',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPairDetail(TradingPairData pair) {
    // TODO: Navigate to pair detail page
    debugPrint('Navigate to ${pair.symbol} detail');
  }
}

class TradingPairData {
  final String symbol;
  final double basePrice;
  double currentPrice;
  String change;
  String changeAmount;
  String volume;
  bool isPositive;
  final IconData icon;
  final String marketCap;
  final double high24h;
  final double low24h;

  TradingPairData({
    required this.symbol,
    required this.basePrice,
    required this.currentPrice,
    required this.change,
    required this.changeAmount,
    required this.volume,
    required this.isPositive,
    required this.icon,
    required this.marketCap,
    required this.high24h,
    required this.low24h,
  });
}

class TradingPairRow extends StatefulWidget {
  const TradingPairRow({
    super.key,
    required this.pair,
    required this.isDark,
    required this.onTap,
  });

  final TradingPairData pair;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<TradingPairRow> createState() => _TradingPairRowState();
}

class _TradingPairRowState extends State<TradingPairRow>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  Color? _lastPriceColor;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _updateFlashAnimation();
  }

  @override
  void didUpdateWidget(TradingPairRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar cambio de precio para flash
    if (oldWidget.pair.currentPrice != widget.pair.currentPrice) {
      _updateFlashAnimation();
      _flashController.forward().then((_) {
        _flashController.reverse();
      });
    }
  }

  void _updateFlashAnimation() {
    Color flashColor = widget.pair.isPositive
        ? AppColors.getBuyGreen(widget.isDark)
        : AppColors.getSellRed(widget.isDark);

    _flashAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: flashColor.withOpacity(0.1),
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  _flashAnimation.value ??
                  (_isHovered
                      ? AppColors.getSurfaceColor(
                          widget.isDark,
                        ).withOpacity(0.5)
                      : Colors.transparent),
            ),
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    _buildPairInfo(),
                    _buildPrice(),
                    _buildChange(),
                    _buildVolume(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPairInfo() {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.getPrimaryBlue(widget.isDark).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(
              widget.pair.icon,
              color: AppColors.getPrimaryBlue(widget.isDark),
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.pair.symbol,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextPrimary(widget.isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.pair.changeAmount,
                style: AppTextStyles.caption.copyWith(
                  color: widget.pair.isPositive
                      ? AppColors.getBuyGreen(widget.isDark)
                      : AppColors.getSellRed(widget.isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Expanded(
      child: Text(
        '\$${widget.pair.currentPrice.toStringAsFixed(widget.pair.currentPrice >= 1 ? 2 : 4)}',
        style: AppTextStyles.priceMedium.copyWith(
          color: AppColors.getTextPrimary(widget.isDark),
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildChange() {
    return Expanded(
      child: Container(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color:
                (widget.pair.isPositive
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark))
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Text(
            widget.pair.change,
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.pair.isPositive
                  ? AppColors.getBuyGreen(widget.isDark)
                  : AppColors.getSellRed(widget.isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolume() {
    return Expanded(
      child: Text(
        widget.pair.volume,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.getTextSecondary(widget.isDark),
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
