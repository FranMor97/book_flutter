// lib/data/services/socket_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentGroupId;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;
  String? get currentGroupId => _currentGroupId;

  Future<void> initSocket(String apiUrl) async {
    _disconnect();

    // Obtener el token guardado
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('Socket.IO: No hay token de autenticación');
      return;
    }

    // Configurar socket con el token
    _socket = IO.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': token,
      },
      'extraHeaders': {
        'Authorization': 'Bearer $token',
      },
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
    });

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      print('Socket.IO conectado');
      _isConnected = true;
      notifyListeners();

      // Si estábamos en un grupo, volver a unirnos
      if (_currentGroupId != null) {
        joinGroupChat(_currentGroupId!);
      }
    });

    _socket?.onDisconnect((_) {
      print('Socket.IO desconectado');
      _isConnected = false;
      notifyListeners();
    });

    _socket?.onError((error) {
      print('Socket.IO error: $error');
      _isConnected = false;
      notifyListeners();
    });

    _socket?.onConnectError((error) {
      print('Socket.IO error de conexión: $error');
      _isConnected = false;
      notifyListeners();
    });

    _socket?.on('connected', (data) {
      print('Socket.IO: Conectado con éxito al servidor');
      if (data['groups'] != null) {
        print('Socket.IO: Grupos del usuario: ${data['groups']}');
      }
    });

    _socket?.on('joined:group', (data) {
      print('Socket.IO: Unido al grupo ${data['groupId']}');
    });

    _socket?.on('error', (data) {
      print('Socket.IO Error del servidor: ${data['message']}');
    });

    // Reconexión automática
    _socket?.on('reconnect', (_) {
      print('Socket.IO: Reconectado');
      _isConnected = true;
      notifyListeners();

      // Volver a unirse al grupo si estábamos en uno
      if (_currentGroupId != null) {
        joinGroupChat(_currentGroupId!);
      }
    });

    _socket?.on('reconnect_error', (error) {
      print('Socket.IO: Error de reconexión: $error');
    });
  }

  void _disconnect() {
    if (_socket != null) {
      _socket!.clearListeners();
      if (_socket!.connected) {
        _socket!.disconnect();
      }
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _currentGroupId = null;
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
      // Intentar reconectar si no está conectado
      _socket?.connect();
    }
  }

  void joinGroupChat(String groupId) {
    _currentGroupId = groupId;
    emit('join:group', {'groupId': groupId});
  }

  void leaveGroupChat(String groupId) {
    if (_currentGroupId == groupId) {
      _currentGroupId = null;
    }
    emit('leave:group', {'groupId': groupId});
  }

  void sendGroupMessage(String groupId, String text) {
    emit('send:group-message', {
      'groupId': groupId,
      'text': text,
    });
  }

  void updateReadingProgress(String groupId, int currentPage) {
    emit('update:reading-progress', {
      'groupId': groupId,
      'currentPage': currentPage,
    });
  }

  void subscribeToBookComments(String bookId) {
    emit('subscribe:book-comments', {'bookId': bookId});
  }

  void unsubscribeFromBookComments(String bookId) {
    emit('unsubscribe:book-comments', {'bookId': bookId});
  }

  void sendBookComment({
    required String bookId,
    required String text,
    required int rating,
    String? title,
    bool isPublic = true,
  }) {
    emit('send:book-comment', {
      'bookId': bookId,
      'text': text,
      'rating': rating,
      'title': title,
      'isPublic': isPublic,
    });
  }

  void reconnect() {
    if (!_isConnected && _socket != null) {
      _socket!.connect();
    }
  }

  void checkConnection() {
    if (_socket != null) {
      print(
          'Socket.IO Estado: ${_socket!.connected ? "Conectado" : "Desconectado"}');
      print('Socket.IO ID: ${_socket!.id}');
    } else {
      print('Socket.IO: No inicializado');
    }
  }
}
