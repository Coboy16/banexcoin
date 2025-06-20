import 'package:banexcoin/features/trading_pair/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/core/bloc/blocs.dart';
import '/core/core.dart';

class TradingPairDetailPage extends StatefulWidget {
  const TradingPairDetailPage({super.key, this.symbol = 'BTC/USDT'});

  final String symbol;

  @override
  State<TradingPairDetailPage> createState() => _TradingPairDetailPageState();
}

class _TradingPairDetailPageState extends State<TradingPairDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return Container(
          color: AppColors.getPrimaryBackground(isDark),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PairHeaderWidget(symbol: widget.symbol),
                const SizedBox(height: AppSpacing.xl),
                PriceDisplayWidget(symbol: widget.symbol),
                const SizedBox(height: AppSpacing.xl),
                _buildMainContent(isDesktop, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(bool isDesktop, bool isDark) {
    if (isDesktop) {
      return ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.ROW,
        rowSpacing: AppSpacing.lg,
        children: [
          ResponsiveRowColumnItem(
            rowFlex: 2,
            child: Column(
              children: [
                TradingChartTwoWidget(symbol: widget.symbol),
                const SizedBox(height: AppSpacing.lg),
                PairStatisticsWidget(symbol: widget.symbol),
              ],
            ),
          ),
          ResponsiveRowColumnItem(
            rowFlex: 1,
            child: Column(
              children: [
                _buildTradingTabs(isDark),
                const SizedBox(height: AppSpacing.lg),
                RecentTradesWidget(symbol: widget.symbol),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile layout
      return Column(
        children: [
          TradingChartTwoWidget(symbol: widget.symbol),
          const SizedBox(height: AppSpacing.lg),
          _buildTradingTabs(isDark),
          const SizedBox(height: AppSpacing.lg),
          PairStatisticsWidget(symbol: widget.symbol),
          const SizedBox(height: AppSpacing.lg),
          RecentTradesWidget(symbol: widget.symbol),
        ],
      );
    }
  }

  Widget _buildTradingTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: AppColors.getBorderPrimary(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Cambiar a min
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
            height: 500, // Altura fija para el contenido de las tabs
            child: TabBarView(
              controller: _tabController,
              children: [
                QuickTradeWidget(symbol: widget.symbol),
                _buildMarketTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab(bool isDark) {
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
          _buildMarketInfo(isDark),
        ],
      ),
    );
  }

  Widget _buildMarketInfo(bool isDark) {
    final marketData = [
      {'label': 'Market Cap Rank', 'value': '#1'},
      {'label': 'Market Cap', 'value': '\$847.2B'},
      {'label': 'Circulating Supply', 'value': '19.8M BTC'},
      {'label': 'Total Supply', 'value': '21M BTC'},
      {'label': 'All Time High', 'value': '\$69,045'},
      {'label': 'All Time Low', 'value': '\$67.81'},
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
              ),
            ],
          ),
        );
      },
    );
  }
}
