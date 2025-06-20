import 'package:banexcoin/core/injections/trading_pair_di.dart' as tp_di;
import 'package:banexcoin/features/trading_pair/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class TradingPairDetailPage extends StatefulWidget {
  const TradingPairDetailPage({super.key, this.symbol = 'BTCUSDT'});

  final String symbol;

  @override
  State<TradingPairDetailPage> createState() => _TradingPairDetailPageState();
}

class _TradingPairDetailPageState extends State<TradingPairDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TradingPairBloc _tradingPairBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Crear el BLoC y cargar datos iniciales
    _tradingPairBloc = tp_di.tpSl<TradingPairBloc>();
    _tradingPairBloc.add(LoadTradingPairData(symbol: widget.symbol));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tradingPairBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TradingPairBloc>.value(
      value: _tradingPairBloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDarkMode;
          final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

          return Container(
            color: AppColors.getPrimaryBackground(isDark),
            child: BlocListener<TradingPairBloc, TradingPairState>(
              listener: (context, state) {
                if (state is TradingPairError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: AppColors.getSellRed(isDark),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              child: BlocBuilder<TradingPairBloc, TradingPairState>(
                builder: (context, state) {
                  if (state is TradingPairLoading) {
                    return _buildLoadingState(isDark);
                  } else if (state is TradingPairError) {
                    return _buildErrorState(state, isDark);
                  } else if (state is TradingPairLoaded) {
                    return _buildLoadedState(state, isDesktop, isDark);
                  }
                  return _buildInitialState(isDark);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header placeholder
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(isDark),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.getBorderPrimary(isDark)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.getPrimaryBlue(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Loading ${widget.symbol} data...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Content placeholders
          _buildShimmerPlaceholder(isDark, height: 120), // Price display
          const SizedBox(height: AppSpacing.xl),
          _buildShimmerPlaceholder(isDark, height: 400), // Chart
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _buildShimmerPlaceholder(isDark, height: 300)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _buildShimmerPlaceholder(isDark, height: 300)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder(bool isDark, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.getSurfaceColor(isDark).withOpacity(0.3),
                AppColors.getSurfaceColor(isDark).withOpacity(0.1),
                AppColors.getSurfaceColor(isDark).withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(TradingPairError state, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(isDark),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: AppColors.getSellRed(isDark).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.getSellRed(isDark),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Error Loading Data',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () {
                    _tradingPairBloc.add(
                      LoadTradingPairData(symbol: widget.symbol),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryBlue(isDark),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(isDark),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.getBorderPrimary(isDark)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.candlestick_chart_rounded,
                  size: 64,
                  color: AppColors.getPrimaryBlue(isDark),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Welcome to Trading Pair',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Select a trading pair to start viewing real-time market data',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    TradingPairLoaded state,
    bool isDesktop,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PairHeaderWidget(
            symbol: state.tradingPair.symbol,
            symbolInfo: state.symbolInfo,
            isStreaming: state.isStreaming,
          ),
          const SizedBox(height: AppSpacing.xl),
          PriceDisplayWidget(
            tradingPair: state.tradingPair,
            priceStats: state.priceStats,
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildMainContent(state, isDesktop, isDark),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    TradingPairLoaded state,
    bool isDesktop,
    bool isDark,
  ) {
    if (isDesktop) {
      return ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.ROW,
        rowSpacing: AppSpacing.lg,
        children: [
          ResponsiveRowColumnItem(
            rowFlex: 2,
            child: Column(
              children: [
                TradingChartTwoWidget(symbol: state.tradingPair.symbol),
                const SizedBox(height: AppSpacing.lg),
                PairStatisticsWidget(symbol: state.tradingPair.symbol),
              ],
            ),
          ),
          ResponsiveRowColumnItem(
            rowFlex: 1,
            child: Column(
              children: [
                _buildTradingTabs(state, isDark),
                const SizedBox(height: AppSpacing.lg),
                RecentTradesWidget(symbol: state.tradingPair.symbol),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile layout
      return Column(
        children: [
          TradingChartTwoWidget(symbol: state.tradingPair.symbol),
          const SizedBox(height: AppSpacing.lg),
          _buildTradingTabs(state, isDark),
          const SizedBox(height: AppSpacing.lg),
          PairStatisticsWidget(symbol: state.tradingPair.symbol),
          const SizedBox(height: AppSpacing.lg),
          RecentTradesWidget(symbol: state.tradingPair.symbol),
        ],
      );
    }
  }

  Widget _buildTradingTabs(TradingPairLoaded state, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.getBorderPrimary(isDark)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.getPrimaryBlue(isDark),
              labelColor: AppColors.getTextPrimary(isDark),
              unselectedLabelColor: AppColors.getTextMuted(isDark),
              labelStyle: AppTextStyles.buttonMedium,
              unselectedLabelStyle: AppTextStyles.bodyMedium,
              tabs: const [
                Tab(text: 'Trade'),
                Tab(text: 'Market'),
              ],
            ),
          ),
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                QuickTradeWidget(symbol: state.tradingPair.symbol),
                _buildMarketTab(state, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab(TradingPairLoaded state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Information',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildMarketInfo(state, isDark),
        ],
      ),
    );
  }

  Widget _buildMarketInfo(TradingPairLoaded state, bool isDark) {
    final marketData = [
      {'label': 'Symbol', 'value': state.symbolInfo.symbol},
      {'label': 'Base Asset', 'value': state.symbolInfo.baseAsset},
      {'label': 'Quote Asset', 'value': state.symbolInfo.quoteAsset},
      {'label': 'Status', 'value': state.symbolInfo.status},
      {
        'label': 'Base Precision',
        'value': '${state.symbolInfo.baseAssetPrecision}',
      },
      {
        'label': 'Quote Precision',
        'value': '${state.symbolInfo.quoteAssetPrecision}',
      },
      {
        'label': '24h Volume',
        'value':
            '${state.priceStats.volume.toStringAsFixed(2)} ${state.symbolInfo.baseAsset}',
      },
      {
        'label': '24h Quote Volume',
        'value':
            '${state.priceStats.quoteVolume.toStringAsFixed(2)} ${state.symbolInfo.quoteAsset}',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
      ),
      itemCount: marketData.length,
      itemBuilder: (context, index) {
        final data = marketData[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: AppColors.getBorderSecondary(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data['label']!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                data['value']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
