import 'package:banexcoin/core/bloc/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';
import 'dart:math';

import '/core/core.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage({super.key});

  @override
  State<OrderBookPage> createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late AnimationController _updateAnimationController;
  late Timer _orderUpdateTimer;

  String _selectedPair = 'BTC/USDT';
  int _selectedDepth = 20;
  double _currentPrice = 43254.00;

  // Order book data
  List<OrderBookEntry> _bids = [];
  List<OrderBookEntry> _asks = [];
  double _spread = 0.0;
  double _spreadPercentage = 0.0;

  // Stats
  double _totalBidsVolume = 0.0;
  double _totalAsksVolume = 0.0;
  double _bidAskRatio = 0.0;

  @override
  void initState() {
    super.initState();

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _updateAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _initializeOrderBook();
    _startOrderBookUpdates();
  }

  void _initializeOrderBook() {
    // Generate initial order book data
    _generateOrderBookData();
  }

  void _startOrderBookUpdates() {
    _orderUpdateTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) => _updateOrderBook(),
    );
  }

  void _generateOrderBookData() {
    final random = Random();

    // Generate bids (buy orders) - prices below current price
    _bids = List.generate(20, (index) {
      final price = _currentPrice - (index + 1) * 0.5 - random.nextDouble() * 2;
      final amount = 0.1 + random.nextDouble() * 2;
      return OrderBookEntry(
        price: price,
        amount: amount,
        total: price * amount,
        isUpdated: false,
      );
    });

    // Generate asks (sell orders) - prices above current price
    _asks = List.generate(20, (index) {
      final price = _currentPrice + (index + 1) * 0.5 + random.nextDouble() * 2;
      final amount = 0.1 + random.nextDouble() * 2;
      return OrderBookEntry(
        price: price,
        amount: amount,
        total: price * amount,
        isUpdated: false,
      );
    });

    _calculateStats();
  }

  void _updateOrderBook() {
    if (!mounted) return;

    final random = Random();

    // Randomly update some orders
    for (int i = 0; i < _bids.length; i++) {
      if (random.nextBool() && random.nextDouble() < 0.3) {
        final priceVariation = (random.nextDouble() - 0.5) * 1.0;
        final amountVariation = (random.nextDouble() - 0.5) * 0.2;

        _bids[i] = _bids[i].copyWith(
          price: (_bids[i].price + priceVariation).clamp(
            _currentPrice - 50,
            _currentPrice - 0.1,
          ),
          amount: (_bids[i].amount + amountVariation).clamp(0.01, 10.0),
          isUpdated: true,
        );
        _bids[i] = _bids[i].copyWith(total: _bids[i].price * _bids[i].amount);
      } else {
        _bids[i] = _bids[i].copyWith(isUpdated: false);
      }
    }

    for (int i = 0; i < _asks.length; i++) {
      if (random.nextBool() && random.nextDouble() < 0.3) {
        final priceVariation = (random.nextDouble() - 0.5) * 1.0;
        final amountVariation = (random.nextDouble() - 0.5) * 0.2;

        _asks[i] = _asks[i].copyWith(
          price: (_asks[i].price + priceVariation).clamp(
            _currentPrice + 0.1,
            _currentPrice + 50,
          ),
          amount: (_asks[i].amount + amountVariation).clamp(0.01, 10.0),
          isUpdated: true,
        );
        _asks[i] = _asks[i].copyWith(total: _asks[i].price * _asks[i].amount);
      } else {
        _asks[i] = _asks[i].copyWith(isUpdated: false);
      }
    }

    // Sort orders
    _bids.sort((a, b) => b.price.compareTo(a.price));
    _asks.sort((a, b) => a.price.compareTo(b.price));

    _calculateStats();

    if (mounted) {
      setState(() {});
      _updateAnimationController.forward().then((_) {
        _updateAnimationController.reverse();
      });
    }
  }

  void _calculateStats() {
    _totalBidsVolume = _bids.fold(0.0, (sum, bid) => sum + bid.amount);
    _totalAsksVolume = _asks.fold(0.0, (sum, ask) => sum + ask.amount);
    _bidAskRatio = _totalAsksVolume > 0
        ? _totalBidsVolume / _totalAsksVolume
        : 0.0;

    if (_bids.isNotEmpty && _asks.isNotEmpty) {
      final bestBid = _bids.first.price;
      final bestAsk = _asks.first.price;
      _spread = bestAsk - bestBid;
      _spreadPercentage = (_spread / bestAsk) * 100;
      _currentPrice = (bestBid + bestAsk) / 2;
    }
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _updateAnimationController.dispose();
    _orderUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == ThemeMode.dark;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ResponsiveRowColumn(
                layout: isDesktop
                    ? ResponsiveRowColumnType.ROW
                    : ResponsiveRowColumnType.COLUMN,
                rowSpacing: AppSpacing.lg,
                columnSpacing: AppSpacing.lg,
                children: [
                  ResponsiveRowColumnItem(
                    rowFlex: 3,
                    child: OrderBookWidget(
                      bids: _bids.take(_selectedDepth ~/ 2).toList(),
                      asks: _asks.take(_selectedDepth ~/ 2).toList(),
                      spread: _spread,
                      spreadPercentage: _spreadPercentage,
                      selectedPair: _selectedPair,
                      isDark: isDark,
                      pulseAnimationController: _pulseAnimationController,
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: Column(
                      children: [
                        OrderBookStatsWidget(
                          totalBidsVolume: _totalBidsVolume,
                          totalAsksVolume: _totalAsksVolume,
                          bidAskRatio: _bidAskRatio,
                          spread: _spread,
                          spreadPercentage: _spreadPercentage,
                          currentPrice: _currentPrice,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Book',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Real-time buy and sell orders',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildDropdown(
              value: _selectedPair,
              items: ['BTC/USDT', 'ETH/USDT', 'BNB/USDT', 'ADA/USDT'],
              onChanged: (value) => setState(() => _selectedPair = value!),
              isDark: isDark,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildDropdown(
              value: _selectedDepth,
              items: [10, 20, 50, 100],
              onChanged: (value) => setState(() => _selectedDepth = value!),
              isDark: isDark,
              displayText: (value) => '$value levels',
            ),
            const SizedBox(width: AppSpacing.md),
            _buildRefreshButton(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
    String Function(T)? displayText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: AppColors.getCardBackground(isDark),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.getTextPrimary(isDark),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(displayText?.call(item) ?? item.toString()),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRefreshButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getPrimaryBlue(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _generateOrderBookData();
            setState(() {});
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Icon(LucideIcons.refreshCw, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// Order Book Entry Model
class OrderBookEntry {
  final double price;
  final double amount;
  final double total;
  final bool isUpdated;

  const OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
    this.isUpdated = false,
  });

  OrderBookEntry copyWith({
    double? price,
    double? amount,
    double? total,
    bool? isUpdated,
  }) {
    return OrderBookEntry(
      price: price ?? this.price,
      amount: amount ?? this.amount,
      total: total ?? this.total,
      isUpdated: isUpdated ?? this.isUpdated,
    );
  }
}

// Enhanced Order Book Widget
class OrderBookWidget extends StatelessWidget {
  const OrderBookWidget({
    super.key,
    required this.bids,
    required this.asks,
    required this.spread,
    required this.spreadPercentage,
    required this.selectedPair,
    required this.isDark,
    required this.pulseAnimationController,
  });

  final List<OrderBookEntry> bids;
  final List<OrderBookEntry> asks;
  final double spread;
  final double spreadPercentage;
  final String selectedPair;
  final bool isDark;
  final AnimationController pulseAnimationController;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildColumnHeaders(),
          Expanded(
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Order Book - $selectedPair',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: pulseAnimationController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getSuccess(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.getSuccess(isDark).withOpacity(
                          0.5 + (pulseAnimationController.value * 0.5),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Live',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.getSuccess(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
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
            flex: 3,
            child: Text(
              'Price (USDT)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Amount (BTC)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Total (USDT)',
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

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildOrderSection('ASKS', asks, false)),
        Container(
          width: 140,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.getBorderPrimary(isDark)),
              right: BorderSide(color: AppColors.getBorderPrimary(isDark)),
            ),
          ),
          child: _buildSpreadSection(),
        ),
        Expanded(child: _buildOrderSection('BIDS', bids, true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: _buildOrderSection('ASKS', asks.reversed.toList(), false),
        ),
        _buildSpreadSection(),
        Expanded(child: _buildOrderSection('BIDS', bids, true)),
      ],
    );
  }

  Widget _buildOrderSection(
    String title,
    List<OrderBookEntry> orders,
    bool isBuySection,
  ) {
    final maxTotal = orders.isNotEmpty
        ? orders.map((o) => o.total).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color:
                (isBuySection
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark))
                    .withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: AppColors.getBorderPrimary(isDark)),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: isBuySection
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderRow(
                order: order,
                isBuyOrder: isBuySection,
                fillPercentage: order.total / maxTotal,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadSection() {
    final bestBid = bids.isNotEmpty ? bids.first.price : 0.0;
    final bestAsk = asks.isNotEmpty ? asks.first.price : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.getSurfaceColor(isDark)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SPREAD',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextSecondary(isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '\$${spread.toStringAsFixed(2)}',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getAccentYellow(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${spreadPercentage.toStringAsFixed(4)}%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getAccentYellow(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: [
              Text(
                'Best Ask',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              Text(
                '\$${bestAsk.toStringAsFixed(2)}',
                style: AppTextStyles.priceSmall.copyWith(
                  color: AppColors.getSellRed(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Best Bid',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              Text(
                '\$${bestBid.toStringAsFixed(2)}',
                style: AppTextStyles.priceSmall.copyWith(
                  color: AppColors.getBuyGreen(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Enhanced Order Row Widget
class OrderRow extends StatefulWidget {
  const OrderRow({
    super.key,
    required this.order,
    required this.isBuyOrder,
    required this.fillPercentage,
    required this.isDark,
  });

  final OrderBookEntry order;
  final bool isBuyOrder;
  final double fillPercentage;
  final bool isDark;

  @override
  State<OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<OrderRow>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(OrderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.order.isUpdated && !oldWidget.order.isUpdated) {
      _flashController.forward().then((_) => _flashController.reverse());
    }
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
        animation: _flashController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.order.isUpdated && _flashController.value > 0
                  ? (widget.isBuyOrder
                            ? AppColors.getBuyGreen(widget.isDark)
                            : AppColors.getSellRed(widget.isDark))
                        .withOpacity(0.3 * _flashController.value)
                  : _isHovered
                  ? AppColors.getSurfaceColor(widget.isDark).withOpacity(0.5)
                  : Colors.transparent,
            ),
            child: InkWell(
              onTap: () {
                // Handle order selection/trading
              },
              child: Stack(
                children: [
                  // Volume visualization bar
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width:
                            MediaQuery.of(context).size.width *
                            widget.fillPercentage *
                            0.3,
                        decoration: BoxDecoration(
                          color:
                              (widget.isBuyOrder
                                      ? AppColors.getBuyGreen(widget.isDark)
                                      : AppColors.getSellRed(widget.isDark))
                                  .withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  // Order data
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AutoSizeText(
                            widget.order.price.toStringAsFixed(2),
                            style: AppTextStyles.priceSmall.copyWith(
                              color: widget.isBuyOrder
                                  ? AppColors.getBuyGreen(widget.isDark)
                                  : AppColors.getSellRed(widget.isDark),
                              fontWeight: widget.order.isUpdated
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: AutoSizeText(
                            widget.order.amount.toStringAsFixed(4),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.getTextPrimary(widget.isDark),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: AutoSizeText(
                            widget.order.total.toStringAsFixed(2),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.getTextSecondary(widget.isDark),
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                          ),
                        ),
                      ],
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

// Enhanced Stats Widget
class OrderBookStatsWidget extends StatelessWidget {
  const OrderBookStatsWidget({
    super.key,
    required this.totalBidsVolume,
    required this.totalAsksVolume,
    required this.bidAskRatio,
    required this.spread,
    required this.spreadPercentage,
    required this.currentPrice,
    required this.isDark,
  });

  final double totalBidsVolume;
  final double totalAsksVolume;
  final double bidAskRatio;
  final double spread;
  final double spreadPercentage;
  final double currentPrice;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  LucideIcons.chartBar,
                  color: AppColors.getPrimaryBlue(isDark),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Order Book Statistics',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorderPrimary(isDark)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _StatRow(
                  label: 'Total Bids Volume',
                  value: '${totalBidsVolume.toStringAsFixed(4)} BTC',
                  color: AppColors.getBuyGreen(isDark),
                  icon: LucideIcons.trendingUp,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatRow(
                  label: 'Total Asks Volume',
                  value: '${totalAsksVolume.toStringAsFixed(4)} BTC',
                  color: AppColors.getSellRed(isDark),
                  icon: LucideIcons.trendingDown,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatRow(
                  label: 'Bid/Ask Ratio',
                  value: bidAskRatio.toStringAsFixed(2),
                  color: bidAskRatio > 1.0
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                  icon: LucideIcons.scale,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatRow(
                  label: 'Mid Price',
                  value: currentPrice.toStringAsFixed(2),
                  color: AppColors.getTextPrimary(isDark),
                  icon: LucideIcons.target,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Enhanced Spread Section
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.getAccentYellow(isDark).withOpacity(0.1),
                        AppColors.getAccentYellow(isDark).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: AppColors.getAccentYellow(isDark).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.gitBranch,
                            color: AppColors.getAccentYellow(isDark),
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Spread Analysis',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.getAccentYellow(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spread (USDT)',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.getTextMuted(isDark),
                                ),
                              ),
                              Text(
                                spread.toStringAsFixed(2),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.getAccentYellow(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Spread (%)',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.getTextMuted(isDark),
                                ),
                              ),
                              Text(
                                '${spreadPercentage.toStringAsFixed(4)}%',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.getAccentYellow(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Spread Quality Indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _getSpreadQualityColor(
                            spreadPercentage,
                            isDark,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.sm,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getSpreadQualityIcon(spreadPercentage),
                              color: _getSpreadQualityColor(
                                spreadPercentage,
                                isDark,
                              ),
                              size: 14,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _getSpreadQualityText(spreadPercentage),
                              style: AppTextStyles.caption.copyWith(
                                color: _getSpreadQualityColor(
                                  spreadPercentage,
                                  isDark,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Market Health Indicator
                _buildMarketHealthIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketHealthIndicator() {
    final healthScore = _calculateMarketHealth();
    final healthColor = _getHealthColor(healthScore, isDark);
    final healthText = _getHealthText(healthScore);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(LucideIcons.activity, color: healthColor, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Market Health',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: healthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  healthText,
                  style: AppTextStyles.caption.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Health Score Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.getBorderPrimary(isDark),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: healthScore / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: healthColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Poor',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              Text(
                '${healthScore.toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  color: healthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Excellent',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateMarketHealth() {
    // Simple market health calculation based on various factors
    double score = 50.0; // Base score

    // Factor 1: Spread (lower is better)
    if (spreadPercentage < 0.01) {
      score += 25;
    } else if (spreadPercentage < 0.05) {
      score += 15;
    } else if (spreadPercentage < 0.1) {
      score += 5;
    }

    // Factor 2: Volume balance (closer to 1.0 is better)
    final balanceScore = 1.0 - (bidAskRatio - 1.0).abs();
    score += balanceScore * 20;

    // Factor 3: Total volume (higher is better)
    final totalVolume = totalBidsVolume + totalAsksVolume;
    if (totalVolume > 50) {
      score += 15;
    } else if (totalVolume > 20) {
      score += 10;
    } else if (totalVolume > 10) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  Color _getHealthColor(double score, bool isDark) {
    if (score >= 80) {
      return AppColors.getSuccess(isDark);
    } else if (score >= 60) {
      return AppColors.getAccentYellow(isDark);
    } else {
      return AppColors.getSellRed(isDark);
    }
  }

  String _getHealthText(double score) {
    if (score >= 80) {
      return 'Excellent';
    } else if (score >= 60) {
      return 'Good';
    } else if (score >= 40) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  Color _getSpreadQualityColor(double percentage, bool isDark) {
    if (percentage <= 0.01) {
      return AppColors.getSuccess(isDark);
    } else if (percentage <= 0.05) {
      return AppColors.getAccentYellow(isDark);
    } else {
      return AppColors.getSellRed(isDark);
    }
  }

  IconData _getSpreadQualityIcon(double percentage) {
    if (percentage <= 0.01) {
      return LucideIcons.circleCheck;
    } else if (percentage <= 0.05) {
      return LucideIcons.triangleAlert;
    } else {
      return LucideIcons.circleX;
    }
  }

  String _getSpreadQualityText(double percentage) {
    if (percentage <= 0.01) {
      return 'Tight Spread';
    } else if (percentage <= 0.05) {
      return 'Normal Spread';
    } else {
      return 'Wide Spread';
    }
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
