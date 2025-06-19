import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PriceAlertsWidget extends StatefulWidget {
  const PriceAlertsWidget({super.key});

  @override
  State<PriceAlertsWidget> createState() => _PriceAlertsWidgetState();
}

class _PriceAlertsWidgetState extends State<PriceAlertsWidget> {
  final List<AlertData> _alerts = [
    AlertData(
      id: '1',
      pair: 'BTC/USDT',
      targetPrice: '45,000',
      currentPrice: '43,250',
      type: AlertType.above,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AlertData(
      id: '2',
      pair: 'ETH/USDT',
      targetPrice: '2,500',
      currentPrice: '2,650',
      type: AlertType.below,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AlertData(
      id: '3',
      pair: 'BNB/USDT',
      targetPrice: '320',
      currentPrice: '315.50',
      type: AlertType.above,
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.getBorderPrimary(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const Divider(height: 1),
              _buildAlertsList(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            LucideIcons.bell,
            color: AppColors.getTextPrimary(isDark),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Price Alerts',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showAddAlertDialog(),
            icon: Icon(
              LucideIcons.plus,
              color: AppColors.getPrimaryBlue(isDark),
              size: 16,
            ),
            tooltip: 'Add Alert',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(bool isDark) {
    if (_alerts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.bellOff,
                color: AppColors.getTextMuted(isDark),
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No active alerts',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => _showAddAlertDialog(),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add your first alert'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _alerts
          .map(
            (alert) => AlertRow(
              alert: alert,
              isDark: isDark,
              onToggle: () => _toggleAlert(alert),
              onDelete: () => _deleteAlert(alert),
              onEdit: () => _editAlert(alert),
            ),
          )
          .toList(),
    );
  }

  void _toggleAlert(AlertData alert) {
    setState(() {
      alert.isActive = !alert.isActive;
    });
  }

  void _deleteAlert(AlertData alert) {
    setState(() {
      _alerts.removeWhere((a) => a.id == alert.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert for ${alert.pair} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _alerts.add(alert);
            });
          },
        ),
      ),
    );
  }

  void _editAlert(AlertData alert) {
    _showAddAlertDialog(editingAlert: alert);
  }

  void _showAddAlertDialog({AlertData? editingAlert}) {
    // TODO: Implement add/edit alert dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editingAlert == null ? 'Add Price Alert' : 'Edit Alert'),
        content: const Text('Alert dialog will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Save alert
            },
            child: Text(editingAlert == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}

enum AlertType { above, below }

class AlertData {
  final String id;
  final String pair;
  final String targetPrice;
  final String currentPrice;
  final AlertType type;
  bool isActive;
  final DateTime createdAt;

  AlertData({
    required this.id,
    required this.pair,
    required this.targetPrice,
    required this.currentPrice,
    required this.type,
    required this.isActive,
    required this.createdAt,
  });
}

class AlertRow extends StatefulWidget {
  const AlertRow({
    super.key,
    required this.alert,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final AlertData alert;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  State<AlertRow> createState() => _AlertRowState();
}

class _AlertRowState extends State<AlertRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isNearTarget = _isNearTarget();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.getSurfaceColor(widget.isDark).withOpacity(0.5)
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildAlertIcon(isNearTarget),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildAlertInfo(isNearTarget)),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertIcon(bool isNearTarget) {
    Color iconColor;
    IconData iconData;

    if (!widget.alert.isActive) {
      iconColor = AppColors.getTextMuted(widget.isDark);
      iconData = LucideIcons.bellOff;
    } else if (isNearTarget) {
      iconColor = AppColors.getWarning(widget.isDark);
      iconData = LucideIcons.bellRing;
    } else {
      iconColor = AppColors.getInfo(widget.isDark);
      iconData = LucideIcons.bell;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Icon(iconData, color: iconColor, size: 16),
    );
  }

  Widget _buildAlertInfo(bool isNearTarget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.alert.pair,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextPrimary(widget.isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getAlertTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Text(
                widget.alert.type == AlertType.above ? 'Above' : 'Below',
                style: AppTextStyles.caption.copyWith(
                  color: _getAlertTypeColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isNearTarget) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getWarning(widget.isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  'NEAR',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getWarning(widget.isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Text(
              'Target: \${widget.alert.targetPrice}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(widget.isDark),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Current: \${widget.alert.currentPrice}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(widget.isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle switch
        Switch(
          value: widget.alert.isActive,
          onChanged: (_) => widget.onToggle(),
          activeColor: AppColors.getSuccess(widget.isDark),
          inactiveThumbColor: AppColors.getTextMuted(widget.isDark),
          inactiveTrackColor: AppColors.getBorderSecondary(widget.isDark),
        ),

        if (_isHovered) ...[
          const SizedBox(width: AppSpacing.sm),
          // Edit button
          IconButton(
            onPressed: widget.onEdit,
            icon: Icon(
              LucideIcons.settings2,
              size: 16,
              color: AppColors.getTextMuted(widget.isDark),
            ),
            tooltip: 'Edit Alert',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          // Delete button
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(
              LucideIcons.trash2,
              size: 16,
              color: AppColors.getError(widget.isDark),
            ),
            tooltip: 'Delete Alert',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ],
    );
  }

  Color _getAlertTypeColor() {
    return widget.alert.type == AlertType.above
        ? AppColors.getBuyGreen(widget.isDark)
        : AppColors.getSellRed(widget.isDark);
  }

  bool _isNearTarget() {
    if (!widget.alert.isActive) return false;

    try {
      final current = double.parse(
        widget.alert.currentPrice.replaceAll(',', ''),
      );
      final target = double.parse(widget.alert.targetPrice.replaceAll(',', ''));

      final percentDifference = ((current - target).abs() / target) * 100;

      // Consider "near" if within 5% of target
      return percentDifference <= 5.0;
    } catch (e) {
      return false;
    }
  }
}
