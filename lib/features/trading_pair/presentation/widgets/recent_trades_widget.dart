import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';
import '/features/trading_pair/domain/entities/entities.dart';

class RecentTradesWidget extends StatelessWidget {
  const RecentTradesWidget({super.key, required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return BlocBuilder<TradingPairBloc, TradingPairState>(
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
                    _buildHeader(
                      isDark,
                      state.isStreaming,
                      state.recentTrades.length,
                    ),
                    const Divider(height: 1),
                    _buildTradesHeader(isDark),
                    SizedBox(
                      height: 300,
                      child: _buildTradesList(
                        isDark,
                        state.recentTrades,
                        state.tradingPair.currentPrice,
                      ),
                    ),
                    _buildFooter(isDark, state.recentTrades),
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

  Widget _buildHeader(bool isDark, bool isStreaming, int tradesCount) {
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
          Text(
            '$tradesCount trades',
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

  Widget _buildTradesList(
    bool isDark,
    List<TradeEntity> trades,
    double currentPrice,
  ) {
    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.chartBar,
              size: 48,
              color: AppColors.getTextMuted(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No trades available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        final isRecent =
            DateTime.now().difference(trade.timestamp).inSeconds < 10;

        return TradeRow(
          trade: trade,
          isDark: isDark,
          isRecent: isRecent,
          currentPrice: currentPrice,
        );
      },
    );
  }

  Widget _buildFooter(bool isDark, List<TradeEntity> trades) {
    if (trades.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
          ),
        ),
        child: Text(
          'Waiting for trade data...',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.getTextMuted(isDark),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final buyTrades = trades.where((t) => t.isBuy).length;
    final sellTrades = trades.where((t) => t.isSell).length;
    final totalTrades = trades.length;

    final buyPercentage = totalTrades > 0
        ? (buyTrades / totalTrades) * 100
        : 50.0;
    final sellPercentage = 100 - buyPercentage;

    // Calculate volume analysis
    final buyVolume = trades
        .where((t) => t.isBuy)
        .fold(0.0, (sum, t) => sum + t.quoteQuantity);
    final sellVolume = trades
        .where((t) => t.isSell)
        .fold(0.0, (sum, t) => sum + t.quoteQuantity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Column(
        children: [
          // Trade count ratio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy/Sell Count',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              Text(
                '$buyTrades / $sellTrades (${buyPercentage.toStringAsFixed(1)}%)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Volume ratio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy/Sell Volume',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              Text(
                '\$${_formatVolume(buyVolume)} / \$${_formatVolume(sellVolume)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Visual ratio bar
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
                if (sellPercentage > 0)
                  Expanded(
                    flex: sellPercentage.round(),
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
          const SizedBox(height: AppSpacing.sm),

          // Market sentiment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Sentiment',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getSentimentColor(
                    buyPercentage,
                    isDark,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(
                    color: _getSentimentColor(
                      buyPercentage,
                      isDark,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getSentimentText(buyPercentage),
                  style: AppTextStyles.caption.copyWith(
                    color: _getSentimentColor(buyPercentage, isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  Color _getSentimentColor(double buyPercentage, bool isDark) {
    if (buyPercentage >= 60) {
      return AppColors.getBuyGreen(isDark);
    } else if (buyPercentage <= 40) {
      return AppColors.getSellRed(isDark);
    }
    return AppColors.getTextMuted(isDark);
  }

  String _getSentimentText(double buyPercentage) {
    if (buyPercentage >= 65) {
      return 'Strong Bullish';
    } else if (buyPercentage >= 55) {
      return 'Bullish';
    } else if (buyPercentage >= 45) {
      return 'Neutral';
    } else if (buyPercentage >= 35) {
      return 'Bearish';
    }
    return 'Strong Bearish';
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
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading recent trades...',
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

class TradeRow extends StatefulWidget {
  const TradeRow({
    super.key,
    required this.trade,
    required this.isDark,
    required this.isRecent,
    required this.currentPrice,
  });

  final TradeEntity trade;
  final bool isDark;
  final bool isRecent;
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
                      Flexible(
                        child: Text(
                          widget.trade.formattedPrice,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.trade.isBuy
                                ? AppColors.getBuyGreen(widget.isDark)
                                : AppColors.getSellRed(widget.isDark),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.trade.formattedQuantity,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextPrimary(widget.isDark),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatTime(widget.trade.timestamp),
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
