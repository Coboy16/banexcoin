import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';

abstract class BinanceWebSocketDataSource {
  /// Stream de ticker completo para un símbolo
  Stream<TickerModel> getTickerStream(String symbol);

  /// Stream de mini ticker para un símbolo
  Stream<MiniTickerModel> getMiniTickerStream(String symbol);

  /// Stream de libro de órdenes para un símbolo
  Stream<DepthModel> getDepthStream(String symbol);

  /// Cierra todas las conexiones activas
  Future<void> dispose();
}

class BinanceWebSocketDataSourceImpl implements BinanceWebSocketDataSource {
  static const String _baseWsUrl = 'wss://stream.binance.com:9443/ws';

  // Controladores de stream para cada tipo de conexión
  final Map<String, StreamController<TickerModel>> _tickerControllers = {};
  final Map<String, StreamController<MiniTickerModel>> _miniTickerControllers =
      {};
  final Map<String, StreamController<DepthModel>> _depthControllers = {};

  // Canales de WebSocket activos
  final Map<String, WebSocketChannel> _channels = {};

  // Timers para reconexión automática
  final Map<String, Timer> _reconnectTimers = {};

  // Estados de conexión
  final Map<String, bool> _isConnected = {};

  // Configuración de reconexión
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxReconnectAttempts = 10;
  final Map<String, int> _reconnectAttempts = {};

  @override
  Stream<TickerModel> getTickerStream(String symbol) {
    final streamKey = '${symbol.toLowerCase()}@ticker';

    if (!_tickerControllers.containsKey(streamKey)) {
      _tickerControllers[streamKey] = StreamController<TickerModel>.broadcast();
      _connectTickerStream(symbol, streamKey);
    }

    return _tickerControllers[streamKey]!.stream;
  }

  @override
  Stream<MiniTickerModel> getMiniTickerStream(String symbol) {
    final streamKey = '${symbol.toLowerCase()}@miniTicker';

    if (!_miniTickerControllers.containsKey(streamKey)) {
      _miniTickerControllers[streamKey] =
          StreamController<MiniTickerModel>.broadcast();
      _connectMiniTickerStream(symbol, streamKey);
    }

    return _miniTickerControllers[streamKey]!.stream;
  }

  @override
  Stream<DepthModel> getDepthStream(String symbol) {
    final streamKey = '${symbol.toLowerCase()}@depth20@100ms';

    if (!_depthControllers.containsKey(streamKey)) {
      _depthControllers[streamKey] = StreamController<DepthModel>.broadcast();
      _connectDepthStream(symbol, streamKey);
    }

    return _depthControllers[streamKey]!.stream;
  }

