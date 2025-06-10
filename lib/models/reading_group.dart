import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:book_app_f/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

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

  @JsonKey(ignore: true)
  final User? user; // User object (optional)

  GroupMember({
    required this.userId,
    required this.role,
    required this.currentPage,
    required this.joinedAt,
    this.user,
  });

  // From JSON
  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);

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
  @JsonKey(name: '_id')
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

  // Campos adicionales que pueden ser útiles
  @JsonKey(ignore: true)
  final BookDto? book; // Book object (optional)

  @JsonKey(ignore: true)
  final User? creator; // Creator user (optional)

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

  // From JSON
  factory ReadingGroup.fromJson(Map<String, dynamic> json) {
    // Process members array
    List<GroupMember> membersList = [];
    if (json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => GroupMember.fromJson(member))
          .toList();
    }

    // Handle id field (_id in MongoDB)
    final id = json['_id'] ?? json['id'];

    // Handle bookId and creatorId that might be objects
    final bookId = json['bookId'] is Map
        ? json['bookId']['_id'] ?? json['bookId']['id']
        : json['bookId'];

    final creatorId = json['creatorId'] is Map
        ? json['creatorId']['_id'] ?? json['creatorId']['id']
        : json['creatorId'];

    return ReadingGroup(
      id: id,
      name: json['name'],
      description: json['description'],
      bookId: bookId,
      creatorId: creatorId,
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
