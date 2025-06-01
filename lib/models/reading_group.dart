// lib/models/reading_group.dart
import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:book_app_f/models/user.dart';

class GroupMember {
  final String userId;
  final String role; // 'admin' o 'member'
  final int currentPage;
  final DateTime joinedAt;
  final User? user; // Usuario completo (opcional)

  GroupMember({
    required this.userId,
    required this.role,
    required this.currentPage,
    required this.joinedAt,
    this.user,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'] is Map
          ? json['userId']['_id'] ?? json['userId']['id']
          : json['userId'],
      role: json['role'] ?? 'member',
      currentPage: json['currentPage'] ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      user: json['userId'] is Map ? User.fromJson(json['userId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
      'currentPage': currentPage,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class ReadingGoal {
  final int? pagesPerDay;
  final DateTime? targetFinishDate;

  ReadingGoal({
    this.pagesPerDay,
    this.targetFinishDate,
  });

  factory ReadingGoal.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReadingGoal();
    return ReadingGoal(
      pagesPerDay: json['pagesPerDay'],
      targetFinishDate: json['targetFinishDate'] != null
          ? DateTime.parse(json['targetFinishDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagesPerDay': pagesPerDay,
      'targetFinishDate': targetFinishDate?.toIso8601String(),
    };
  }
}

class ReadingGroup {
  final String id;
  final String name;
  final String? description;
  final String bookId;
  final String creatorId;
  final List<GroupMember> members;
  final bool isPrivate;
  final ReadingGoal? readingGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos adicionales que pueden ser útiles
  final BookDto? book; // Libro completo (opcional)
  final User? creator; // Creador del grupo (opcional)

  ReadingGroup({
    required this.id,
    required this.name,
    this.description,
    required this.bookId,
    required this.creatorId,
    required this.members,
    required this.isPrivate,
    this.readingGoal,
    required this.createdAt,
    required this.updatedAt,
    this.book,
    this.creator,
  });

  factory ReadingGroup.fromJson(Map<String, dynamic> json) {
    List<GroupMember> membersList = [];
    if (json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => GroupMember.fromJson(member))
          .toList();
    }

    return ReadingGroup(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      bookId: json['bookId'] is Map
          ? json['bookId']['_id'] ?? json['bookId']['id']
          : json['bookId'],
      creatorId: json['creatorId'] is Map
          ? json['creatorId']['_id'] ?? json['creatorId']['id']
          : json['creatorId'],
      members: membersList,
      isPrivate: json['isPrivate'] ?? false,
      readingGoal: json['readingGoal'] != null
          ? ReadingGoal.fromJson(json['readingGoal'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      book: json['bookId'] is Map ? BookDto.fromJson(json['bookId']) : null,
      creator:
          json['creatorId'] is Map ? User.fromJson(json['creatorId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bookId': bookId,
      'creatorId': creatorId,
      'members': members.map((member) => member.toJson()).toList(),
      'isPrivate': isPrivate,
      'readingGoal': readingGoal?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool isMember(String userId) {
    return members.any((member) => member.userId == userId);
  }

  bool isAdmin(String userId) {
    return members
        .any((member) => member.userId == userId && member.role == 'admin');
  }

  GroupMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }
}
