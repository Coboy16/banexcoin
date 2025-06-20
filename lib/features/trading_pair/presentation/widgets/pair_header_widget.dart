import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PairHeaderWidget extends StatefulWidget {
  const PairHeaderWidget({super.key, required this.symbol});

  final String symbol;

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
      child: Icon(_getPairIcon(widget.symbol), color: Colors.white, size: 24),
    );
  }

  IconData _getPairIcon(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC/USDT':
        return LucideIcons.bitcoin;
      case 'ETH/USDT':
        return LucideIcons.hexagon;
      case 'BNB/USDT':
        return LucideIcons.triangle;
      case 'ADA/USDT':
        return LucideIcons.circle;
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
                widget.symbol,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _getPairDescription(widget.symbol),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getPairDescription(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC/USDT':
        return 'Bitcoin / Tether USD';
      case 'ETH/USDT':
        return 'Ethereum / Tether USD';
      case 'BNB/USDT':
        return 'Binance Coin / Tether USD';
      case 'ADA/USDT':
        return 'Cardano / Tether USD';
      default:
        return 'Cryptocurrency / Tether USD';
    }
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
      ],
    );
  }

  void _showAlertDialog() {
    // TODO: Implement alert dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Price Alert for ${widget.symbol}'),
        content: const Text('Alert functionality will be implemented here'),
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
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${widget.symbol}...'),
        duration: const Duration(seconds: 2),
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
