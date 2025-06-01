// lib/services/socket_service.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void initSocket(String apiUrl, String token) {
    _disconnect();

    _socket = IO.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': token,
      },
      'extraHeaders': {
        'Authorization': token,
      },
    });

    _socket?.onConnect((_) {
      print('Socket.IO conectado');
      _isConnected = true;
      notifyListeners();
    });

    _socket?.onDisconnect((_) {
      print('Socket.IO desconectado');
      _isConnected = false;
      notifyListeners();
    });

    _socket?.onError((error) {
      print('Socket.IO error: $error');
    });

    _socket?.onConnectError((error) {
      print('Socket.IO error de conexión: $error');
    });
  }

  // Desconectar el socket
  void _disconnect() {
    if (_socket != null) {
      if (_socket!.connected) {
        _socket!.disconnect();
      }
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  void disconnect() {
    _disconnect();
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    } else {
      print('Socket.IO no conectado, no se puede emitir "$event"');
    }
  }

  void joinGroupChat(String groupId) {
    emit('join:group', {'groupId': groupId});
  }

  void sendGroupMessage(String groupId, String text) {
    emit('send:group-message', {'groupId': groupId, 'text': text});
  }

  void updateReadingProgress(String groupId, int currentPage) {
    emit('update:reading-progress',
        {'groupId': groupId, 'currentPage': currentPage});
  }
}
