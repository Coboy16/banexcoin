import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class RecentActivitiesWidget extends StatefulWidget {
  const RecentActivitiesWidget({super.key});

  @override
  State<RecentActivitiesWidget> createState() => _RecentActivitiesWidgetState();
}

class _RecentActivitiesWidgetState extends State<RecentActivitiesWidget> {
  late Timer _activityTimer;
  final Random _random = Random();

  final List<ActivityData> _activities = [
    ActivityData(
      type: 'Buy',
      pair: 'BTC/USDT',
      amount: '0.0523',
      price: '43,150.00',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      isPositive: true,
      id: '1',
    ),
    ActivityData(
      type: 'Sell',
      pair: 'ETH/USDT',
      amount: '1.25',
      price: '2,665.00',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      isPositive: false,
      id: '2',
    ),
    ActivityData(
      type: 'Buy',
      pair: 'BNB/USDT',
      amount: '5.8',
      price: '312.25',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isPositive: true,
      id: '3',
    ),
    ActivityData(
      type: 'Buy',
      pair: 'BNB/USDT',
      amount: '5.8',
      price: '312.25',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isPositive: true,
      id: '4',
    ),
    ActivityData(
      type: 'Buy',
      pair: 'BNB/USDT',
      amount: '5.8',
      price: '312.25',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isPositive: true,
      id: '5',
    ),
    ActivityData(
      type: 'Sell',
      pair: 'ETH/USDT',
      amount: '1.25',
      price: '2,665.00',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      isPositive: false,
      id: '6',
    ),
  ];

  final List<String> _tradingPairs = [
    'BTC/USDT',
    'ETH/USDT',
    'BNB/USDT',
    'ADA/USDT',
    'SOL/USDT',
    'DOT/USDT',
  ];

  @override
  void initState() {
    super.initState();
    _startActivityUpdates();
  }

  @override
  void dispose() {
    _activityTimer.cancel();
    super.dispose();
  }

  void _startActivityUpdates() {
    _activityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _addNewActivity();
      }
    });
  }

  void _addNewActivity() {
    if (_activities.length >= 10) {
      _activities.removeLast();
    }

    final isPositive = _random.nextBool();
    final pair = _tradingPairs[_random.nextInt(_tradingPairs.length)];
    final amount = (_random.nextDouble() * 10).toStringAsFixed(4);
    final price = (1000 + _random.nextDouble() * 50000).toStringAsFixed(2);

    final newActivity = ActivityData(
      type: isPositive ? 'Buy' : 'Sell',
      pair: pair,
      amount: amount,
      price: price,
      time: DateTime.now(),
      isPositive: isPositive,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    setState(() {
      _activities.insert(0, newActivity);
    });
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

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
              _buildActivitiesList(isDark),
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
          Text(
            'Recent Activities',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Navigate to all activities
            },
            child: Text(
              'View All',
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.getPrimaryBlue(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(bool isDark) {
    return Column(
      children: _activities
          .map(
            (activity) => ActivityRow(
              activity: activity,
              isDark: isDark,
              timeAgo: _formatTimeAgo(activity.time),
            ),
          )
          .toList(),
    );
  }
}

class ActivityData {
  final String type;
  final String pair;
  final String amount;
  final String price;
  final DateTime time;
  final bool isPositive;
  final String id;

  ActivityData({
    required this.type,
    required this.pair,
    required this.amount,
    required this.price,
    required this.time,
    required this.isPositive,
    required this.id,
  });
}

class ActivityRow extends StatefulWidget {
  const ActivityRow({
    super.key,
    required this.activity,
    required this.isDark,
    required this.timeAgo,
  });

  final ActivityData activity;
  final bool isDark;
  final String timeAgo;

  @override
  State<ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<ActivityRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    // Verificar si es una nueva actividad
    final now = DateTime.now();
    if (now.difference(widget.activity.time).inSeconds < 2) {
      _isNew = true;
      _slideController.forward();

      // Remover el estado de "nuevo" después de 5 segundos
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isNew = false;
          });
        }
      });
    } else {
      _slideController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _isNew
              ? (widget.activity.isPositive
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark))
                    .withOpacity(0.05)
              : Colors.transparent,
          border: _isNew
              ? Border(
                  left: BorderSide(
                    color: widget.activity.isPositive
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark),
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildActivityIcon(),
              const SizedBox(width: AppSpacing.sm),
              _buildActivityInfo(),
              Text(
                widget.timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextMuted(widget.isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            (widget.activity.isPositive
                    ? AppColors.getBuyGreen(widget.isDark)
                    : AppColors.getSellRed(widget.isDark))
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Icon(
        widget.activity.isPositive
            ? LucideIcons.arrowUp
            : LucideIcons.arrowDown,
        color: widget.activity.isPositive
            ? AppColors.getBuyGreen(widget.isDark)
            : AppColors.getSellRed(widget.isDark),
        size: 16,
      ),
    );
  }

  Widget _buildActivityInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.activity.type} ${widget.activity.pair}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextPrimary(widget.isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_isNew) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getInfo(widget.isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NEW',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            '${widget.activity.amount} @ \$${widget.activity.price}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextSecondary(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }
}
