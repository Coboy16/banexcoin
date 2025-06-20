import 'package:equatable/equatable.dart';

class DepthEntity extends Equatable {
  const DepthEntity({
    required this.lastUpdateId,
    required this.bids,
    required this.asks,
  });

  final int lastUpdateId; // ID de la última actualización
  final List<OrderLevel> bids; // Órdenes de compra (precio, cantidad)
  final List<OrderLevel> asks; // Órdenes de venta (precio, cantidad)

  /// Obtiene el mejor precio de compra (bid más alto)
  double? get bestBidPrice => bids.isNotEmpty ? bids.first.price : null;

  /// Obtiene el mejor precio de venta (ask más bajo)
  double? get bestAskPrice => asks.isNotEmpty ? asks.first.price : null;

  /// Calcula el spread entre bid y ask
  double? get spread {
    final bid = bestBidPrice;
    final ask = bestAskPrice;
    if (bid != null && ask != null) {
      return ask - bid;
    }
    return null;
  }

  /// Calcula el spread en porcentaje
  double? get spreadPercent {
    final bid = bestBidPrice;
    final ask = bestAskPrice;
    if (bid != null && ask != null && bid > 0) {
      return ((ask - bid) / bid) * 100;
    }
    return null;
  }

  @override
  List<Object?> get props => [lastUpdateId, bids, asks];
}

/// Representa un nivel de precio en el libro de órdenes
class OrderLevel extends Equatable {
  const OrderLevel({required this.price, required this.quantity});

  final double price; // Precio del nivel
  final double quantity; // Cantidad disponible en este precio

  /// Formatea el precio con decimales apropiados
  String get formattedPrice {
    return price >= 1 ? price.toStringAsFixed(2) : price.toStringAsFixed(4);
  }

  /// Formatea la cantidad con decimales apropiados
  String get formattedQuantity {
    return quantity.toStringAsFixed(6);
  }

  /// Calcula el valor total (precio × cantidad)
  double get totalValue => price * quantity;

  /// Formatea el valor total
  String get formattedTotalValue {
    return totalValue.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [price, quantity];
}
