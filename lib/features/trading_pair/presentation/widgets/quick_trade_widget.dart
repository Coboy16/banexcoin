import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class QuickTradeWidget extends StatefulWidget {
  const QuickTradeWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<QuickTradeWidget> createState() => _QuickTradeWidgetState();
}

class _QuickTradeWidgetState extends State<QuickTradeWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tradeTabController;
  late TextEditingController _amountController;
  late TextEditingController _priceController;

  bool _isBuySelected = true;
  TradeType _tradeType = TradeType.market;

  // Balances de ejemplo
  double _availableQuoteBalance = 5000.00; // e.g., USDT
  double _availableBaseBalance = 0.5; // e.g., BTC

  String _selectedPercentage = '';

  // Variables de estado para los cálculos
  double _estimatedTotal = 0.0;
  double _estimatedFee = 0.0;
  double _receiveAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tradeTabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _priceController = TextEditingController();

    _amountController.addListener(_calculateEstimates);
    _priceController.addListener(_calculateEstimates);
    _tradeTabController.addListener(() {
      setState(() {
        _isBuySelected = _tradeTabController.index == 0;
        _amountController.clear();
        _selectedPercentage = '';
        _calculateEstimates();
      });
    });
  }

  @override
  void dispose() {
    _tradeTabController.dispose();
    _amountController.removeListener(_calculateEstimates);
    _priceController.removeListener(_calculateEstimates);
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculateEstimates() {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double price = double.tryParse(_priceController.text) ?? 0.0;
    const double feeRate = 0.001; // 0.1%

    double total = 0.0;
    double fee = 0.0;
    double receive = 0.0;

    if (amount > 0 && price > 0) {
      if (_isBuySelected) {
        // En "Buy", el 'amount' es el total que gastas en la moneda cotizada (USDT)
        total = amount;
        fee = total * feeRate;
        // Recibes la moneda base (BTC)
        receive = (total - fee) / price;
      } else {
        // En "Sell", el 'amount' es la cantidad de la moneda base que vendes (BTC)
        total = amount * price;
        fee = total * feeRate;
        // Recibes la moneda cotizada (USDT)
        receive = total - fee;
      }
    }

    setState(() {
      _estimatedTotal = total;
      _estimatedFee = fee;
      _receiveAmount = receive;
    });
  }

  void _setPercentage(String percentage, double currentPrice) {
    _selectedPercentage = percentage;
    final percent = double.parse(percentage.replaceAll('%', '')) / 100;

    double calculatedAmount = 0.0;

    if (_isBuySelected) {
      // Usar un % del balance en USDT para comprar
      calculatedAmount = _availableQuoteBalance * percent;
    } else {
      // Usar un % del balance en BTC para vender
      calculatedAmount = _availableBaseBalance * percent;
    }

    _amountController.text = calculatedAmount.toStringAsFixed(
      _isBuySelected ? 2 : 6, // Más decimales para cripto
    );
    _calculateEstimates(); // Recalcular todo con el nuevo monto
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return BlocConsumer<TradingPairBloc, TradingPairState>(
          listener: (context, state) {
            if (state is TradingPairLoaded && _tradeType == TradeType.market) {
              final currentPrice = state.tradingPair.currentPrice;
              _priceController.text = currentPrice.toStringAsFixed(
                currentPrice >= 1 ? 2 : 4,
              );
              _calculateEstimates();
            }
          },
          builder: (context, state) {
            if (state is TradingPairLoaded) {
              final currentPrice = state.tradingPair.currentPrice;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(color: AppColors.getBorderPrimary(isDark)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRealTimePriceHeader(isDark, state),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTradeTypeSelector(isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildOrderTypeSelector(isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInputFields(isDark, state),
                      const SizedBox(height: AppSpacing.md),
                      _buildPercentageButtons(isDark, currentPrice),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSummary(isDark, state),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTradeButton(isDark, state),
                    ],
                  ),
                ),
              );
            }

            return _buildLoadingState(isDark);
          },
        );
      },
    );
  }

  Widget _buildRealTimePriceHeader(bool isDark, TradingPairLoaded state) {
    final tradingPair = state.tradingPair;
    final isPositive = tradingPair.isPriceChangePositive;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Price',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '\$${tradingPair.currentPrice.toStringAsFixed(tradingPair.currentPrice >= 1 ? 2 : 4)}',
                style: AppTextStyles.h4.copyWith(
                  color: isPositive
                      ? AppColors.getBuyGreen(isDark)
                      : AppColors.getSellRed(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '24h Change',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTypeSelector(bool isDark) {
    return TabBar(
      controller: _tradeTabController,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        color: _isBuySelected
            ? AppColors.getBuyGreen(isDark)
            : AppColors.getSellRed(isDark),
        boxShadow: [
          BoxShadow(
            color:
                (_isBuySelected
                        ? AppColors.getBuyGreen(isDark)
                        : AppColors.getSellRed(isDark))
                    .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      labelColor: Colors.white,
      unselectedLabelColor: AppColors.getTextMuted(isDark),
      tabs: [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.arrowUp, size: 16),
              SizedBox(width: AppSpacing.sm),
              Text('Buy'),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.arrowDown, size: 16),
              SizedBox(width: AppSpacing.sm),
              Text('Sell'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        children: TradeType.values.map((type) {
          final isSelected = type == _tradeType;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tradeType = type;
                  if (type == TradeType.limit) {
                    _priceController.clear();
                  }
                  _calculateEstimates();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.getPrimaryBlue(isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  type == TradeType.market ? 'Market' : 'Limit',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.getTextMuted(isDark),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputFields(bool isDark, TradingPairLoaded state) {
    return Column(
      children: [
        _buildInputField(
          label: 'Price (${state.tradingPair.quoteAsset})',
          controller: _priceController,
          isDark: isDark,
          enabled: _tradeType == TradeType.limit,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInputField(
          label: _isBuySelected
              ? 'Total (${state.tradingPair.quoteAsset})'
              : 'Amount (${state.tradingPair.baseAsset})',
          controller: _amountController,
          isDark: isDark,
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: enabled,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? AppColors.getCardBackground(isDark)
                : AppColors.getSurfaceColor(isDark),
            hintText: '0.00',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(color: AppColors.getBorderPrimary(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(color: AppColors.getBorderPrimary(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(
                color: AppColors.getPrimaryBlue(isDark),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageButtons(bool isDark, double currentPrice) {
    final percentages = ['25%', '50%', '75%', '100%'];

    return Row(
      children: percentages.map((percentage) {
        final isSelected = _selectedPercentage == percentage;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: percentage == percentages.last ? 0 : AppSpacing.sm,
            ),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _setPercentage(percentage, currentPrice)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.getPrimaryBlue(isDark).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.getPrimaryBlue(isDark)
                        : AppColors.getBorderSecondary(isDark),
                  ),
                ),
                child: Text(
                  percentage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.getPrimaryBlue(isDark)
                        : AppColors.getTextPrimary(isDark),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummary(bool isDark, TradingPairLoaded state) {
    final price = double.tryParse(_priceController.text) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Available Balance:',
            _isBuySelected
                ? '\$${_availableQuoteBalance.toStringAsFixed(2)}'
                : '${_availableBaseBalance.toStringAsFixed(6)} ${state.tradingPair.baseAsset}',
            isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            'Order Type:',
            _tradeType == TradeType.market ? 'Market Order' : 'Limit Order',
            isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            'Estimated Price:',
            '\$${price.toStringAsFixed(price >= 1 ? 2 : 4)}',
            isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            'Estimated Total:',
            '\$${_estimatedTotal.toStringAsFixed(2)}',
            isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            'Trading Fee (0.1%):',
            '\$${_estimatedFee.toStringAsFixed(4)}',
            isDark,
            isHighlighted: true,
          ),
          const Divider(height: AppSpacing.lg, thickness: 1),
          _buildSummaryRow(
            _isBuySelected ? 'You will receive:' : 'You will pay:',
            _isBuySelected
                ? '≈ ${_receiveAmount.toStringAsFixed(6)} ${state.tradingPair.baseAsset}'
                : '≈ \$${_estimatedTotal.toStringAsFixed(2)}',
            isDark,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isHighlighted = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isHighlighted
                ? AppColors.getWarning(isDark)
                : AppColors.getTextPrimary(isDark),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTradeButton(bool isDark, TradingPairLoaded state) {
    final isEnabled = _estimatedTotal > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _executeTrade(state) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isBuySelected
              ? AppColors.getBuyGreen(isDark)
              : AppColors.getSellRed(isDark),
          disabledBackgroundColor: AppColors.getSurfaceColor(isDark),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          elevation: isEnabled ? 4 : 0,
        ),
        child: Text(
          '${_isBuySelected ? 'Buy' : 'Sell'} ${state.tradingPair.baseAsset}',
          style: AppTextStyles.buttonMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _executeTrade(TradingPairLoaded state) {
    final price = double.tryParse(_priceController.text) ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${_isBuySelected ? 'Buy' : 'Sell'} Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symbol: ${state.tradingPair.symbol}'),
            Text(
              'Type: ${_tradeType == TradeType.market ? 'Market' : 'Limit'}',
            ),
            Text('Side: ${_isBuySelected ? 'Buy' : 'Sell'}'),
            Text('Amount: ${_amountController.text}'),
            Text('Price: \$${price.toStringAsFixed(price >= 1 ? 2 : 4)}'),
            const Divider(),
            Text(
              'Estimated Total: \$${_estimatedTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Fee: \$${_estimatedFee.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showTradeSuccess(state);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBuySelected
                  ? AppColors.getBuyGreen(true)
                  : AppColors.getSellRed(true),
            ),
            child: Text('Confirm ${_isBuySelected ? 'Buy' : 'Sell'}'),
          ),
        ],
      ),
    );
  }

  void _showTradeSuccess(TradingPairLoaded state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isBuySelected ? 'Buy' : 'Sell'} order for ${state.tradingPair.symbol} placed successfully!',
        ),
        backgroundColor: _isBuySelected
            ? AppColors.getBuyGreen(true)
            : AppColors.getSellRed(true),
        duration: const Duration(seconds: 3),
      ),
    );

    _amountController.clear();
    setState(() {
      _selectedPercentage = '';
    });
  }
}

enum TradeType { market, limit }
