import '/features/features.dart';

class ExchangeInfo {
  final String timezone;
  final DateTime serverTime;
  final List<SymbolInfo> symbols;

  ExchangeInfo({
    required this.timezone,
    required this.serverTime,
    required this.symbols,
  });

  /// Busca información de un símbolo específico
  SymbolInfo? getSymbolInfo(String symbol) {
    try {
      return symbols.firstWhere(
        (s) => s.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene símbolos activos para trading
  List<SymbolInfo> get activeSymbols =>
      symbols.where((s) => s.isActive).toList();
}
