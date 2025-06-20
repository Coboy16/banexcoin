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
  double _availableBalance = 5000.0;
  double _estimatedFee = 0.0;
  double _estimatedTotal = 0.0;
  String _selectedPercentage = '';

  @override
  void initState() {
    super.initState();
    _tradeTabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _priceController = TextEditingController();

    _amountController.addListener(_calculateEstimates);
    _priceController.addListener(_calculateEstimates);
  }

  @override
  void dispose() {
    _tradeTabController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculateEstimates() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    setState(() {
      _estimatedTotal = amount * price;
      _estimatedFee = _estimatedTotal * 0.001; // 0.1% fee
    });
  }

  void _setPercentage(String percentage, double currentPrice) {
    setState(() {
      _selectedPercentage = percentage;
    });

    final percent = double.parse(percentage.replaceAll('%', '')) / 100;
    final maxAmount = _isBuySelected
        ? _availableBalance / currentPrice
        : _availableBalance;

    _amountController.text = (maxAmount * percent).toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return BlocBuilder<TradingPairBloc, TradingPairState>(
          builder: (context, state) {
            if (state is TradingPairLoaded) {
              final currentPrice = state.tradingPair.currentPrice;

              // Update price controller when market type is selected
              if (_tradeType == TradeType.market) {
                _priceController.text = currentPrice.toStringAsFixed(
                  currentPrice >= 1 ? 2 : 4,
                );
              }

              return SingleChildScrollView(
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
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: state.isStreaming
                  ? AppColors.getSuccess(isDark)
                  : AppColors.getWarning(isDark),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTypeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBuySelected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _isBuySelected
                      ? AppColors.getBuyGreen(isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  boxShadow: _isBuySelected
                      ? [
                          BoxShadow(
                            color: AppColors.getBuyGreen(
                              isDark,
                            ).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.arrowUp,
                      color: _isBuySelected
                          ? Colors.white
                          : AppColors.getBuyGreen(isDark),
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Buy',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: _isBuySelected
                            ? Colors.white
                            : AppColors.getTextMuted(isDark),
                        fontWeight: _isBuySelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBuySelected = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_isBuySelected
                      ? AppColors.getSellRed(isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  boxShadow: !_isBuySelected
                      ? [
                          BoxShadow(
                            color: AppColors.getSellRed(
                              isDark,
                            ).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.arrowDown,
                      color: !_isBuySelected
                          ? Colors.white
                          : AppColors.getSellRed(isDark),
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Sell',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: !_isBuySelected
                            ? Colors.white
                            : AppColors.getTextMuted(isDark),
                        fontWeight: !_isBuySelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: AppColors.getBorderSecondary(isDark)),
      ),
      child: Row(
        children: TradeType.values.map((type) {
          final isSelected = type == _tradeType;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tradeType = type),
              child: Container(
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
    final currentPrice = state.tradingPair.currentPrice;

    return Column(
      children: [
        if (_tradeType == TradeType.limit) ...[
          _buildInputField(
            label: 'Price (${state.tradingPair.quoteAsset})',
            controller: _priceController,
            isDark: isDark,
            suffix: state.tradingPair.quoteAsset,
            keyboardType: TextInputType.number,
            enabled: true,
          ),
          const SizedBox(height: AppSpacing.md),
        ] else ...[
          _buildInputField(
            label: 'Price (${state.tradingPair.quoteAsset})',
            controller: _priceController,
            isDark: isDark,
            suffix: state.tradingPair.quoteAsset,
            keyboardType: TextInputType.number,
            enabled: false,
            hint:
                'Market Price: \${currentPrice.toStringAsFixed(currentPrice >= 1 ? 2 : 4)}',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildInputField(
          label: _isBuySelected
              ? 'Amount (${state.tradingPair.quoteAsset})'
              : 'Amount (${state.tradingPair.baseAsset})',
          controller: _amountController,
          isDark: isDark,
          suffix: _isBuySelected
              ? state.tradingPair.quoteAsset
              : state.tradingPair.baseAsset,
          keyboardType: TextInputType.number,
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required String suffix,
    required TextInputType keyboardType,
    required bool enabled,
    String? hint,
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
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.getCardBackground(isDark)
                : AppColors.getSurfaceColor(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(
              color: enabled
                  ? AppColors.getBorderPrimary(isDark)
                  : AppColors.getBorderSecondary(isDark),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: hint ?? '0.00',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
              suffixText: suffix,
              suffixStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextMuted(isDark),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
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
              onTap: () => _setPercentage(percentage, currentPrice),
              child: Container(
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
    final currentPrice = state.tradingPair.currentPrice;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final price = _tradeType == TradeType.market
        ? currentPrice
        : (double.tryParse(_priceController.text) ?? currentPrice);

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
            '\${_availableBalance.toStringAsFixed(2)}',
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
            '\${price.toStringAsFixed(price >= 1 ? 2 : 4)}',
            isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            'Estimated Total:',
            '\${_estimatedTotal.toStringAsFixed(2)}',
            isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSummaryRow(
            'Trading Fee (0.1%):',
            '\${_estimatedFee.toStringAsFixed(2)}',
            isDark,
            isHighlighted: true,
          ),
          const Divider(),
          _buildSummaryRow(
            'You will ${_isBuySelected ? 'receive' : 'pay'}:',
            _isBuySelected
                ? '≈ ${(amount / price).toStringAsFixed(4)} ${state.tradingPair.baseAsset}'
                : '\${(_estimatedTotal + _estimatedFee).toStringAsFixed(2)}',
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
          style: AppTextStyles.bodySmall.copyWith(
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
    final isEnabled =
        _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.parse(_amountController.text) > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _executeTrade(state) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isBuySelected
              ? AppColors.getBuyGreen(isDark)
              : AppColors.getSellRed(isDark),
          disabledBackgroundColor: AppColors.getTextMuted(isDark),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.getBorderSecondary(isDark)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading trade data...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _executeTrade(TradingPairLoaded state) {
    final currentPrice = state.tradingPair.currentPrice;
    final price = _tradeType == TradeType.market
        ? currentPrice
        : (double.tryParse(_priceController.text) ?? currentPrice);

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
            Text('Price: \${price.toStringAsFixed(price >= 1 ? 2 : 4)}'),
            Text('Estimated Total: \${_estimatedTotal.toStringAsFixed(2)}'),
            Text('Fee: \${_estimatedFee.toStringAsFixed(2)}'),
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

    // Reset form
    _amountController.clear();
    setState(() {
      _selectedPercentage = '';
      _estimatedTotal = 0.0;
      _estimatedFee = 0.0;
    });
  }
}

enum TradeType { market, limit }
