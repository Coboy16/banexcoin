import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart'; // Importante para la detección

import '/features/dashboard/domain/entities/entities.dart';
import '/core/bloc/blocs.dart';
import '/core/core.dart';

class TradingPairsWidget extends StatelessWidget {
  final MarketDataState? marketState;

  const TradingPairsWidget({super.key, this.marketState});

  @override
  Widget build(BuildContext context) {
    // =================================================================
    // INICIO MODIFICACIÓN: Detectar si es escritorio o móvil
    // =================================================================
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    // =================================================================
    // FIN MODIFICACIÓN
    // =================================================================

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
              // MODIFICACIÓN: Pasar 'isDesktop' para renderizar la cabecera correcta
              _buildTableHeader(isDark, isDesktop),
              // MODIFICACIÓN: Pasar 'isDesktop' para renderizar el contenido correcto
              _buildContent(isDark, isDesktop),
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
            'Trading Pairs',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const Spacer(),
          _buildStatusIndicator(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isDark) {
    if (marketState is MarketDataLoaded) {
      final state = marketState as MarketDataLoaded;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: state.isConnected
              ? AppColors.getBuyGreen(isDark).withOpacity(0.1)
              : AppColors.getSellRed(isDark).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: state.isConnected
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              state.isConnected ? 'Live' : 'Offline',
              style: AppTextStyles.caption.copyWith(
                color: state.isConnected
                    ? AppColors.getBuyGreen(isDark)
                    : AppColors.getSellRed(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // =================================================================
  // INICIO MODIFICACIÓN: Cabecera de tabla responsiva
  // =================================================================
  Widget _buildTableHeader(bool isDark, bool isDesktop) {
    final headerStyle = AppTextStyles.labelMedium.copyWith(
      color: AppColors.getTextSecondary(isDark),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.getBorderPrimary(isDark)),
          bottom: BorderSide(color: AppColors.getBorderPrimary(isDark)),
        ),
      ),
      child: Row(
        children: isDesktop
            ? [
                // Cabecera para Desktop (Original)
                Expanded(flex: 2, child: Text('Pair', style: headerStyle)),
                Expanded(
                  child: Text(
                    'Price',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '24h Change',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Volume',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ]
            : [
                // Cabecera para Móvil (Modificada)
                Expanded(flex: 3, child: Text('Pair', style: headerStyle)),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '24h Change',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Volume',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
      ),
    );
  }
  // =================================================================
  // FIN MODIFICACIÓN
  // =================================================================

  Widget _buildContent(bool isDark, bool isDesktop) {
    if (marketState is MarketDataLoading) {
      return _buildLoadingState(isDark);
    } else if (marketState is MarketDataLoaded) {
      // MODIFICACIÓN: Pasar 'isDesktop' para elegir el widget de fila correcto
      return _buildLoadedState(
        marketState as MarketDataLoaded,
        isDark,
        isDesktop,
      );
    } else if (marketState is MarketDataError) {
      return _buildErrorState(marketState as MarketDataError, isDark);
    } else {
      return _buildInitialState(isDark);
    }
  }

  Widget _buildLoadedState(
    MarketDataLoaded state,
    bool isDark,
    bool isDesktop,
  ) {
    final tickers = state.tickers.values.toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));

    if (tickers.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: tickers.map((ticker) {
        final connectionStatus = state.getConnectionStatus(ticker.symbol);
        // =================================================================
        // INICIO MODIFICACIÓN: Lógica para elegir el widget de fila
        // =================================================================
        if (isDesktop) {
          return TradingPairDesktopRow(
            // Usar el widget de fila para Desktop
            ticker: ticker,
            connectionStatus: connectionStatus,
            isDark: isDark,
            onTap: () => _navigateToPairDetail(ticker),
          );
        } else {
          return TradingPairMobileRow(
            // Usar el nuevo widget de fila para Móvil
            ticker: ticker,
            isDark: isDark,
            onTap: () => _navigateToPairDetail(ticker),
          );
        }
        // =================================================================
        // FIN MODIFICACIÓN
        // =================================================================
      }).toList(),
    );
  }

  // El resto de los métodos _build... (loading, error, etc.) no necesitan cambios.
  Widget _buildLoadingState(bool isDark) {
    /* ...código sin cambios... */
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                _buildShimmer(80, 20, isDark),
                const Spacer(),
                _buildShimmer(60, 20, isDark),
                const SizedBox(width: AppSpacing.md),
                _buildShimmer(70, 20, isDark),
                const SizedBox(width: AppSpacing.md),
                _buildShimmer(50, 20, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(double width, double height, bool isDark) {
    /* ...código sin cambios... */
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildErrorState(MarketDataError error, bool isDark) {
    /* ...código sin cambios... */
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            LucideIcons.circleAlert,
            color: AppColors.getError(isDark),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load trading pairs',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error.friendlyMessage,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.getTextSecondary(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          if (error.isRetryable) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _retryConnection(),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    /* ...código sin cambios... */
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            LucideIcons.trendingUp,
            color: AppColors.getTextMuted(isDark),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No trading pairs available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    /* ...código sin cambios... */
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            LucideIcons.database,
            color: AppColors.getTextMuted(isDark),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Initialize market data to see trading pairs',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPairDetail(TickerEntity ticker) {
    debugPrint('Navigate to ${ticker.symbol} detail');
  }

  void _retryConnection() {
    debugPrint('Retry connection');
  }
}

// =================================================================
// WIDGET DE FILA PARA DESKTOP (EL CÓDIGO ORIGINAL SIN CAMBIOS)
// Renombrado de 'TradingPairRealRow' a 'TradingPairDesktopRow' para mayor claridad.
// =================================================================
class TradingPairDesktopRow extends StatefulWidget {
  final TickerEntity ticker;
  final ConnectionStatus connectionStatus;
  final bool isDark;
  final VoidCallback onTap;

  const TradingPairDesktopRow({
    super.key,
    required this.ticker,
    required this.connectionStatus,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<TradingPairDesktopRow> createState() => _TradingPairDesktopRowState();
}

class _TradingPairDesktopRowState extends State<TradingPairDesktopRow>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateFlashAnimation();
  }

  @override
  void didUpdateWidget(TradingPairDesktopRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticker.lastPrice != widget.ticker.lastPrice) {
      _updateFlashAnimation();
      _flashController.forward().then((_) {
        _flashController.reverse();
      });
    }
  }

  void _updateFlashAnimation() {
    Color flashColor = widget.ticker.isPriceChangePositive
        ? AppColors.getBuyGreen(widget.isDark)
        : AppColors.getSellRed(widget.isDark);
    _flashAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: flashColor.withOpacity(0.1),
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  _flashAnimation.value ??
                  (_isHovered
                      ? AppColors.getSurfaceColor(
                          widget.isDark,
                        ).withOpacity(0.5)
                      : Colors.transparent),
            ),
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    _buildPairInfo(),
                    _buildPrice(),
                    _buildChange(),
                    _buildVolume(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPairInfo() {
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryBlue(
                    widget.isDark,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  _getSymbolIcon(widget.ticker.symbol),
                  color: AppColors.getPrimaryBlue(widget.isDark),
                  size: 16,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getConnectionColor(),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.getCardBackground(widget.isDark),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatSymbol(widget.ticker.symbol),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextPrimary(widget.isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.ticker.formattedPriceChangePercent,
                style: AppTextStyles.caption.copyWith(
                  color: widget.ticker.isPriceChangePositive
                      ? AppColors.getBuyGreen(widget.isDark)
                      : AppColors.getSellRed(widget.isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrice() {
    return Expanded(
      child: Text(
        _formatPrice(widget.ticker.lastPrice),
        style: AppTextStyles.priceMedium.copyWith(
          color: AppColors.getTextPrimary(widget.isDark),
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildChange() {
    return Expanded(
      child: Container(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color:
                (widget.ticker.isPriceChangePositive
                        ? AppColors.getBuyGreen(widget.isDark)
                        : AppColors.getSellRed(widget.isDark))
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Text(
            widget.ticker.formattedPriceChangePercent,
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.ticker.isPriceChangePositive
                  ? AppColors.getBuyGreen(widget.isDark)
                  : AppColors.getSellRed(widget.isDark),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolume() {
    return Expanded(
      child: Text(
        _formatVolume(widget.ticker.quoteVolume),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.getTextSecondary(widget.isDark),
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  // Métodos de ayuda (sin cambios)
  IconData _getSymbolIcon(String symbol) {
    if (symbol.startsWith('BTC')) return LucideIcons.bitcoin;
    if (symbol.startsWith('ETH')) return LucideIcons.hexagon;
    if (symbol.startsWith('BNB')) return LucideIcons.triangle;
    if (symbol.startsWith('ADA')) return LucideIcons.circle;
    if (symbol.startsWith('SOL')) return LucideIcons.sun;
    if (symbol.startsWith('DOT')) return LucideIcons.circle;
    return LucideIcons.coins;
  }

  String _formatSymbol(String symbol) {
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
      } else if (value >= 0.01) {
        return value.toStringAsFixed(6);
      } else {
        return value.toStringAsFixed(8);
      }
    } catch (e) {
      return price;
    }
  }

  String _formatVolume(String volume) {
    try {
      final value = double.parse(volume);
      if (value >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return value.toStringAsFixed(2);
      }
    } catch (e) {
      return volume;
    }
  }

  Color _getConnectionColor() {
    switch (widget.connectionStatus) {
      case ConnectionStatus.connected:
        return AppColors.getBuyGreen(widget.isDark);
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return AppColors.getWarning(widget.isDark);
      case ConnectionStatus.error:
        return AppColors.getSellRed(widget.isDark);
      case ConnectionStatus.disconnected:
        return AppColors.getTextMuted(widget.isDark);
    }
  }
}

// =================================================================
// NUEVO WIDGET DE FILA EXCLUSIVO PARA MÓVIL
// Contiene el diseño simplificado y espaciado.
// =================================================================
class TradingPairMobileRow extends StatelessWidget {
  final TickerEntity ticker;
  final bool isDark;
  final VoidCallback onTap;

  const TradingPairMobileRow({
    super.key,
    required this.ticker,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                _formatSymbol(ticker.symbol),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatPrice(ticker.lastPrice),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (ticker.isPriceChangePositive
                                ? AppColors.getBuyGreen(isDark)
                                : AppColors.getSellRed(isDark))
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    ticker.formattedPriceChangePercent,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: ticker.isPriceChangePositive
                          ? AppColors.getBuyGreen(isDark)
                          : AppColors.getSellRed(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatVolume(ticker.quoteVolume),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de ayuda (copiados para que el widget sea autocontenido)
  String _formatSymbol(String symbol) {
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
      } else if (value >= 0.01) {
        return value.toStringAsFixed(6);
      } else {
        return value.toStringAsFixed(8);
      }
    } catch (e) {
      return price;
    }
  }

  String _formatVolume(String volume) {
    try {
      final value = double.parse(volume);
      if (value >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return value.toStringAsFixed(2);
      }
    } catch (e) {
      return volume;
    }
  }
}
