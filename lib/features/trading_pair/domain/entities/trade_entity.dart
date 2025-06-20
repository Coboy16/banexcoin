import 'package:equatable/equatable.dart';

class TradeEntity extends Equatable {
  const TradeEntity({
    required this.id,
    required this.price,
    required this.quantity,
    required this.quoteQuantity,
    required this.timestamp,
    required this.isBuyerMaker,
  });

  final int id;
  final double price;
  final double quantity;
  final double quoteQuantity;
  final DateTime timestamp;
  final bool isBuyerMaker; // true si el comprador fue el maker

  /// Determina si es una orden de compra (buy)
  bool get isBuy => !isBuyerMaker;

  /// Determina si es una orden de venta (sell)
  bool get isSell => isBuyerMaker;

  /// Formatea el precio
  String get formattedPrice {
    return price >= 1 ? price.toStringAsFixed(2) : price.toStringAsFixed(4);
  }

  /// Formatea la cantidad
  String get formattedQuantity {
    return quantity.toStringAsFixed(6);
  }

  /// Formatea el timestamp
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  List<Object?> get props => [
    id,
    price,
    quantity,
    quoteQuantity,
    timestamp,
    isBuyerMaker,
  ];
}
