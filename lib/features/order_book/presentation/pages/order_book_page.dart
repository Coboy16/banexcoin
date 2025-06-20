import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '/core/core.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage({super.key});

  @override
  State<OrderBookPage> createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedPair = 'BTC/USDT';
  int _selectedDepth = 20;
  final double _spreadValue = 2.50;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Simulate order book updates
    _simulateOrderUpdates();
  }

  void _simulateOrderUpdates() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        _simulateOrderUpdates();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        _buildHeader(),

        const SizedBox(height: AppSpacing.lg),

        // Main content
        Expanded(
          child: ResponsiveRowColumn(
            layout: isDesktop
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
            rowSpacing: AppSpacing.lg,
            columnSpacing: AppSpacing.lg,
            children: [
              ResponsiveRowColumnItem(
                rowFlex: 2,
                child: Column(
                  children: [
                    // Order book widget
                    Expanded(
                      child: OrderBookWidget(
                        animationController: _animationController,
                      ),
                    ),
                  ],
                ),
              ),

              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Column(
                  children: [
                    // Market depth chart
                    const MarketDepthWidget(),

                    const SizedBox(height: AppSpacing.lg),

                    // Order book stats
                    OrderBookStatsWidget(spreadValue: _spreadValue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order Book', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Real-time buy and sell orders',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),

        // Controls
        Row(
          children: [
            // Pair selector
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: DropdownButton<String>(
                value: _selectedPair,
                underline: const SizedBox(),
                dropdownColor: AppColors.cardBackground,
                style: AppTextStyles.bodyMedium,
                items: ['BTC/USDT', 'ETH/USDT', 'BNB/USDT', 'ADA/USDT']
                    .map(
                      (pair) =>
                          DropdownMenuItem(value: pair, child: Text(pair)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPair = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Depth selector
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: DropdownButton<int>(
                value: _selectedDepth,
                underline: const SizedBox(),
                dropdownColor: AppColors.cardBackground,
                style: AppTextStyles.bodyMedium,
                items: [10, 20, 50, 100]
                    .map(
                      (depth) => DropdownMenuItem(
                        value: depth,
                        child: Text('$depth levels'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDepth = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Refresh button
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Refresh order book
                  },
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      LucideIcons.refreshCw,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OrderBookWidget extends StatelessWidget {
  const OrderBookWidget({super.key, required this.animationController});

  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    // Sample order book data
    final asks = List.generate(
      15,
      (index) => _OrderData(
        price: 43255.50 + (index * 0.50),
        amount: 0.15 - (index * 0.005),
        total: (43255.50 + (index * 0.50)) * (0.15 - (index * 0.005)),
      ),
    );

    final bids = List.generate(
      15,
      (index) => _OrderData(
        price: 43252.50 - (index * 0.50),
        amount: 0.22 + (index * 0.008),
        total: (43252.50 - (index * 0.50)) * (0.22 + (index * 0.008)),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderPrimary),
              ),
            ),
            child: Row(
              children: [
                Text('Order Book - BTC/USDT', style: AppTextStyles.h3),
                const Spacer(),

                // Connection status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(
                                0.5 + (animationController.value * 0.5),
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Live',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceColor,
              border: Border(
                bottom: BorderSide(color: AppColors.borderPrimary),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Price (USDT)', style: AppTextStyles.labelMedium),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount (BTC)',
                    style: AppTextStyles.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Total (USDT)',
                    style: AppTextStyles.labelMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Order book content
          Expanded(
            child: isDesktop
                ? Row(
                    children: [
                      // Asks (Sell orders)
                      Expanded(
                        child: _OrderSection(
                          title: 'ASKS (Sell Orders)',
                          orders: asks.reversed.toList(),
                          isBuySection: false,
                          animationController: animationController,
                        ),
                      ),

                      // Spread section
                      Container(
                        width: 120,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppColors.borderPrimary),
                            right: BorderSide(color: AppColors.borderPrimary),
                          ),
                        ),
                        child: _SpreadSection(),
                      ),

                      // Bids (Buy orders)
                      Expanded(
                        child: _OrderSection(
                          title: 'BIDS (Buy Orders)',
                          orders: bids,
                          isBuySection: true,
                          animationController: animationController,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Asks section (top)
                      Expanded(
                        child: _OrderSection(
                          title: 'ASKS (Sell Orders)',
                          orders: asks.take(8).toList().reversed.toList(),
                          isBuySection: false,
                          animationController: animationController,
                        ),
                      ),

                      // Spread section
                      _SpreadSection(),

                      // Bids section (bottom)
                      Expanded(
                        child: _OrderSection(
                          title: 'BIDS (Buy Orders)',
                          orders: bids.take(8).toList(),
                          isBuySection: true,
                          animationController: animationController,
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

class _OrderData {
  final double price;
  final double amount;
  final double total;

  _OrderData({required this.price, required this.amount, required this.total});
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({
    required this.title,
    required this.orders,
    required this.isBuySection,
    required this.animationController,
  });

  final String title;
  final List<_OrderData> orders;
  final bool isBuySection;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: (isBuySection ? AppColors.buyGreen : AppColors.sellRed)
                .withOpacity(0.1),
            border: const Border(
              bottom: BorderSide(color: AppColors.borderPrimary),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: isBuySection ? AppColors.buyGreen : AppColors.sellRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Orders list
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final maxTotal = orders
                  .map((o) => o.total)
                  .reduce((a, b) => a > b ? a : b);
              final fillPercentage = order.total / maxTotal;

              return _OrderRow(
                order: order,
                isBuyOrder: isBuySection,
                fillPercentage: fillPercentage,
                animationController: animationController,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OrderRow extends StatefulWidget {
  const _OrderRow({
    required this.order,
    required this.isBuyOrder,
    required this.fillPercentage,
    required this.animationController,
    required this.index,
  });

  final _OrderData order;
  final bool isBuyOrder;
  final double fillPercentage;
  final AnimationController animationController;
  final int index;

  @override
  State<_OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<_OrderRow> {
  bool _isHovered = false;
  bool _isFlashing = false;

  @override
  void initState() {
    super.initState();

    // Random flash simulation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _simulateFlash();
      }
    });
  }

  void _simulateFlash() {
    if (mounted && DateTime.now().millisecond % 10 == 0) {
      setState(() {
        _isFlashing = true;
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isFlashing = false;
          });
        }
      });
    }

    Future.delayed(
      Duration(milliseconds: 1000 + (widget.index * 200)),
      _simulateFlash,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFlashing
              ? (widget.isBuyOrder ? AppColors.buyGreen : AppColors.sellRed)
                    .withOpacity(0.2)
              : _isHovered
              ? AppColors.surfaceColor.withOpacity(0.5)
              : Colors.transparent,
        ),
        child: InkWell(
          onTap: () {
            // Handle order selection
          },
          child: Stack(
            children: [
              // Background fill
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
                                  ? AppColors.buyGreen
                                  : AppColors.sellRed)
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
                              ? AppColors.buyGreen
                              : AppColors.sellRed,
                          fontWeight: _isFlashing
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
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: AutoSizeText(
                        widget.order.total.toStringAsFixed(2),
                        style: AppTextStyles.bodySmall,
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
      ),
    );
  }
}

class _SpreadSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.surfaceColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SPREAD',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '\$2.50',
            style: AppTextStyles.h4.copyWith(color: AppColors.accentYellow),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '0.0058%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentYellow,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Best ask/bid
          Column(
            children: [
              Text('Best Ask', style: AppTextStyles.caption),
              Text(
                '\$43,255.50',
                style: AppTextStyles.priceSmall.copyWith(
                  color: AppColors.sellRed,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Best Bid', style: AppTextStyles.caption),
              Text(
                '\$43,252.50',
                style: AppTextStyles.priceSmall.copyWith(
                  color: AppColors.buyGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MarketDepthWidget extends StatelessWidget {
  const MarketDepthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Market Depth', style: AppTextStyles.h4),
          ),

          const Divider(height: 1),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.borderSecondary),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.chartArea,
                        color: AppColors.textMuted,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Market Depth Chart',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Visual representation of buy/sell orders',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderBookStatsWidget extends StatelessWidget {
  const OrderBookStatsWidget({super.key, required this.spreadValue});

  final double spreadValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Order Book Stats', style: AppTextStyles.h4),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _StatRow(
                  label: 'Total Bids',
                  value: '15.2435 BTC',
                  color: AppColors.buyGreen,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatRow(
                  label: 'Total Asks',
                  value: '12.8967 BTC',
                  color: AppColors.sellRed,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatRow(
                  label: 'Bid/Ask Ratio',
                  value: '1.18',
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatRow(
                  label: 'Mid Price',
                  value: '\$43,254.00',
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Spread details
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spread (USDT)',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '\$${spreadValue.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.accentYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Spread (%)', style: AppTextStyles.bodySmall),
                          Text(
                            '${(spreadValue / 43254 * 100).toStringAsFixed(4)}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
