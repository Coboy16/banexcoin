import '/features/features.dart';

class ConnectivityStatus {
  final bool isConnected;
  final DateTime checkedAt;
  final MarketStatistics? marketStatistics;
  final String? error;

  ConnectivityStatus({
    required this.isConnected,
    required this.checkedAt,
    this.marketStatistics,
    this.error,
  });

  /// Obtiene el estado como texto
  String get statusText {
    if (isConnected) {
      return 'Conectado - ${marketStatistics?.totalTradingPairs ?? 0} pares activos';
    } else {
      return 'Desconectado${error != null ? ' - $error' : ''}';
    }
  }

  /// Determina si se necesita reintentar
  bool get shouldRetry {
    return !isConnected &&
        DateTime.now().difference(checkedAt) > const Duration(minutes: 1);
  }
}