  /// Conecta stream de ticker completo
  void _connectTickerStream(String symbol, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@ticker';
    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final tickerData = TickerModel.fromWebSocketJson(data);
          _tickerControllers[streamKey]?.add(tickerData);
        } catch (e) {
          print('Error parsing ticker data for $symbol: $e');
        }
      },
      onReconnect: () => _connectTickerStream(symbol, streamKey),
    );
  }

  /// Conecta stream de mini ticker
  void _connectMiniTickerStream(String symbol, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@miniTicker';
    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final miniTickerData = MiniTickerModel.fromWebSocketJson(data);
          _miniTickerControllers[streamKey]?.add(miniTickerData);
        } catch (e) {
          print('Error parsing mini ticker data for $symbol: $e');
        }
      },
      onReconnect: () => _connectMiniTickerStream(symbol, streamKey),
    );
  }

  /// Conecta stream de libro de órdenes
  void _connectDepthStream(String symbol, String streamKey) {
    final url = '$_baseWsUrl/${symbol.toLowerCase()}@depth20@100ms';
    _createConnection(
      url: url,
      streamKey: streamKey,
      onData: (data) {
        try {
          final depthData = DepthModel.fromWebSocketJson(data);
          _depthControllers[streamKey]?.add(depthData);
        } catch (e) {
          print('Error parsing depth data for $symbol: $e');
        }
      },
      onReconnect: () => _connectDepthStream(symbol, streamKey),
    );
  }

  /// Crea una conexión WebSocket genérica con manejo de errores
  void _createConnection({
    required String url,
    required String streamKey,
    required Function(Map<String, dynamic>) onData,
    required VoidCallback onReconnect,
  }) {
    try {
      // Cancelar timer de reconexión anterior si existe
      _reconnectTimers[streamKey]?.cancel();

      // Cerrar canal anterior si existe
      _channels[streamKey]?.sink.close();

      // Crear nueva conexión
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels[streamKey] = channel;
      _isConnected[streamKey] = true;
      _reconnectAttempts[streamKey] = 0;

      print('Conectado a WebSocket: $url');

      // Escuchar mensajes
      channel.stream.listen(
        (message) {
          try {
            final data = json.decode(message as String) as Map<String, dynamic>;
            onData(data);
          } catch (e) {
            print('Error decodificando mensaje de $streamKey: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket $streamKey: $error');
          _handleConnectionError(streamKey, onReconnect);
        },
        onDone: () {
          print('WebSocket cerrado: $streamKey');
          _handleConnectionError(streamKey, onReconnect);
        },
      );
    } catch (e) {
      print('Error creando conexión WebSocket para $streamKey: $e');
      _handleConnectionError(streamKey, onReconnect);
    }
  }

  /// Maneja errores de conexión y reconexión automática
  void _handleConnectionError(String streamKey, VoidCallback onReconnect) {
    _isConnected[streamKey] = false;

    final attempts = _reconnectAttempts[streamKey] ?? 0;
    if (attempts < _maxReconnectAttempts) {
      _reconnectAttempts[streamKey] = attempts + 1;

      print(
        'Reintentando conexión para $streamKey (intento ${attempts + 1}/$_maxReconnectAttempts)',
      );

      _reconnectTimers[streamKey] = Timer(_reconnectDelay, () {
        if (!_isConnected[streamKey]!) {
          onReconnect();
        }
      });
    } else {
      print('Máximo número de reintentos alcanzado para $streamKey');
      _closeStream(streamKey);
    }
  }

  /// Cierra un stream específico
  void _closeStream(String streamKey) {
    _channels[streamKey]?.sink.close();
    _channels.remove(streamKey);
    _reconnectTimers[streamKey]?.cancel();
    _reconnectTimers.remove(streamKey);
    _isConnected.remove(streamKey);
    _reconnectAttempts.remove(streamKey);

    // Cerrar controladores apropiados
    if (streamKey.contains('@ticker') && !streamKey.contains('@miniTicker')) {
      _tickerControllers[streamKey]?.close();
      _tickerControllers.remove(streamKey);
    } else if (streamKey.contains('@miniTicker')) {
      _miniTickerControllers[streamKey]?.close();
      _miniTickerControllers.remove(streamKey);
    } else if (streamKey.contains('@depth')) {
      _depthControllers[streamKey]?.close();
      _depthControllers.remove(streamKey);
    }
  }

  /// Verifica el estado de conexión de un stream
  bool isConnected(String streamKey) {
    return _isConnected[streamKey] ?? false;
  }

  /// Obtiene estadísticas de conexión
  Map<String, dynamic> getConnectionStats() {
    return {
      'activeConnections': _channels.length,
      'connectedStreams': _isConnected.values.where((c) => c).length,
      'reconnectAttempts': Map.from(_reconnectAttempts),
    };
  }

  @override
  Future<void> dispose() async {
    // Cancelar todos los timers
    for (final timer in _reconnectTimers.values) {
      timer.cancel();
    }
    _reconnectTimers.clear();

    // Cerrar todos los canales
    for (final channel in _channels.values) {
      await channel.sink.close();
    }
    _channels.clear();

    // Cerrar todos los controladores
    for (final controller in _tickerControllers.values) {
      await controller.close();
    }
    _tickerControllers.clear();

    for (final controller in _miniTickerControllers.values) {
      await controller.close();
    }
    _miniTickerControllers.clear();

    for (final controller in _depthControllers.values) {
      await controller.close();
    }
    _depthControllers.clear();

    _isConnected.clear();
    _reconnectAttempts.clear();

    print('BinanceWebSocketDataSource cerrado completamente');
  }
}
