import 'dart:convert';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class IReadingGroupRepository {
  Future<List<ReadingGroup>> getUserGroups();
  Future<ReadingGroup> getGroupById(String groupId);
  Future<ReadingGroup> createGroup({
    required String name,
    String? description,
    required String bookId,
    bool isPrivate = false,
    ReadingGoal? readingGoal,
  });
  Future<ReadingGroup> updateGroup({
    required String groupId,
    String? name,
    String? description,
    bool? isPrivate,
    ReadingGoal? readingGoal,
  });
  Future<List<ReadingGroup>> searchPublicGroups({
    String? query,
    int page = 1,
    int limit = 10,
  });
  Future<ReadingGroup> joinGroup(String groupId);
  Future<void> leaveGroup(String groupId);
  Future<ReadingGroup> manageMember({
    required String groupId,
    required String memberId,
    required String action,
  });
  Future<ReadingGroup> updateReadingProgress({
    required String groupId,
    required int currentPage,
  });
  Future<List<GroupMessage>> getGroupMessages({
    required String groupId,
    int page = 1,
    int limit = 20,
  });
  Future<GroupMessage> sendGroupMessage({
    required String groupId,
    required String text,
  });
}
