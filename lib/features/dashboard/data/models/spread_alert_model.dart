import '/features/features.dart';

class SpreadAlert {
  final String symbol;
  final double spread;
  final double spreadPercent;
  final double bestBid;
  final double bestAsk;
  final DateTime timestamp;

  SpreadAlert({
    required this.symbol,
    required this.spread,
    required this.spreadPercent,
    required this.bestBid,
    required this.bestAsk,
    required this.timestamp,
  });

  /// Severidad de la alerta basada en el spread
  AlertSeverity get severity {
    if (spreadPercent > 5.0) return AlertSeverity.critical;
    if (spreadPercent > 2.0) return AlertSeverity.high;
    if (spreadPercent > 1.0) return AlertSeverity.medium;
    return AlertSeverity.low;
  }

  /// Mensaje descriptivo de la alerta
  String get message {
    return 'Spread alto detectado en $symbol: '
        '${spreadPercent.toStringAsFixed(2)}% '
        '(Bid: \${bestBid.toStringAsFixed(4)}, '
        'Ask: \${bestAsk.toStringAsFixed(4)})';
  }
}
