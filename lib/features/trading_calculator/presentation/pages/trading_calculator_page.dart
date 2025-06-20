import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '/core/core.dart';

class TradingCalculatorPage extends StatefulWidget {
  const TradingCalculatorPage({super.key});

  @override
  State<TradingCalculatorPage> createState() => _TradingCalculatorPageState();
}

class _TradingCalculatorPageState extends State<TradingCalculatorPage> {
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedPair = 'BTC/USDT';
  String _selectedAction = 'Buy';
  double _currentPrice = 43250.00;
  double _tradingFee = 0.1; // 0.1%
  double _calculatedAmount = 0.0;
  double _totalCost = 0.0;
  double _feeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _priceController.text = _currentPrice.toStringAsFixed(2);
    _amountController.addListener(_calculateTrade);
    _priceController.addListener(_calculateTrade);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculateTrade() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    setState(() {
      if (_selectedAction == 'Buy') {
        // Buying with USDT, calculating BTC received
        _totalCost = amount;
        _feeAmount = amount * (_tradingFee / 100);
        final netAmount = amount - _feeAmount;
        _calculatedAmount = price > 0 ? netAmount / price : 0.0;
      } else {
        // Selling BTC, calculating USDT received
        _calculatedAmount = amount;
        final grossAmount = amount * price;
        _feeAmount = grossAmount * (_tradingFee / 100);
        _totalCost = grossAmount - _feeAmount;
      }
    });
  }

  void _switchAction(String action) {
    setState(() {
      _selectedAction = action;
      _amountController.clear();
      _calculateTrade();
    });
  }

  void _setPercentage(double percentage) {
    // Mock available balance
    final availableBalance = _selectedAction == 'Buy' ? 10000.0 : 0.25;
    final amount = availableBalance * (percentage / 100);

    _amountController.text = amount.toStringAsFixed(
      _selectedAction == 'Buy' ? 2 : 6,
    );
    _calculateTrade();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: AppSpacing.xl),

          ResponsiveRowColumn(
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
                    // Main calculator
                    _buildMainCalculator(),

                    const SizedBox(height: AppSpacing.lg),

                    // Advanced calculator
                    const AdvancedCalculatorWidget(),
                  ],
                ),
              ),

              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Column(
                  children: [
                    // Market prices
                    const MarketPricesWidget(),

                    const SizedBox(height: AppSpacing.lg),

                    // Calculator history
                    const CalculatorHistoryWidget(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trading Calculator', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Calculate your trades and fees before executing',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),

        // Quick tools
        Row(
          children: [
            _QuickToolButton(
              icon: LucideIcons.calculator,
              label: 'P&L Calculator',
              onPressed: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickToolButton(
              icon: LucideIcons.percent,
              label: 'Fee Calculator',
              onPressed: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickToolButton(
              icon: LucideIcons.target,
              label: 'Risk Calculator',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCalculator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Trade Calculator', style: AppTextStyles.h3),
              const Spacer(),

              // Pair selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.borderSecondary),
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
                        // Update price based on pair
                        _currentPrice = value == 'BTC/USDT'
                            ? 43250.00
                            : value == 'ETH/USDT'
                            ? 2650.00
                            : 315.50;
                        _priceController.text = _currentPrice.toStringAsFixed(
                          2,
                        );
                        _calculateTrade();
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Buy/Sell toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchAction('Buy'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedAction == 'Buy'
                            ? AppColors.buyGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.arrowUp,
                            color: _selectedAction == 'Buy'
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Buy',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: _selectedAction == 'Buy'
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchAction('Sell'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedAction == 'Sell'
                            ? AppColors.sellRed
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.arrowDown,
                            color: _selectedAction == 'Sell'
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Sell',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: _selectedAction == 'Sell'
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Input fields
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedAction == 'Buy'
                          ? 'Amount to spend (USDT)'
                          : 'Amount to sell (${_selectedPair.split('/')[0]})',
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        suffixText: _selectedAction == 'Buy'
                            ? 'USDT'
                            : _selectedPair.split('/')[0],
                        suffixStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price (USDT)', style: AppTextStyles.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        suffixText: 'USDT',
                        suffixStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _priceController.text = _currentPrice
                                .toStringAsFixed(2);
                            _calculateTrade();
                          },
                          icon: const Icon(
                            LucideIcons.refreshCw,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Percentage buttons
          Row(
            children: [
              Text('Quick amounts:', style: AppTextStyles.labelMedium),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _PercentageButton(
                        percentage: 25,
                        onPressed: () => _setPercentage(25),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PercentageButton(
                        percentage: 50,
                        onPressed: () => _setPercentage(50),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PercentageButton(
                        percentage: 75,
                        onPressed: () => _setPercentage(75),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PercentageButton(
                        percentage: 100,
                        onPressed: () => _setPercentage(100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Results section
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.borderSecondary),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Calculation Results', style: AppTextStyles.h4),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Text(
                        'Fee: ${_tradingFee.toStringAsFixed(1)}%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                _ResultRow(
                  label: _selectedAction == 'Buy'
                      ? 'You will receive:'
                      : 'You will get:',
                  value: _selectedAction == 'Buy'
                      ? '${_calculatedAmount.toStringAsFixed(6)} ${_selectedPair.split('/')[0]}'
                      : '${_totalCost.toStringAsFixed(2)} USDT',
                  valueColor: _selectedAction == 'Buy'
                      ? AppColors.buyGreen
                      : AppColors.sellRed,
                ),

                const Divider(height: AppSpacing.lg),

                _ResultRow(
                  label: 'Trading fee:',
                  value: '${_feeAmount.toStringAsFixed(2)} USDT',
                  valueColor: AppColors.accentYellow,
                ),

                const Divider(height: AppSpacing.lg),

                _ResultRow(
                  label: _selectedAction == 'Buy'
                      ? 'Total cost:'
                      : 'Net received:',
                  value: _selectedAction == 'Buy'
                      ? '${(double.tryParse(_amountController.text) ?? 0.0).toStringAsFixed(2)} USDT'
                      : '${_totalCost.toStringAsFixed(2)} USDT',
                  valueColor: AppColors.textPrimary,
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Execute trade or save calculation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAction == 'Buy'
                    ? AppColors.buyGreen
                    : AppColors.sellRed,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedAction == 'Buy'
                        ? LucideIcons.shoppingCart
                        : LucideIcons.dollarSign,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _selectedAction == 'Buy'
                        ? 'Execute Buy Order'
                        : 'Execute Sell Order',
                    style: AppTextStyles.buttonMedium,
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

class _QuickToolButton extends StatelessWidget {
  const _QuickToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentageButton extends StatelessWidget {
  const _PercentageButton({required this.percentage, required this.onPressed});

  final int percentage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSecondary),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              '${percentage}%',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)
              : AppTextStyles.bodyMedium,
        ),
        AutoSizeText(
          value,
          style: (isTotal ? AppTextStyles.h4 : AppTextStyles.bodyMedium)
              .copyWith(color: valueColor, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
      ],
    );
  }
}

class AdvancedCalculatorWidget extends StatefulWidget {
  const AdvancedCalculatorWidget({super.key});

  @override
  State<AdvancedCalculatorWidget> createState() =>
      _AdvancedCalculatorWidgetState();
}

class _AdvancedCalculatorWidgetState extends State<AdvancedCalculatorWidget> {
  final _entryPriceController = TextEditingController();
  final _exitPriceController = TextEditingController();
  final _positionSizeController = TextEditingController();

  double _pnlAmount = 0.0;
  double _pnlPercentage = 0.0;
  double _roe = 0.0;

  @override
  void initState() {
    super.initState();
    _entryPriceController.addListener(_calculatePnL);
    _exitPriceController.addListener(_calculatePnL);
    _positionSizeController.addListener(_calculatePnL);
  }

  @override
  void dispose() {
    _entryPriceController.dispose();
    _exitPriceController.dispose();
    _positionSizeController.dispose();
    super.dispose();
  }

  void _calculatePnL() {
    final entryPrice = double.tryParse(_entryPriceController.text) ?? 0.0;
    final exitPrice = double.tryParse(_exitPriceController.text) ?? 0.0;
    final positionSize = double.tryParse(_positionSizeController.text) ?? 0.0;

    if (entryPrice > 0 && exitPrice > 0 && positionSize > 0) {
      setState(() {
        _pnlAmount = (exitPrice - entryPrice) * positionSize;
        _pnlPercentage = ((exitPrice - entryPrice) / entryPrice) * 100;
        _roe = _pnlPercentage; // Simplified ROE calculation
      });
    } else {
      setState(() {
        _pnlAmount = 0.0;
        _pnlPercentage = 0.0;
        _roe = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('P&L Calculator', style: AppTextStyles.h3),

          const SizedBox(height: AppSpacing.lg),

          // Input fields
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entry Price (USDT)',
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _entryPriceController,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        suffixText: 'USDT',
                      ),
                      style: AppTextStyles.bodyMedium,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exit Price (USDT)', style: AppTextStyles.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _exitPriceController,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        suffixText: 'USDT',
                      ),
                      style: AppTextStyles.bodyMedium,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Position Size (BTC)', style: AppTextStyles.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _positionSizeController,
                decoration: const InputDecoration(
                  hintText: '0.00000000',
                  suffixText: 'BTC',
                ),
                style: AppTextStyles.bodyMedium,
                keyboardType: TextInputType.number,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Results
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'P&L Amount:',
                  value:
                      '${_pnlAmount >= 0 ? '+' : ''}${_pnlAmount.toStringAsFixed(2)} USDT',
                  valueColor: _pnlAmount >= 0
                      ? AppColors.buyGreen
                      : AppColors.sellRed,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ResultRow(
                  label: 'P&L Percentage:',
                  value:
                      '${_pnlPercentage >= 0 ? '+' : ''}${_pnlPercentage.toStringAsFixed(2)}%',
                  valueColor: _pnlPercentage >= 0
                      ? AppColors.buyGreen
                      : AppColors.sellRed,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ResultRow(
                  label: 'ROE:',
                  value: '${_roe >= 0 ? '+' : ''}${_roe.toStringAsFixed(2)}%',
                  valueColor: _roe >= 0
                      ? AppColors.buyGreen
                      : AppColors.sellRed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarketPricesWidget extends StatelessWidget {
  const MarketPricesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final prices = [
      _PriceData(symbol: 'BTC/USDT', price: 43250.00, change: 2.5),
      _PriceData(symbol: 'ETH/USDT', price: 2650.00, change: -1.2),
      _PriceData(symbol: 'BNB/USDT', price: 315.50, change: 4.7),
      _PriceData(symbol: 'ADA/USDT', price: 0.4850, change: 8.3),
    ];

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
            child: Row(
              children: [
                Text('Current Prices', style: AppTextStyles.h4),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
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

          const Divider(height: 1),

          ...prices.map((price) => _PriceRow(price: price)),
        ],
      ),
    );
  }
}

class _PriceData {
  final String symbol;
  final double price;
  final double change;

  _PriceData({required this.symbol, required this.price, required this.change});
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price});

  final _PriceData price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              price.symbol,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\${price.price.toStringAsFixed(price.price < 1 ? 4 : 2)}',
                style: AppTextStyles.priceSmall,
              ),
              Text(
                '${price.change >= 0 ? '+' : ''}${price.change.toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  color: price.change >= 0
                      ? AppColors.buyGreen
                      : AppColors.sellRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CalculatorHistoryWidget extends StatelessWidget {
  const CalculatorHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      _CalculationData(
        action: 'Buy',
        pair: 'BTC/USDT',
        amount: '1000.00 USDT',
        result: '0.0231 BTC',
        time: '2 min ago',
      ),
      _CalculationData(
        action: 'Sell',
        pair: 'ETH/USDT',
        amount: '0.5 ETH',
        result: '1325.00 USDT',
        time: '15 min ago',
      ),
      _CalculationData(
        action: 'Buy',
        pair: 'BNB/USDT',
        amount: '500.00 USDT',
        result: '1.58 BNB',
        time: '1 hour ago',
      ),
    ];

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
            child: Row(
              children: [
                Text('Recent Calculations', style: AppTextStyles.h4),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Clear All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          ...history.map((calc) => _CalculationRow(calculation: calc)),

          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.calculator,
                      color: AppColors.textMuted,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No calculations yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
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

class _CalculationData {
  final String action;
  final String pair;
  final String amount;
  final String result;
  final String time;

  _CalculationData({
    required this.action,
    required this.pair,
    required this.amount,
    required this.result,
    required this.time,
  });
}

class _CalculationRow extends StatelessWidget {
  const _CalculationRow({required this.calculation});

  final _CalculationData calculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderPrimary)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  (calculation.action == 'Buy'
                          ? AppColors.buyGreen
                          : AppColors.sellRed)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(
              calculation.action == 'Buy'
                  ? LucideIcons.arrowUp
                  : LucideIcons.arrowDown,
              color: calculation.action == 'Buy'
                  ? AppColors.buyGreen
                  : AppColors.sellRed,
              size: 16,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${calculation.action} ${calculation.pair}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${calculation.amount} → ${calculation.result}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          Text(calculation.time, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
