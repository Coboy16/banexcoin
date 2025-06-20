enum LiquidityQuality {
  excellent,
  good,
  fair,
  poor;

  String get displayName {
    switch (this) {
      case LiquidityQuality.excellent:
        return 'Excelente';
      case LiquidityQuality.good:
        return 'Buena';
      case LiquidityQuality.fair:
        return 'Regular';
      case LiquidityQuality.poor:
        return 'Pobre';
    }
  }
}
