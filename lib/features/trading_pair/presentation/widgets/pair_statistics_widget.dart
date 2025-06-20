import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class PairStatisticsWidget extends StatefulWidget {
  const PairStatisticsWidget({super.key, required this.symbol});

  final String symbol;

  @override
  State<PairStatisticsWidget> createState() => _PairStatisticsWidgetState();
}

class _PairStatisticsWidgetState extends State<PairStatisticsWidget> {
  late Timer _updateTimer;
  final Random _random = Random();

  List<StatisticData> _statistics = [];

  @override
  void initState() {
    super.initState();
    _initializeStatistics();
    _startUpdates();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _initializeStatistics() {
    final basePrice = _getBasePriceForSymbol(widget.symbol);

    _statistics = [
      StatisticData(
        title: '24h Open',
        value: (basePrice * 0.98).toStringAsFixed(basePrice >= 1 ? 2 : 4),
        change: null,
        icon: LucideIcons.sunrise,
        baseValue: basePrice * 0.98,
      ),
      StatisticData(
        title: '24h High',
        value: (basePrice * 1.045).toStringAsFixed(basePrice >= 1 ? 2 : 4),
        change: '+4.5%',
        isPositive: true,
        icon: LucideIcons.trendingUp,
        baseValue: basePrice * 1.045,
      ),
      StatisticData(
        title: '24h Low',
        value: (basePrice * 0.97).toStringAsFixed(basePrice >= 1 ? 2 : 4),
        change: '-3.0%',
        isPositive: false,
        icon: LucideIcons.trendingDown,
        baseValue: basePrice * 0.97,
      ),
      StatisticData(
        title: 'Current',
        value: basePrice.toStringAsFixed(basePrice >= 1 ? 2 : 4),
        change: '+2.5%',
        isPositive: true,
        icon: LucideIcons.activity,
        baseValue: basePrice,
      ),
      StatisticData(
        title: 'Volume (BTC)',
        value: '28,456.23',
        change: '+15.2%',
        isPositive: true,
        icon: LucideIcons.chartBar,
        baseValue: 28456.23,
      ),
      StatisticData(
        title: 'Volume (USDT)',
        value: '1.23B',
        change: '+12.8%',
        isPositive: true,
        icon: LucideIcons.dollarSign,
        baseValue: 1230000000,
      ),
      StatisticData(
        title: 'Market Cap',
        value: _getMarketCap(),
        change: '+3.2%',
        isPositive: true,
        icon: LucideIcons.chartPie,
        baseValue: 0,
      ),
      StatisticData(
        title: 'Circulating Supply',
        value: _getCirculatingSupply(),
        change: null,
        icon: LucideIcons.coins,
        baseValue: 0,
      ),
    ];
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

  String _getMarketCap() {
    switch (widget.symbol.toUpperCase()) {
      case 'BTC/USDT':
        return '847.2B';
      case 'ETH/USDT':
        return '318.5B';
      case 'BNB/USDT':
        return '48.3B';
      case 'ADA/USDT':
        return '17.1B';
      default:
        return 'N/A';
    }
  }

  String _getCirculatingSupply() {
    switch (widget.symbol.toUpperCase()) {
      case 'BTC/USDT':
        return '19.8M BTC';
      case 'ETH/USDT':
        return '120.3M ETH';
      case 'BNB/USDT':
        return '153.9M BNB';
      case 'ADA/USDT':
        return '35.0B ADA';
      default:
        return 'N/A';
    }
  }

  void _startUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _updateStatistics();
      }
    });
  }

  void _updateStatistics() {
    setState(() {
      for (var stat in _statistics) {
        if (stat.baseValue > 0) {
          // Simular cambios realistas
          final changePercent = (_random.nextDouble() - 0.5) * 0.01; // ±0.5%
          stat.baseValue = stat.baseValue * (1 + changePercent);

          if (stat.title.contains('Volume') && stat.title.contains('USDT')) {
            stat.value = '${(stat.baseValue / 1000000000).toStringAsFixed(2)}B';
          } else if (stat.title.contains('Volume')) {
            stat.value = '${stat.baseValue.toStringAsFixed(2)}';
          } else {
            final basePrice = _getBasePriceForSymbol(widget.symbol);
            stat.value = stat.baseValue.toStringAsFixed(basePrice >= 1 ? 2 : 4);
          }

          // Actualizar cambio porcentual si existe
          if (stat.change != null &&
              !stat.title.contains('Open') &&
              !stat.title.contains('Cap') &&
              !stat.title.contains('Supply')) {
            final newChange = (_random.nextDouble() - 0.5) * 10; // ±5%
            stat.isPositive = newChange >= 0;
            stat.change =
                '${newChange >= 0 ? '+' : ''}${newChange.toStringAsFixed(1)}%';
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: AppColors.getBorderPrimary(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildStatisticsGrid(isDark),
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
          LucideIcons.chartLine,
          color: AppColors.getPrimaryBlue(isDark),
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '24h Statistics',
          style: AppTextStyles.h3.copyWith(
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
            color: AppColors.getAccentYellow(isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(
              color: AppColors.getAccentYellow(isDark).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.clock,
                color: AppColors.getAccentYellow(isDark),
                size: 12,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Updated',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getAccentYellow(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
      ),
      itemCount: _statistics.length,
      itemBuilder: (context, index) {
        return StatisticCard(statistic: _statistics[index], isDark: isDark);
      },
    );
  }
}

class StatisticData {
  final String title;
  String value;
  String? change;
  bool? isPositive;
  final IconData icon;
  double baseValue;

  StatisticData({
    required this.title,
    required this.value,
    this.change,
    this.isPositive,
    required this.icon,
    required this.baseValue,
  });
}

class StatisticCard extends StatefulWidget {
  const StatisticCard({
    super.key,
    required this.statistic,
    required this.isDark,
  });

  final StatisticData statistic;
  final bool isDark;

  @override
  State<StatisticCard> createState() => _StatisticCardState();
}

class _StatisticCardState extends State<StatisticCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.getPrimaryBlue(widget.isDark).withOpacity(0.05),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    _colorAnimation.value ??
                    AppColors.getSurfaceColor(widget.isDark),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.getPrimaryBlue(widget.isDark).withOpacity(0.3)
                      : AppColors.getBorderSecondary(widget.isDark),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.sm),
                  _buildValue(),
                  if (widget.statistic.change != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _buildChange(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: _getIconColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(widget.statistic.icon, color: _getIconColor(), size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            widget.statistic.title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.getTextSecondary(widget.isDark),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildValue() {
    return Text(
      widget.statistic.value.startsWith('\$')
          ? widget.statistic.value
          : '\$${widget.statistic.value}',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.getTextPrimary(widget.isDark),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChange() {
    final isPositive = widget.statistic.isPositive ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color:
            (isPositive
                    ? AppColors.getBuyGreen(widget.isDark)
                    : AppColors.getSellRed(widget.isDark))
                .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? LucideIcons.arrowUp : LucideIcons.arrowDown,
            size: 12,
            color: isPositive
                ? AppColors.getBuyGreen(widget.isDark)
                : AppColors.getSellRed(widget.isDark),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.statistic.change!,
            style: AppTextStyles.caption.copyWith(
              color: isPositive
                  ? AppColors.getBuyGreen(widget.isDark)
                  : AppColors.getSellRed(widget.isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor() {
    switch (widget.statistic.title) {
      case '24h High':
        return AppColors.getBuyGreen(widget.isDark);
      case '24h Low':
        return AppColors.getSellRed(widget.isDark);
      case 'Current':
        return AppColors.getPrimaryBlue(widget.isDark);
      case 'Volume (BTC)':
      case 'Volume (USDT)':
        return AppColors.getAccentYellow(widget.isDark);
      case 'Market Cap':
        return AppColors.getInfo(widget.isDark);
      default:
        return AppColors.getTextSecondary(widget.isDark);
    }
  }
}
