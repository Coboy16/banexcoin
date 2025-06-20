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
    _priceController.text = _getCurrentPrice().toStringAsFixed(2);

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

  double _getCurrentPrice() {
    switch (widget.symbol.toUpperCase()) {
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

  void _calculateEstimates() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? _getCurrentPrice();

    setState(() {
      _estimatedTotal = amount * price;
      _estimatedFee = _estimatedTotal * 0.001; // 0.1% fee
    });
  }

  void _setPercentage(String percentage) {
    setState(() {
      _selectedPercentage = percentage;
    });

    final percent = double.parse(percentage.replaceAll('%', '')) / 100;
    final maxAmount = _isBuySelected
        ? _availableBalance / _getCurrentPrice()
        : _availableBalance;

    _amountController.text = (maxAmount * percent).toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return SingleChildScrollView(
          // Agregar scroll para evitar overflow
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Cambiar a min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTradeTypeSelector(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildOrderTypeSelector(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildInputFields(isDark),
              const SizedBox(height: AppSpacing.md),
              _buildPercentageButtons(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildSummary(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildTradeButton(isDark),
            ],
          ),
        );
      },
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

  Widget _buildInputFields(bool isDark) {
    return Column(
      children: [
        if (_tradeType == TradeType.limit) ...[
          _buildInputField(
            label: 'Price (USDT)',
            controller: _priceController,
            isDark: isDark,
            suffix: 'USDT',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildInputField(
          label: _isBuySelected
              ? 'Amount (USDT)'
              : 'Amount (${_getCurrency()})',
          controller: _amountController,
          isDark: isDark,
          suffix: _isBuySelected ? 'USDT' : _getCurrency(),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  String _getCurrency() {
    return widget.symbol.split('/').first;
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required String suffix,
    required TextInputType keyboardType,
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
            color: AppColors.getCardBackground(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: AppColors.getBorderPrimary(isDark)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
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

  Widget _buildPercentageButtons(bool isDark) {
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
              onTap: () => _setPercentage(percentage),
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

  Widget _buildSummary(bool isDark) {
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
            '\$${_availableBalance.toStringAsFixed(2)}',
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
            '\$${_estimatedFee.toStringAsFixed(2)}',
            isDark,
            isHighlighted: true,
          ),
          const Divider(),
          _buildSummaryRow(
            'You will ${_isBuySelected ? 'receive' : 'pay'}:',
            _isBuySelected
                ? '≈ ${(_estimatedTotal / _getCurrentPrice()).toStringAsFixed(4)} ${_getCurrency()}'
                : '\$${(_estimatedTotal + _estimatedFee).toStringAsFixed(2)}',
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

  Widget _buildTradeButton(bool isDark) {
    final isEnabled =
        _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.parse(_amountController.text) > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _executeTrade : null,
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
          '${_isBuySelected ? 'Buy' : 'Sell'} ${_getCurrency()}',
          style: AppTextStyles.buttonMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _executeTrade() {
    // TODO: Implement actual trade execution
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${_isBuySelected ? 'Buy' : 'Sell'} Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symbol: ${widget.symbol}'),
            Text(
              'Type: ${_tradeType == TradeType.market ? 'Market' : 'Limit'}',
            ),
            Text('Amount: ${_amountController.text}'),
            if (_tradeType == TradeType.limit)
              Text('Price: \${_priceController.text}'),
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
              _showTradeSuccess();
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

  void _showTradeSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isBuySelected ? 'Buy' : 'Sell'} order placed successfully!',
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
