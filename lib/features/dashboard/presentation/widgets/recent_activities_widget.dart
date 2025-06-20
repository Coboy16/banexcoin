import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'dart:math';

import '/features/dashboard/domain/entities/entities.dart';
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
  final List<ActivityData> _activities = [];
  final Map<String, TickerEntity> _lastTickerData = {};

  @override
  void initState() {
    super.initState();
    _addInitialActivities();
    _startActivityGeneration();
  }

  @override
  void dispose() {
    _activityTimer.cancel();
    super.dispose();
  }

  void _addInitialActivities() {
    // Agregar algunas actividades iniciales para demostración
    final initialActivities = [
      ActivityData(
        type: 'Buy',
        pair: 'BTC/USDT',
        amount: '0.0245',
        price: '43,250.00',
        time: DateTime.now().subtract(const Duration(minutes: 2)),
        isPositive: true,
        id: 'initial_1',
        orderType: 'Market',
        priceChange: 1.25,
      ),
      ActivityData(
        type: 'Sell',
        pair: 'ETH/USDT',
        amount: '2.15',
        price: '2,680.50',
        time: DateTime.now().subtract(const Duration(minutes: 8)),
        isPositive: false,
        id: 'initial_2',
        orderType: 'Limit',
        priceChange: -0.85,
      ),
      ActivityData(
        type: 'Buy',
        pair: 'BNB/USDT',
        amount: '12.5',
        price: '315.75',
        time: DateTime.now().subtract(const Duration(minutes: 15)),
        isPositive: true,
        id: 'initial_3',
        orderType: 'Market',
        priceChange: 2.1,
      ),
    ];

    setState(() {
      _activities.addAll(initialActivities);
    });
  }

  void _startActivityGeneration() {
    // Generar actividades basadas en cambios de precios cada 8-15 segundos
    _activityTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (mounted) {
        final marketDataBloc = context.read<MarketDataBloc>();
        final state = marketDataBloc.state;

        if (state is MarketDataLoaded) {
          _generateActivityFromMarketData(state);
        } else {
          // Si no hay datos del mercado, generar actividad simulada
          _generateSimulatedActivity();
        }
      }
    });
  }

  void _generateActivityFromMarketData(MarketDataLoaded state) {
    final currentTickers = state.tickers;

    if (currentTickers.isEmpty) {
      _generateSimulatedActivity();
      return;
    }

    // Buscar símbolos con cambios significativos de precio
    bool activityGenerated = false;

    for (final entry in currentTickers.entries) {
      final symbol = entry.key;
      final currentTicker = entry.value;
      final lastTicker = _lastTickerData[symbol];

      if (lastTicker != null) {
        final currentPrice = double.tryParse(currentTicker.lastPrice) ?? 0;
        final lastPrice = double.tryParse(lastTicker.lastPrice) ?? 0;

        // Detectar cambio significativo de precio (>0.05% para mayor sensibilidad)
        if (lastPrice > 0) {
          final priceChangePercent =
              ((currentPrice - lastPrice) / lastPrice) * 100;

          if (priceChangePercent.abs() > 0.05) {
            _createActivityFromPriceChange(currentTicker, priceChangePercent);
            activityGenerated = true;
            break; // Solo generar una actividad por vez
          }
        }
      }

      _lastTickerData[symbol] = currentTicker;
    }

    // Si no se generó actividad de cambios reales, generar una simulada ocasionalmente
    if (!activityGenerated && _random.nextDouble() < 0.3) {
      _generateSimulatedActivity();
    }
  }

  void _generateSimulatedActivity() {
    // Limitar a 10 actividades máximo
    if (_activities.length >= 10) {
      _activities.removeLast();
    }

    final tradingPairs = [
      'BTC/USDT',
      'ETH/USDT',
      'BNB/USDT',
      'ADA/USDT',
      'SOL/USDT',
      'DOT/USDT',
    ];
    final orderTypes = ['Market', 'Limit', 'Stop'];

    final isPositive = _random.nextBool();
    final pair = tradingPairs[_random.nextInt(tradingPairs.length)];
    final orderType = orderTypes[_random.nextInt(orderTypes.length)];

    // Generar datos simulados realistas
    final amount = _generateSimulatedAmount(pair);
    final price = _generateSimulatedPrice(pair);
    final priceChange = (_random.nextDouble() * 4 - 2); // Entre -2% y +2%

    final newActivity = ActivityData(
      type: isPositive ? 'Buy' : 'Sell',
      pair: pair,
      amount: amount,
      price: price,
      time: DateTime.now(),
      isPositive: isPositive,
      id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      orderType: orderType,
      priceChange: priceChange,
    );

    setState(() {
      _activities.insert(0, newActivity);
    });
  }

  String _generateSimulatedAmount(String pair) {
    if (pair.startsWith('BTC')) {
      return (_random.nextDouble() * 0.5).toStringAsFixed(4);
    } else if (pair.startsWith('ETH')) {
      return (_random.nextDouble() * 10).toStringAsFixed(3);
    } else if (pair.startsWith('BNB')) {
      return (_random.nextDouble() * 50).toStringAsFixed(2);
    } else {
      return (_random.nextDouble() * 1000).toStringAsFixed(2);
    }
  }

  String _generateSimulatedPrice(String pair) {
    if (pair.startsWith('BTC')) {
      final basePrice = 43000 + (_random.nextDouble() * 2000);
      return basePrice.toStringAsFixed(2);
    } else if (pair.startsWith('ETH')) {
      final basePrice = 2600 + (_random.nextDouble() * 200);
      return basePrice.toStringAsFixed(2);
    } else if (pair.startsWith('BNB')) {
      final basePrice = 300 + (_random.nextDouble() * 50);
      return basePrice.toStringAsFixed(2);
    } else if (pair.startsWith('ADA')) {
      final basePrice = 0.5 + (_random.nextDouble() * 0.2);
      return basePrice.toStringAsFixed(4);
    } else if (pair.startsWith('SOL')) {
      final basePrice = 80 + (_random.nextDouble() * 20);
      return basePrice.toStringAsFixed(2);
    } else {
      final basePrice = 10 + (_random.nextDouble() * 40);
      return basePrice.toStringAsFixed(2);
    }
  }

  void _createActivityFromPriceChange(
    TickerEntity ticker,
    double priceChangePercent,
  ) {
    // Limitar a 10 actividades máximo
    if (_activities.length >= 10) {
      _activities.removeLast();
    }

    final isPositive = priceChangePercent > 0;

    // Simular diferentes tipos de órdenes basadas en el cambio de precio
    final orderTypes = ['Market', 'Limit', 'Stop'];
    final orderType = orderTypes[_random.nextInt(orderTypes.length)];

    // Generar volumen realista basado en el volumen del ticker
    final baseVolume = double.tryParse(ticker.volume) ?? 0;
    final simulatedAmount = _generateRealisticAmount(ticker.symbol, baseVolume);

    final newActivity = ActivityData(
      type: isPositive ? 'Buy' : 'Sell',
      pair: _formatSymbolToPair(ticker.symbol),
      amount: simulatedAmount,
      price: _formatPrice(ticker.lastPrice),
      time: DateTime.now(),
      isPositive: isPositive,
      id: '${ticker.symbol}_${DateTime.now().millisecondsSinceEpoch}',
      orderType: orderType,
      priceChange: priceChangePercent,
      volume24h: ticker.quoteVolume,
    );

    setState(() {
      _activities.insert(0, newActivity);
    });
  }

  String _generateRealisticAmount(String symbol, double baseVolume) {
    // Generar cantidades realistas basadas en el símbolo
    if (symbol.startsWith('BTC')) {
      return (_random.nextDouble() * 0.5).toStringAsFixed(4);
    } else if (symbol.startsWith('ETH')) {
      return (_random.nextDouble() * 10).toStringAsFixed(3);
    } else if (symbol.startsWith('BNB')) {
      return (_random.nextDouble() * 50).toStringAsFixed(2);
    } else {
      return (_random.nextDouble() * 1000).toStringAsFixed(2);
    }
  }

  String _formatSymbolToPair(String symbol) {
    if (symbol.endsWith('USDT')) {
      final base = symbol.substring(0, symbol.length - 4);
      return '$base/USDT';
    } else if (symbol.endsWith('BUSD')) {
      final base = symbol.substring(0, symbol.length - 4);
      return '$base/BUSD';
    } else if (symbol.endsWith('BTC')) {
      final base = symbol.substring(0, symbol.length - 3);
      return '$base/BTC';
    } else if (symbol.endsWith('ETH')) {
      final base = symbol.substring(0, symbol.length - 3);
      return '$base/ETH';
    }
    return symbol;
  }

  String _formatPrice(String price) {
    try {
      final value = double.parse(price);
      if (value >= 1000) {
        return value.toStringAsFixed(2);
      } else if (value >= 1) {
        return value.toStringAsFixed(4);
      } else {
        return value.toStringAsFixed(6);
      }
    } catch (e) {
      return price;
    }
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

        return BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, marketState) {
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
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: _buildContent(isDark, marketState),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, MarketDataState marketState) {
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
          if (marketState is MarketDataLoaded)
            _buildConnectionStatus(isDark, marketState),
          const SizedBox(width: AppSpacing.sm),
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

  Widget _buildConnectionStatus(bool isDark, MarketDataLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: state.streamsActive
            ? AppColors.getBuyGreen(isDark).withOpacity(0.1)
            : AppColors.getTextMuted(isDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: state.streamsActive
                  ? AppColors.getBuyGreen(isDark)
                  : AppColors.getTextMuted(isDark),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            state.streamsActive ? 'Live' : 'Paused',
            style: AppTextStyles.caption.copyWith(
              color: state.streamsActive
                  ? AppColors.getBuyGreen(isDark)
                  : AppColors.getTextMuted(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, MarketDataState marketState) {
    if (marketState is MarketDataLoading) {
      return _buildLoadingState(isDark);
    } else if (marketState is MarketDataLoaded) {
      return _buildActivitiesList(isDark);
    } else if (marketState is MarketDataError) {
      return _buildErrorState(isDark);
    } else {
      return _buildInitialState(isDark);
    }
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceColor(isDark),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceColor(isDark),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivitiesList(bool isDark) {
    if (_activities.isEmpty) {
      return SizedBox(
        height: 430,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.activity,
                color: AppColors.getTextMuted(isDark),
                size: 48,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Waiting for market activity...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Activities will appear as prices change',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextMuted(isDark),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 430,
      child: ListView.builder(
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return ActivityRow(
            activity: activity,
            isDark: isDark,
            timeAgo: _formatTimeAgo(activity.time),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            LucideIcons.wifiOff,
            color: AppColors.getError(isDark),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unable to load activities',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            LucideIcons.play,
            color: AppColors.getTextMuted(isDark),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Initialize market data to see activities',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
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
  final String orderType;
  final double priceChange;
  final String volume24h;

  ActivityData({
    required this.type,
    required this.pair,
    required this.amount,
    required this.price,
    required this.time,
    required this.isPositive,
    required this.id,
    this.orderType = 'Market',
    this.priceChange = 0.0,
    this.volume24h = '0',
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
  late Animation<double> _pulseAnimation;
  bool _isNew = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // Verificar si es una nueva actividad
    final now = DateTime.now();
    if (now.difference(widget.activity.time).inSeconds < 3) {
      _isNew = true;
      _slideController.forward();

      // Remover el estado de "nuevo" después de 8 segundos
      Timer(const Duration(seconds: 8), () {
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
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: _isNew
                ? (widget.activity.isPositive
                          ? AppColors.getBuyGreen(widget.isDark)
                          : AppColors.getSellRed(widget.isDark))
                      .withOpacity(0.08)
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
                _buildTimeAndStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            (widget.activity.isPositive
                    ? AppColors.getBuyGreen(widget.isDark)
                    : AppColors.getSellRed(widget.isDark))
                .withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: widget.activity.isPositive
              ? AppColors.getBuyGreen(widget.isDark)
              : AppColors.getSellRed(widget.isDark),
          width: 1,
        ),
      ),
      child: Icon(
        widget.activity.isPositive
            ? LucideIcons.trendingUp
            : LucideIcons.trendingDown,
        color: widget.activity.isPositive
            ? AppColors.getBuyGreen(widget.isDark)
            : AppColors.getSellRed(widget.isDark),
        size: 18,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(widget.isDark),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  widget.activity.orderType,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.getTextMuted(widget.isDark),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
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
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
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

  Widget _buildTimeAndStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.timeAgo,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.getTextMuted(widget.isDark),
            fontSize: 11,
          ),
        ),
        if (widget.activity.priceChange != 0.0) ...[
          const SizedBox(height: 2),
          Text(
            '${widget.activity.priceChange > 0 ? '+' : ''}${widget.activity.priceChange.toStringAsFixed(2)}%',
            style: AppTextStyles.caption.copyWith(
              color: widget.activity.isPositive
                  ? AppColors.getBuyGreen(widget.isDark)
                  : AppColors.getSellRed(widget.isDark),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
