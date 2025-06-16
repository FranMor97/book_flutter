import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:book_app_f/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

import 'dtos/user_dto.dart';

part 'reading_group.g.dart';

@JsonSerializable()
class GroupMember {
  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'role')
  final String role; // 'admin' or 'member'

  @JsonKey(name: 'currentPage')
  final int currentPage;

  @JsonKey(
      name: 'joinedAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime joinedAt;

  // Ya no es @JsonKey(ignore: true) porque ahora viene del backend
  @JsonKey(name: 'user')
  final User? user; // User object (populated from backend)

  GroupMember({
    required this.userId,
    required this.role,
    required this.currentPage,
    required this.joinedAt,
    this.user,
  });

  // From JSON
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    // Manejar el caso en que 'user' venga como objeto
    User? userObj;
    if (json['user'] != null) {
      userObj = User.fromJson(json['user']);
    }

    return GroupMember(
      userId: json['userId'],
      role: json['role'] ?? 'member',
      currentPage: json['currentPage'] ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      user: userObj,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}

@JsonSerializable()
class ReadingGoal {
  @JsonKey(name: 'pagesPerDay')
  final int? pagesPerDay;

  @JsonKey(
      name: 'targetFinishDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? targetFinishDate;

  ReadingGoal({
    this.pagesPerDay,
    this.targetFinishDate,
  });

  // From JSON
  factory ReadingGoal.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReadingGoal();
    return _$ReadingGoalFromJson(json);
  }

  // To JSON
  Map<String, dynamic> toJson() => _$ReadingGoalToJson(this);

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromNullableJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToNullableJson(DateTime? date) =>
      date?.toIso8601String();
}

@JsonSerializable()
class ReadingGroup {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'bookId')
  final String bookId;

  @JsonKey(name: 'creatorId')
  final String creatorId;

  @JsonKey(name: 'members')
  final List<GroupMember> members;

  @JsonKey(name: 'isPrivate')
  final bool isPrivate;

  @JsonKey(name: 'readingGoal')
  final ReadingGoal? readingGoal;

  @JsonKey(
      name: 'createdAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  @JsonKey(
      name: 'updatedAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  BookDto? book;

  UserDto? creator;

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

  ReadingGroup copyWithRelatedData({
    BookDto? book,
    UserDto? creator,
  }) {
    return ReadingGroup(
      id: id,
      name: name,
      description: description,
      bookId: bookId,
      creatorId: creatorId,
      members: members,
      isPrivate: isPrivate,
      readingGoal: readingGoal,
      createdAt: createdAt,
      updatedAt: updatedAt,
      book: book ?? this.book,
      creator: creator ?? this.creator,
    );
  }

  // From JSON
  factory ReadingGroup.fromJson(Map<String, dynamic> json) {
    // Manejar id (puede venir como _id o id)
    final String groupId = json['id'] ?? json['_id'];

    // Manejar bookId (podría ser un string directo o venir de un objeto)
    String bookIdValue;
    if (json ['bookId'] is Map) {
      bookIdValue = json['bookId']['id'] ?? json['bookId']['_id'];
    } else {
      bookIdValue = json['bookId'];
    }

    // Manejar creatorId (podría ser un string directo o venir de un objeto)
    String creatorIdValue;
    if (json['creatorId'] is Map) {
      creatorIdValue = json['creatorId']['id'] ?? json['creatorId']['_id'];
    } else {
      creatorIdValue = json['creatorId'];
    }

    // Procesar miembros
    List<GroupMember> membersList = [];
    if (json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => GroupMember.fromJson(member))
          .toList();
    }

    return ReadingGroup(
      id: groupId,
      name: json['name'],
      description: json['description'],
      bookId: bookIdValue,
      creatorId: creatorIdValue,
      members: membersList,
      isPrivate: json['isPrivate'] ?? false,
      readingGoal: json['readingGoal'] != null
          ? ReadingGoal.fromJson(json['readingGoal'])
          : null,
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );
  }

  // To JSON
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
      'createdAt': _dateTimeToJson(createdAt),
      'updatedAt': _dateTimeToJson(updatedAt),
      // No incluimos book y creator en toJson ya que son
      // objetos de solo lectura que vienen del backend
    };
  }

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Utility methods
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
