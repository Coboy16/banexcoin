import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class OrderBookTwoWidget extends StatefulWidget {
  const OrderBookTwoWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<OrderBookTwoWidget> createState() => _OrderBookTwoWidgetState();
}

class _OrderBookTwoWidgetState extends State<OrderBookTwoWidget> {
  late Timer _updateTimer;
  final Random _random = Random();

  List<OrderBookEntry> _buyOrders = [];
  List<OrderBookEntry> _sellOrders = [];
  double _currentPrice = 43250.0;
  double _priceSpread = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPrice = _getBasePriceForSymbol(widget.symbol);
    _generateInitialOrderBook();
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

  void _generateInitialOrderBook() {
    _buyOrders.clear();
    _sellOrders.clear();

    // Generar órdenes de compra (bid) - precios menores al actual
    for (int i = 0; i < 15; i++) {
      final priceOffset = (i + 1) * (_currentPrice * 0.001); // 0.1% steps
      final price = _currentPrice - priceOffset;
      final amount = 0.1 + _random.nextDouble() * 2.0;

      _buyOrders.add(
        OrderBookEntry(
          price: price,
          amount: amount,
          total: price * amount,
          isBuy: true,
        ),
      );
    }

    // Generar órdenes de venta (ask) - precios mayores al actual
    for (int i = 0; i < 15; i++) {
      final priceOffset = (i + 1) * (_currentPrice * 0.001); // 0.1% steps
      final price = _currentPrice + priceOffset;
      final amount = 0.1 + _random.nextDouble() * 2.0;

      _sellOrders.add(
        OrderBookEntry(
          price: price,
          amount: amount,
          total: price * amount,
          isBuy: false,
        ),
      );
    }

    _calculateSpread();
  }

  void _calculateSpread() {
    if (_buyOrders.isNotEmpty && _sellOrders.isNotEmpty) {
      final highestBid = _buyOrders.first.price;
      final lowestAsk = _sellOrders.first.price;
      _priceSpread = lowestAsk - highestBid;
    }
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _updateOrderBook();
      }
    });
  }

  void _updateOrderBook() {
    // Simular cambios en el libro de órdenes
    for (var order in _buyOrders) {
      if (_random.nextDouble() < 0.3) {
        // 30% chance de cambio
        order.amount = (order.amount * (0.8 + _random.nextDouble() * 0.4))
            .clamp(0.01, 10.0);
        order.total = order.price * order.amount;
      }
    }

    for (var order in _sellOrders) {
      if (_random.nextDouble() < 0.3) {
        // 30% chance de cambio
        order.amount = (order.amount * (0.8 + _random.nextDouble() * 0.4))
            .clamp(0.01, 10.0);
        order.total = order.price * order.amount;
      }
    }

    // Ocasionalmente agregar/quitar órdenes
    if (_random.nextDouble() < 0.1) {
      _generateInitialOrderBook();
    }

    setState(() {
      _calculateSpread();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Cambiar a min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: AppSpacing.md),
              _buildOrderBookHeader(isDark),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 350, // Altura fija para la lista de órdenes
                child: Column(
                  children: [
                    // Sell Orders (Ask) - arriba
                    SizedBox(height: 150, child: _buildSellOrders(isDark)),

                    // Precio actual y spread
                    _buildCurrentPrice(isDark),

                    // Buy Orders (Bid) - abajo
                    SizedBox(height: 150, child: _buildBuyOrders(isDark)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildOrderBookStats(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Icon(
          LucideIcons.bookOpen,
          color: AppColors.getPrimaryBlue(isDark),
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Order Book',
          style: AppTextStyles.h4.copyWith(
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
            color: AppColors.getSuccess(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Text(
            'Real-time',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getSuccess(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderBookHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
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
              'Total',
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

  Widget _buildSellOrders(bool isDark) {
    // Mostrar órdenes de venta (precios más altos) en orden descendente
    final reversedSellOrders = _sellOrders.reversed.take(8).toList();

    return ListView.builder(
      reverse: true, // Para que las órdenes más cercanas al precio estén abajo
      itemCount: reversedSellOrders.length,
      itemBuilder: (context, index) {
        final order = reversedSellOrders[index];
        return _buildOrderRow(order, isDark, false);
      },
    );
  }

  Widget _buildBuyOrders(bool isDark) {
    // Mostrar órdenes de compra (precios más bajos)
    return ListView.builder(
      itemCount: math.min(_buyOrders.length, 8),
      itemBuilder: (context, index) {
        final order = _buyOrders[index];
        return _buildOrderRow(order, isDark, true);
      },
    );
  }

  Widget _buildOrderRow(OrderBookEntry order, bool isDark, bool isBuyOrder) {
    final maxAmount = isBuyOrder
        ? _buyOrders.isNotEmpty
              ? _buyOrders.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
              : 1.0
        : _sellOrders.isNotEmpty
        ? _sellOrders.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    final fillPercentage = order.amount / maxAmount;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Stack(
        children: [
          // Background bar para mostrar profundidad
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * fillPercentage * 0.3,
                decoration: BoxDecoration(
                  color:
                      (isBuyOrder
                              ? AppColors.getBuyGreen(isDark)
                              : AppColors.getSellRed(isDark))
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Contenido de la fila
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    order.price.toStringAsFixed(_currentPrice >= 1 ? 2 : 4),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isBuyOrder
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    order.amount.toStringAsFixed(4),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    order.total.toStringAsFixed(0),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPrice(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryBlue(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: AppColors.getPrimaryBlue(isDark).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '\$${_currentPrice.toStringAsFixed(_currentPrice >= 1 ? 2 : 4)}',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getPrimaryBlue(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Spread: ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              Text(
                '\$${_priceSpread.toStringAsFixed(_currentPrice >= 1 ? 2 : 4)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' (${((_priceSpread / _currentPrice) * 100).toStringAsFixed(3)}%)',
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

  Widget _buildOrderBookStats(bool isDark) {
    final totalBuyVolume = _buyOrders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );
    final totalSellVolume = _sellOrders.fold<double>(
      0,
      (sum, order) => sum + order.total,
    );
    final buyPressure = totalBuyVolume / (totalBuyVolume + totalSellVolume);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy Pressure',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              Text(
                '${(buyPressure * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getBuyGreen(isDark),
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
                Expanded(
                  flex: (buyPressure * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: AppColors.getBuyGreen(isDark),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((1 - buyPressure) * 100).round(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy Vol: ${(totalBuyVolume / 1000).toStringAsFixed(1)}K',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getBuyGreen(isDark),
                ),
              ),
              Text(
                'Sell Vol: ${(totalSellVolume / 1000).toStringAsFixed(1)}K',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getSellRed(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderBookEntry {
  double price;
  double amount;
  double total;
  final bool isBuy;

  OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
    required this.isBuy,
  });
}
