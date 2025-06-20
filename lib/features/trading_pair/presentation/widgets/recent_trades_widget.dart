import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class RecentTradesWidget extends StatefulWidget {
  const RecentTradesWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<RecentTradesWidget> createState() => _RecentTradesWidgetState();
}

class _RecentTradesWidgetState extends State<RecentTradesWidget> {
  late Timer _updateTimer;
  final Random _random = Random();

  List<TradeEntry> _trades = [];
  double _currentPrice = 43250.0;

  @override
  void initState() {
    super.initState();
    _currentPrice = _getBasePriceForSymbol(widget.symbol);
    _generateInitialTrades();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
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

  void _generateInitialTrades() {
    _trades.clear();
    final now = DateTime.now();

    for (int i = 0; i < 20; i++) {
      final price =
          _currentPrice * (0.998 + _random.nextDouble() * 0.004); // ±0.2%
      final amount = 0.01 + _random.nextDouble() * 0.5;
      final isBuy = _random.nextBool();
      final time = now.subtract(Duration(seconds: i * 5));

      _trades.add(
        TradeEntry(
          price: price,
          amount: amount,
          time: time,
          isBuy: isBuy,
          id: 'trade_${now.millisecondsSinceEpoch}_$i',
        ),
      );
    }

    // Ordenar por tiempo descendente (más recientes primero)
    _trades.sort((a, b) => b.time.compareTo(a.time));
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _addNewTrade();
      }
    });
  }

  void _addNewTrade() {
    // Simular cambio de precio realista
    final priceChange = (_random.nextDouble() - 0.5) * 0.002; // ±0.1%
    _currentPrice = _currentPrice * (1 + priceChange);

    final amount = 0.01 + _random.nextDouble() * 1.0;
    final isBuy = _random.nextBool();

    final newTrade = TradeEntry(
      price: _currentPrice,
      amount: amount,
      time: DateTime.now(),
      isBuy: isBuy,
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
    );

    setState(() {
      _trades.insert(0, newTrade);

      // Mantener solo los últimos 50 trades
      if (_trades.length > 50) {
        _trades.removeLast();
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
            mainAxisSize:
                MainAxisSize.min, // Cambiar a min para evitar problemas
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const Divider(height: 1),
              _buildTradesHeader(isDark),
              SizedBox(
                height: 300, // Altura fija para la lista de trades
                child: _buildTradesList(isDark),
              ),
              _buildFooter(isDark),
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
            LucideIcons.chartLine,
            color: AppColors.getPrimaryBlue(isDark),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Recent Trades',
            style: AppTextStyles.h4.copyWith(
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
          Text(
            '${_trades.length} trades',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradesHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Price (USDT)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Amount',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Time',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradesList(bool isDark) {
    return ListView.builder(
      itemCount: _trades.length,
      itemBuilder: (context, index) {
        final trade = _trades[index];
        final isRecent = DateTime.now().difference(trade.time).inSeconds < 10;

        return TradeRow(
          trade: trade,
          isDark: isDark,
          isRecent: isRecent,
          formatTime: _formatTime,
          currentPrice: _currentPrice,
        );
      },
    );
  }

  Widget _buildFooter(bool isDark) {
    final buyTrades = _trades.where((t) => t.isBuy).length;
    final buyPercentage = _trades.isNotEmpty
        ? (buyTrades / _trades.length) * 100
        : 50;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy/Sell Ratio',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              Text(
                '${buyPercentage.toStringAsFixed(1)}% / ${(100 - buyPercentage).toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppColors.getBorderSecondary(isDark),
            ),
            child: Row(
              children: [
                if (buyPercentage > 0)
                  Expanded(
                    flex: buyPercentage.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.getBuyGreen(isDark),
                      ),
                    ),
                  ),
                if (buyPercentage < 100)
                  Expanded(
                    flex: (100 - buyPercentage).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.getSellRed(isDark),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TradeEntry {
  final double price;
  final double amount;
  final DateTime time;
  final bool isBuy;
  final String id;

  TradeEntry({
    required this.price,
    required this.amount,
    required this.time,
    required this.isBuy,
    required this.id,
  });
}

class TradeRow extends StatefulWidget {
  const TradeRow({
    super.key,
    required this.trade,
    required this.isDark,
    required this.isRecent,
    required this.formatTime,
    required this.currentPrice,
  });

  final TradeEntry trade;
  final bool isDark;
  final bool isRecent;
  final String Function(DateTime) formatTime;
  final double currentPrice;

  @override
  State<TradeRow> createState() => _TradeRowState();
}

class _TradeRowState extends State<TradeRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.isRecent) {
      _colorAnimation =
          ColorTween(
            begin:
                (widget.trade.isBuy
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark))
                    .withOpacity(0.2),
            end: Colors.transparent,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
          );

      _animationController.forward();
    } else {
      _colorAnimation = const AlwaysStoppedAnimation(Colors.transparent);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(color: _colorAnimation.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.trade.isBuy
                              ? AppColors.getBuyGreen(widget.isDark)
                              : AppColors.getSellRed(widget.isDark),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.trade.price.toStringAsFixed(
                          widget.currentPrice >= 1 ? 2 : 4,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.trade.isBuy
                              ? AppColors.getBuyGreen(widget.isDark)
                              : AppColors.getSellRed(widget.isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.trade.amount.toStringAsFixed(4),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextPrimary(widget.isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.formatTime(widget.trade.time),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.getTextMuted(widget.isDark),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
