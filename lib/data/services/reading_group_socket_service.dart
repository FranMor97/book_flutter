// lib/data/services/reading_group_socket_service.dart
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:flutter/foundation.dart';

class ReadingGroupSocketService {
  final SocketService _socketService;

  // Callback for different events
  final Function(GroupMessage)? onNewMessage;
  final Function(Map<String, dynamic>)? onProgressUpdated;
  final Function(String)? onKickedFromGroup;

  ReadingGroupSocketService({
    required SocketService socketService,
    this.onNewMessage,
    this.onProgressUpdated,
    this.onKickedFromGroup,
  }) : _socketService = socketService {
    _init();
  }

  void _init() {
    // Escuchar eventos del servidor
    _socketService.on('group-message:new', _handleNewMessage);
    _socketService.on('reading-progress:updated', _handleProgressUpdated);
    _socketService.on('group:kicked', _handleKickedFromGroup);

    // Debug: Agregar listeners para eventos comunes
    if (kDebugMode) {
      _socketService.on('connected', (data) {
        debugPrint('Socket connected event: $data');
      });

      _socketService.on('joined:group', (data) {
        debugPrint('Joined group event: $data');
      });

      _socketService.on('error', (data) {
        debugPrint('Socket error event: $data');
      });
    }
  }

  void dispose() {
    // Remover listeners
    _socketService.off('group-message:new');
    _socketService.off('reading-progress:updated');
    _socketService.off('group:kicked');

    if (kDebugMode) {
      _socketService.off('connected');
      _socketService.off('joined:group');
      _socketService.off('error');
    }
  }

  void _handleNewMessage(dynamic data) {
    try {
      debugPrint('Received new message data: $data');

      GroupMessage message;

      if (data is GroupMessage) {
        message = data;
      } else if (data is Map<String, dynamic>) {
        message = GroupMessage.fromJson(data);
      } else {
        debugPrint('Unknown data type for message: ${data.runtimeType}');
        return;
      }

      onNewMessage?.call(message);
    } catch (e) {
      debugPrint('Error parsing socket message: $e');
      debugPrint('Raw data: $data');
    }
  }

  void _handleProgressUpdated(dynamic data) {
    try {
      debugPrint('Progress updated data: $data');

      if (onProgressUpdated != null && data is Map<String, dynamic>) {
        onProgressUpdated!(data);
      }
    } catch (e) {
      debugPrint('Error handling progress update: $e');
    }
  }

  void _handleKickedFromGroup(dynamic data) {
    try {
      debugPrint('Kicked from group data: $data');

      if (onKickedFromGroup != null && data is Map<String, dynamic>) {
        onKickedFromGroup!(data['groupId']);
      }
    } catch (e) {
      debugPrint('Error handling kicked from group: $e');
    }
  }

  // Methods to emit events
  void joinGroupChat(String groupId) {
    debugPrint('Joining group: $groupId');
    _socketService.emit('join:group', {'groupId': groupId});
  }

  void sendGroupMessage(String groupId, String text) {
    debugPrint('Sending message to group $groupId: $text');
    _socketService
        .emit('send:group-message', {'groupId': groupId, 'text': text});
  }

  void updateReadingProgress(String groupId, int currentPage) {
    debugPrint('Updating progress for group $groupId: page $currentPage');
    _socketService.emit('update:reading-progress',
        {'groupId': groupId, 'currentPage': currentPage});
  }
}
