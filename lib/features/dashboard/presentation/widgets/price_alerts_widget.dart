import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PriceAlertsWidget extends StatefulWidget {
  const PriceAlertsWidget({super.key});

  @override
  State<PriceAlertsWidget> createState() => _PriceAlertsWidgetState();
}

class _PriceAlertsWidgetState extends State<PriceAlertsWidget> {
  List<AlertData> _alerts = [];

  @override
  void initState() {
    super.initState();
    _generateInitialAlerts();
  }

  void _generateInitialAlerts() {
    // Generar alertas iniciales simuladas basadas en precios realistas
    _alerts = [
      AlertData(
        id: '1',
        pair: 'BTC/USDT',
        targetPrice: 45000.0,
        type: AlertType.above,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isTriggered: false,
      ),
      AlertData(
        id: '2',
        pair: 'ETH/USDT',
        targetPrice: 2500.0,
        type: AlertType.below,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isTriggered: false,
      ),
      AlertData(
        id: '3',
        pair: 'BNB/USDT',
        targetPrice: 320.0,
        type: AlertType.above,
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isTriggered: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, marketState) {
            // Actualizar precios actuales con datos reales si están disponibles
            if (marketState is MarketDataLoaded) {
              _updateCurrentPrices(marketState);
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(isDark),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: AppColors.getBorderPrimary(isDark)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, marketState),
                  const Divider(height: 1),
                  _buildAlertsList(isDark, marketState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateCurrentPrices(MarketDataLoaded marketState) {
    for (final alert in _alerts) {
      final symbol = alert.pair.replaceAll('/', '');
      final ticker = marketState.tickers[symbol];

      if (ticker != null) {
        try {
          alert.currentPrice = double.parse(ticker.lastPrice);

          // Verificar si la alerta debe ser activada
          if (alert.isActive && !alert.isTriggered) {
            final shouldTrigger = _shouldTriggerAlert(alert);
            if (shouldTrigger) {
              alert.isTriggered = true;
              _showAlertNotification(alert);
            }
          }
        } catch (e) {
          // Si hay error en parsing, mantener precio anterior
        }
      }
    }
  }

  bool _shouldTriggerAlert(AlertData alert) {
    if (alert.type == AlertType.above) {
      return alert.currentPrice >= alert.targetPrice;
    } else {
      return alert.currentPrice <= alert.targetPrice;
    }
  }

  void _showAlertNotification(AlertData alert) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      title: Text(
        '🚨 Price Alert Triggered!',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      description: Text(
        '${alert.pair} is now ${alert.type == AlertType.above ? 'above' : 'below'} \${_formatPrice(alert.targetPrice)}',
        style: const TextStyle(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 6),
      animationDuration: const Duration(milliseconds: 400),
      showIcon: true,
      icon: Icon(LucideIcons.bellRing, color: Colors.white),
      showProgressBar: true,
      progressBarTheme: const ProgressIndicatorThemeData(color: Colors.white70),
      closeButtonShowType: CloseButtonShowType.onHover,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) {
          // TODO: Navigate to detailed view or trading page
          debugPrint('Alert tapped: ${alert.pair}');
        },
        onCloseButtonTap: (toastItem) {
          toastification.dismiss(toastItem);
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, MarketDataState marketState) {
    final activeAlerts = _alerts.where((alert) => alert.isActive).length;
    final triggeredAlerts = _alerts.where((alert) => alert.isTriggered).length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Stack(
            children: [
              Icon(
                LucideIcons.bell,
                color: AppColors.getTextPrimary(isDark),
                size: 20,
              ),
              if (triggeredAlerts > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.getError(isDark),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Price Alerts',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (activeAlerts > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.getInfo(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$activeAlerts',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          if (marketState is MarketDataLoaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: marketState.isConnected
                    ? AppColors.getBuyGreen(isDark).withOpacity(0.1)
                    : AppColors.getError(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: marketState.isConnected
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getError(isDark),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    marketState.isConnected ? 'Live' : 'Offline',
                    style: AppTextStyles.caption.copyWith(
                      color: marketState.isConnected
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getError(isDark),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildAlertsList(bool isDark, MarketDataState marketState) {
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

    // Ordenar alertas: primero las activadas, luego las triggered, luego por fecha
    final sortedAlerts = List<AlertData>.from(_alerts);
    sortedAlerts.sort((a, b) {
      if (a.isActive != b.isActive) {
        return a.isActive ? -1 : 1;
      }
      if (a.isTriggered != b.isTriggered) {
        return a.isTriggered ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return Column(
      children: sortedAlerts
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
      if (!alert.isActive) {
        alert.isTriggered = false;
      }
    });
  }

  void _deleteAlert(AlertData alert) {
    setState(() {
      _alerts.removeWhere((a) => a.id == alert.id);
    });

    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.minimal,
      title: Text('Alert Deleted'),
      description: Text('Alert for ${alert.pair} has been removed'),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 300),
      showIcon: true,
      icon: Icon(LucideIcons.trash2),
      showProgressBar: false,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) {
          // Undo deletion
          setState(() {
            _alerts.add(alert);
          });
          toastification.dismiss(toastItem);

          // Show confirmation toast
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.minimal,
            title: Text('Alert Restored'),
            description: Text('${alert.pair} alert has been restored'),
            alignment: Alignment.bottomCenter,
            autoCloseDuration: const Duration(seconds: 3),
            animationDuration: const Duration(milliseconds: 300),
            showIcon: true,
            showProgressBar: false,
          );
        },
      ),
    );
  }

  void _editAlert(AlertData alert) {
    _showAddAlertDialog(editingAlert: alert);
  }

  void _showAddAlertDialog({AlertData? editingAlert}) {
    final pairController = TextEditingController(
      text: editingAlert?.pair ?? '',
    );
    final priceController = TextEditingController(
      text: editingAlert?.targetPrice.toString() ?? '',
    );
    AlertType selectedType = editingAlert?.type ?? AlertType.above;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editingAlert == null ? 'Add Price Alert' : 'Edit Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: pairController,
                decoration: const InputDecoration(
                  labelText: 'Trading Pair',
                  hintText: 'e.g., BTC/USDT',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Target Price',
                  hintText: 'e.g., 45000',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Alert Type:'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<AlertType>(
                      title: const Text('Above'),
                      value: AlertType.above,
                      groupValue: selectedType,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<AlertType>(
                      title: const Text('Below'),
                      value: AlertType.below,
                      groupValue: selectedType,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final pair = pairController.text.trim();
                final priceText = priceController.text.trim();

                if (pair.isNotEmpty && priceText.isNotEmpty) {
                  try {
                    final price = double.parse(priceText);

                    if (editingAlert == null) {
                      // Add new alert
                      final newAlert = AlertData(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        pair: pair,
                        targetPrice: price,
                        type: selectedType,
                        isActive: true,
                        createdAt: DateTime.now(),
                        isTriggered: false,
                      );

                      setState(() {
                        _alerts.add(newAlert);
                      });
                    } else {
                      // Edit existing alert
                      setState(() {
                        editingAlert.pair = pair;
                        editingAlert.targetPrice = price;
                        editingAlert.type = selectedType;
                        editingAlert.isTriggered = false;
                      });
                    }

                    Navigator.pop(context);

                    // Show success toast
                    toastification.show(
                      context: context,
                      type: editingAlert == null
                          ? ToastificationType.success
                          : ToastificationType.info,
                      style: ToastificationStyle.minimal,
                      title: Text(
                        editingAlert == null
                            ? 'Alert Created'
                            : 'Alert Updated',
                      ),
                      description: Text(
                        editingAlert == null
                            ? 'New alert for $pair has been created'
                            : 'Alert for $pair has been updated',
                      ),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 4),
                      animationDuration: const Duration(milliseconds: 300),
                      showIcon: true,
                      showProgressBar: false,
                    );
                  } catch (e) {
                    // Show error toast for invalid price
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.minimal,
                      title: Text('Invalid Price'),
                      description: Text('Please enter a valid numeric price'),
                      alignment: Alignment.topCenter,
                      autoCloseDuration: const Duration(seconds: 3),
                      animationDuration: const Duration(milliseconds: 300),
                      showIcon: true,
                      showProgressBar: false,
                    );
                  }
                }
              },
              child: Text(editingAlert == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }
}

enum AlertType { above, below }

class AlertData {
  String id;
  String pair;
  double targetPrice;
  double currentPrice;
  AlertType type;
  bool isActive;
  DateTime createdAt;
  bool isTriggered;

  AlertData({
    required this.id,
    required this.pair,
    required this.targetPrice,
    this.currentPrice = 0.0,
    required this.type,
    required this.isActive,
    required this.createdAt,
    required this.isTriggered,
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
    final priceDistance = _getPriceDistance();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.alert.isTriggered
              ? AppColors.getWarning(widget.isDark).withOpacity(0.05)
              : _isHovered
              ? AppColors.getSurfaceColor(widget.isDark).withOpacity(0.5)
              : Colors.transparent,
          border: widget.alert.isTriggered
              ? Border(
                  left: BorderSide(
                    color: AppColors.getWarning(widget.isDark),
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildAlertIcon(isNearTarget),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildAlertInfo(isNearTarget, priceDistance)),
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

    if (widget.alert.isTriggered) {
      iconColor = AppColors.getWarning(widget.isDark);
      iconData = LucideIcons.bellRing;
    } else if (!widget.alert.isActive) {
      iconColor = AppColors.getTextMuted(widget.isDark);
      iconData = LucideIcons.bellOff;
    } else if (isNearTarget) {
      iconColor = AppColors.getWarning(widget.isDark);
      iconData = LucideIcons.bell;
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

  Widget _buildAlertInfo(bool isNearTarget, String priceDistance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.alert.pair,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextPrimary(widget.isDark),
                fontWeight: FontWeight.w600,
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
                  fontSize: 10,
                ),
              ),
            ),
            if (widget.alert.isTriggered) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getWarning(widget.isDark),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  'TRIGGERED',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ] else if (isNearTarget) ...[
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
                    fontSize: 9,
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
              'Target: \$${_formatPrice(widget.alert.targetPrice)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(widget.isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Current: \$${_formatPrice(widget.alert.currentPrice)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.getTextSecondary(widget.isDark),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              priceDistance,
              style: AppTextStyles.caption.copyWith(
                color: isNearTarget
                    ? AppColors.getWarning(widget.isDark)
                    : AppColors.getTextMuted(widget.isDark),
                fontSize: 10,
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
    if (!widget.alert.isActive || widget.alert.currentPrice == 0) return false;

    final percentDifference =
        ((widget.alert.currentPrice - widget.alert.targetPrice).abs() /
            widget.alert.targetPrice) *
        100;
    return percentDifference <= 5.0;
  }

  String _getPriceDistance() {
    if (widget.alert.currentPrice == 0) return '';

    final difference = widget.alert.targetPrice - widget.alert.currentPrice;
    final percentDifference = (difference / widget.alert.currentPrice) * 100;

    if (difference > 0) {
      return '+${percentDifference.toStringAsFixed(1)}% to go';
    } else {
      return '${percentDifference.toStringAsFixed(1)}% below';
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }
}
