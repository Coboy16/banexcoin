import 'package:banexcoin/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PairHeaderWidget extends StatefulWidget {
  const PairHeaderWidget({
    super.key,
    required this.symbol,
    required this.symbolInfo,
    required this.isStreaming,
  });

  final String symbol;
  final SymbolInfoTraiding symbolInfo;
  final bool isStreaming;

  @override
  State<PairHeaderWidget> createState() => _PairHeaderWidgetState();
}

class _PairHeaderWidgetState extends State<PairHeaderWidget> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Row(
          children: [
            _buildBackButton(isDark),
            const SizedBox(width: AppSpacing.sm),
            _buildPairIcon(isDark),
            const SizedBox(width: AppSpacing.md),
            _buildPairInfo(isDark),
            const Spacer(),
            _buildActionButtons(isDark),
          ],
        );
      },
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          LucideIcons.arrowLeft,
          color: AppColors.getTextMuted(isDark),
        ),
        tooltip: 'Back to Dashboard',
      ),
    );
  }

  Widget _buildPairIcon(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getPrimaryBlue(isDark),
            AppColors.getPrimaryBlue(isDark).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimaryBlue(isDark).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        _getPairIcon(widget.symbolInfo.baseAsset),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getPairIcon(String baseAsset) {
    switch (baseAsset.toUpperCase()) {
      case 'BTC':
        return LucideIcons.bitcoin;
      case 'ETH':
        return LucideIcons.hexagon;
      case 'BNB':
        return LucideIcons.triangle;
      case 'ADA':
        return LucideIcons.circle;
      case 'SOL':
        return LucideIcons.sun;
      case 'DOT':
        return LucideIcons.circle;
      case 'MATIC':
        return LucideIcons.pentagon;
      case 'AVAX':
        return LucideIcons.mountain;
      case 'LINK':
        return LucideIcons.link;
      case 'UNI':
        return LucideIcons.hexagon;
      default:
        return LucideIcons.coins;
    }
  }

  Widget _buildPairInfo(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.symbolInfo.baseAsset}/${widget.symbolInfo.quoteAsset}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildStreamingIndicator(isDark),
              const SizedBox(width: AppSpacing.sm),
              _buildStatusBadge(isDark),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _getPairDescription(
              widget.symbolInfo.baseAsset,
              widget.symbolInfo.quoteAsset,
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingIndicator(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: widget.isStreaming
            ? AppColors.getSuccess(isDark).withOpacity(0.1)
            : AppColors.getWarning(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: widget.isStreaming
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
              color: widget.isStreaming
                  ? AppColors.getSuccess(isDark)
                  : AppColors.getWarning(isDark),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.isStreaming ? 'LIVE' : 'CONNECTING',
            style: AppTextStyles.caption.copyWith(
              color: widget.isStreaming
                  ? AppColors.getSuccess(isDark)
                  : AppColors.getWarning(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    final isActive = widget.symbolInfo.status == 'TRADING';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.getInfo(isDark).withOpacity(0.1)
            : AppColors.getSellRed(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(
          color: isActive
              ? AppColors.getInfo(isDark).withOpacity(0.3)
              : AppColors.getSellRed(isDark).withOpacity(0.3),
        ),
      ),
      child: Text(
        widget.symbolInfo.status,
        style: AppTextStyles.caption.copyWith(
          color: isActive
              ? AppColors.getInfo(isDark)
              : AppColors.getSellRed(isDark),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getPairDescription(String baseAsset, String quoteAsset) {
    final baseNames = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'Binance Coin',
      'ADA': 'Cardano',
      'SOL': 'Solana',
      'DOT': 'Polkadot',
      'MATIC': 'Polygon',
      'AVAX': 'Avalanche',
      'LINK': 'Chainlink',
      'UNI': 'Uniswap',
    };

    final quoteNames = {
      'USDT': 'Tether USD',
      'USDC': 'USD Coin',
      'BUSD': 'Binance USD',
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'Binance Coin',
    };

    final baseName = baseNames[baseAsset.toUpperCase()] ?? baseAsset;
    final quoteName = quoteNames[quoteAsset.toUpperCase()] ?? quoteAsset;

    return '$baseName / $quoteName';
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        ActionButton(
          icon: _isFavorite ? LucideIcons.heart : LucideIcons.heart,
          label: 'Watchlist',
          isActive: _isFavorite,
          isDark: isDark,
          onPressed: () => setState(() => _isFavorite = !_isFavorite),
        ),
        const SizedBox(width: AppSpacing.sm),
        ActionButton(
          icon: LucideIcons.bell,
          label: 'Alert',
          isDark: isDark,
          onPressed: () => _showAlertDialog(),
        ),
        const SizedBox(width: AppSpacing.sm),
        ActionButton(
          icon: LucideIcons.share,
          label: 'Share',
          isDark: isDark,
          onPressed: () => _shareSymbol(),
        ),
        const SizedBox(width: AppSpacing.sm),
        ActionButton(
          icon: LucideIcons.refreshCcw,
          label: 'Refresh',
          isDark: isDark,
          onPressed: () => _refreshData(),
        ),
      ],
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Price Alert for ${widget.symbol}'),
        content: Text(
          'Alert functionality will be implemented here.\n\nCurrent status: ${widget.symbolInfo.status}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Set Alert'),
          ),
        ],
      ),
    );
  }

  void _shareSymbol() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing ${widget.symbol} (${widget.symbolInfo.baseAsset}/${widget.symbolInfo.quoteAsset})...',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refreshData() {
    // Trigger refresh in the BLoC
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshing ${widget.symbol} data...'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.getInfo(
          Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) {
          _animationController.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.getPrimaryBlue(widget.isDark)
                      : AppColors.getCardBackground(widget.isDark),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(
                    color: widget.isActive
                        ? AppColors.getPrimaryBlue(widget.isDark)
                        : _isHovered
                        ? AppColors.getBorderActive(widget.isDark)
                        : AppColors.getBorderPrimary(widget.isDark),
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.getPrimaryBlue(
                              widget.isDark,
                            ).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.isActive
                            ? Colors.white
                            : AppColors.getTextMuted(widget.isDark),
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isActive
                              ? Colors.white
                              : AppColors.getTextPrimary(widget.isDark),
                          fontWeight: widget.isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
