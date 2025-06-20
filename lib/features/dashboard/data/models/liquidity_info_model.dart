import '/features/features.dart';

class LiquidityInfo {
  final double bidLiquidity; // Liquidez total en bids
  final double askLiquidity; // Liquidez total en asks
  final double totalLiquidity; // Liquidez total
  final double liquidityRatio; // Ratio bid/ask
  final int depthLevels; // Niveles de profundidad
  final double averageOrderSize; // Tamaño promedio de orden

  LiquidityInfo({
    required this.bidLiquidity,
    required this.askLiquidity,
    required this.totalLiquidity,
    required this.liquidityRatio,
    required this.depthLevels,
    required this.averageOrderSize,
  });

  factory LiquidityInfo.fromDepth(DepthEntity depth) {
    final bidLiquidity = depth.bids.fold<double>(
      0.0,
      (sum, bid) => sum + bid.totalValue,
    );

    final askLiquidity = depth.asks.fold<double>(
      0.0,
      (sum, ask) => sum + ask.totalValue,
    );

    final totalLiquidity = bidLiquidity + askLiquidity;
    final liquidityRatio = askLiquidity > 0 ? bidLiquidity / askLiquidity : 0.0;
    final depthLevels = depth.bids.length + depth.asks.length;
    final averageOrderSize = depthLevels > 0
        ? totalLiquidity / depthLevels
        : 0.0;

    return LiquidityInfo(
      bidLiquidity: bidLiquidity,
      askLiquidity: askLiquidity,
      totalLiquidity: totalLiquidity,
      liquidityRatio: liquidityRatio,
      depthLevels: depthLevels,
      averageOrderSize: averageOrderSize,
    );
  }
}
