enum AlertSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Baja';
      case AlertSeverity.medium:
        return 'Media';
      case AlertSeverity.high:
        return 'Alta';
      case AlertSeverity.critical:
        return 'Crítica';
    }
  }
}
