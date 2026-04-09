import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  /// WebSocket server URL, or null to disable.
  ///
  /// WARNING: Default URL 'wss://ws.ifelse.io' is a public echo service for demo purposes only.
  /// For production, replace with your own WebSocket server URL or set to null to disable.
  /// 
  /// Note: This service is currently disabled in favor of Firebase Realtime Database
  /// as the primary source for doctor status updates.
  final String? url;

  WebSocketService({this.url = 'wss://ws.ifelse.io', this.enabled = true});

  WebSocketChannel? _channel;
  StreamController<String> _controller = StreamController.broadcast();
  bool _connected = false;
  // Allow disabling WS entirely (we rely on Firebase instead)
  bool enabled;

  Stream<String> get stream => _controller.stream;

  void connect() {
    if (!enabled || url == null || url!.isEmpty) {
      // No-op when disabled or when no URL is configured; prevents noisy network errors.
      return;
    }
    // Build a resilient connection that never crashes the app
    () async {
      try {
        // Attempt a socket DNS resolution first to avoid throwing inside connect
        final host = Uri.parse(url!).host;
        final lookups = await InternetAddress.lookup(host).timeout(Duration(seconds: 3));
        if (lookups.isEmpty) throw const SocketException('DNS lookup returned empty');

        final ch = await IOWebSocketChannel.connect(Uri.parse(url), pingInterval: Duration(seconds: 20));
        _channel = ch;
        _connected = true;
        // Mark online immediately on successful connect for demo
        _controller.add('online');
        ch.stream.listen((message) {
          _controller.add(message.toString());
        }, onDone: () {
          _connected = false;
          _controller.add('disconnect');
          Future.delayed(Duration(seconds: 2), connect);
        }, onError: (err) {
          _connected = false;
          _controller.add('error: $err');
          Future.delayed(Duration(seconds: 2), connect);
        });
        // Optionally request initial status
        send('status_request');
      } on SocketException catch (e) {
        _connected = false;
        _controller.add('network_error: $e');
        Future.delayed(Duration(seconds: 5), connect);
      } on TimeoutException catch (e) {
        _connected = false;
        _controller.add('timeout: $e');
        Future.delayed(Duration(seconds: 5), connect);
      } catch (e) {
        _connected = false;
        _controller.add('connect_error: $e');
        Future.delayed(Duration(seconds: 5), connect);
      }
    }();
  }

  void send(String msg) {
    if (!enabled) return;
    if (_connected && _channel != null) {
      _channel!.sink.add(msg);
    } else {
      // Not connected; try reconnect
      connect();
    }
  }

  void dispose() {
    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {}
    _controller.close();
  }
}
