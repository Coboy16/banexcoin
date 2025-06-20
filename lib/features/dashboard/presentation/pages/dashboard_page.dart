import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/features/dashboard/presentation/widgets/widgets.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Símbolos principales para mostrar en el dashboard
  final List<String> _mainSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'SOLUSDT',
    'DOTUSDT',
  ];

  @override
  void initState() {
    super.initState();
    _initializeMarketData();
  }

  void _initializeMarketData() {
    // Inicializar el BLoC con datos de mercado
    context.read<MarketDataBloc>().add(
      InitializeMarketData(
        symbols: _mainSymbols,
        enableRealTimeStreams: true,
        loadStatistics: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

        return Container(
          color: AppColors.getPrimaryBackground(isDark),
          child: BlocBuilder<MarketDataBloc, MarketDataState>(
            builder: (context, marketState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDark, marketState),
                    const SizedBox(height: AppSpacing.xl),
                    _buildConnectionStatus(isDark, marketState),
                    const SizedBox(height: AppSpacing.lg),
                    const PortfolioOverviewWidget(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildMainContent(isDesktop, marketState),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, MarketDataState marketState) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trading Dashboard',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _getSubtitleText(marketState),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
        _buildHeaderActions(isDark, marketState),
      ],
    );
  }

  String _getSubtitleText(MarketDataState state) {
    if (state is MarketDataLoading) {
      return 'Loading market data...';
    } else if (state is MarketDataLoaded) {
      return '${state.activeSymbols.length} pairs tracking • ${state.activeConnectionsCount} live connections';
    } else if (state is MarketDataError) {
      return 'Error loading data • ${state.message}';
    }
    return 'Monitor your portfolio and market trends';
  }

  Widget _buildHeaderActions(bool isDark, MarketDataState marketState) {
    return Row(
      children: [
        // Refresh button
        IconButton(
          onPressed: marketState is! MarketDataLoading
              ? () => _refreshData()
              : null,
          icon: Icon(Icons.refresh, color: AppColors.getPrimaryBlue(isDark)),
          tooltip: 'Refresh Data',
        ),
        const SizedBox(width: AppSpacing.sm),

        // Add to watchlist button
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.getPrimaryBlue(isDark),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: InkWell(
            onTap: () => _showAddSymbolDialog(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: AppColors.getTextPrimary(!isDark),
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Add Symbol',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.getTextPrimary(!isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(bool isDark, MarketDataState marketState) {
    if (marketState is! MarketDataLoaded) return const SizedBox.shrink();

    final isConnected = marketState.isConnected;
    final streamsActive = marketState.streamsActive;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: isConnected
              ? AppColors.getBuyGreen(isDark)
              : AppColors.getSellRed(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.getBuyGreen(isDark)
                  : AppColors.getSellRed(isDark),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isConnected
                  ? 'Connected • ${marketState.activeConnectionsCount} active streams'
                  : 'Disconnected • Check your internet connection',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
          ),
          if (isConnected) ...[
            const SizedBox(width: AppSpacing.sm),
            Switch(
              value: streamsActive,
              onChanged: (value) {
                context.read<MarketDataBloc>().add(ToggleStreams(!value));
              },
              activeColor: AppColors.getBuyGreen(isDark),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              streamsActive ? 'Live' : 'Paused',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop, MarketDataState marketState) {
    return ResponsiveRowColumn(
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
              // Trading Pairs Widget con datos reales
              TradingPairsWidget(marketState: marketState),
              const SizedBox(height: AppSpacing.lg),

              // Market Overview Widget con datos reales
              MarketOverviewWidget(marketState: marketState),
            ],
          ),
        ),
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Column(
            children: [
              const RecentActivitiesWidget(),
              const SizedBox(height: AppSpacing.lg),
              const PriceAlertsWidget(),
            ],
          ),
        ),
      ],
    );
  }

  void _refreshData() {
    context.read<MarketDataBloc>().add(
      RefreshInitialData(symbols: _mainSymbols),
    );
  }

  void _showAddSymbolDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSymbolDialog(
        onSymbolAdded: (symbol) {
          context.read<MarketDataBloc>().add(AddToWatchlist(symbol));
          context.read<MarketDataBloc>().add(SubscribeToTicker(symbol));
        },
      ),
    );
  }
}

// Widget para agregar nuevos símbolos
class AddSymbolDialog extends StatefulWidget {
  final Function(String) onSymbolAdded;

  const AddSymbolDialog({super.key, required this.onSymbolAdded});

  @override
  State<AddSymbolDialog> createState() => _AddSymbolDialogState();
}

class _AddSymbolDialogState extends State<AddSymbolDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _popularSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'SOLUSDT',
    'DOTUSDT',
    'LINKUSDT',
    'MATICUSDT',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Trading Pair'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter symbol (e.g., BTCUSDT)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Popular pairs:'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _popularSymbols.map((symbol) {
              return ActionChip(
                label: Text(symbol),
                onPressed: () {
                  _controller.text = symbol;
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final symbol = _controller.text.trim().toUpperCase();
            if (symbol.isNotEmpty) {
              widget.onSymbolAdded(symbol);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
