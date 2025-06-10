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
    // Listen to socket events related to reading groups
    _socketService.on('group-message:new', _handleNewMessage);
    _socketService.on('reading-progress:updated', _handleProgressUpdated);
    _socketService.on('group:kicked', _handleKickedFromGroup);
  }

  void dispose() {
    // Remove listeners when not needed
    _socketService.off('group-message:new');
    _socketService.off('reading-progress:updated');
    _socketService.off('group:kicked');
  }

  void _handleNewMessage(dynamic data) {
    try {
      final message = GroupMessage.fromJson(data);
      if (onNewMessage != null) {
        onNewMessage!(message);
      }
    } catch (e) {
      debugPrint('Error parsing socket message: $e');
    }
  }

  void _handleProgressUpdated(dynamic data) {
    try {
      if (onProgressUpdated != null) {
        onProgressUpdated!(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error handling progress update: $e');
    }
  }

  void _handleKickedFromGroup(dynamic data) {
    try {
      if (onKickedFromGroup != null && data is Map<String, dynamic>) {
        onKickedFromGroup!(data['groupId']);
      }
    } catch (e) {
      debugPrint('Error handling kicked from group: $e');
    }
  }

  // Methods to emit events
  void joinGroupChat(String groupId) {
    _socketService.emit('join:group', {'groupId': groupId});
  }

  void sendGroupMessage(String groupId, String text) {
    _socketService
        .emit('send:group-message', {'groupId': groupId, 'text': text});
  }

  void updateReadingProgress(String groupId, int currentPage) {
    _socketService.emit('update:reading-progress',
        {'groupId': groupId, 'currentPage': currentPage});
  }
}
