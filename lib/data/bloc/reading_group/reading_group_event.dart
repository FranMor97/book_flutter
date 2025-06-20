// lib/data/bloc/reading_group/reading_group_event.dart
part of 'reading_group_bloc.dart';

@immutable
abstract class ReadingGroupEvent extends Equatable {
  const ReadingGroupEvent();

  @override
  List<Object?> get props => [];
}

class ReadingGroupLoadUserGroups extends ReadingGroupEvent {}

class ReadingGroupLoadById extends ReadingGroupEvent {
  final String groupId;

  const ReadingGroupLoadById({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class ReadingGroupCreate extends ReadingGroupEvent {
  final String name;
  final String? description;
  final String bookId;
  final bool isPrivate;
  final ReadingGoal? readingGoal;
  final List<String>? memberIds; // Nuevo campo para los IDs de miembros

  const ReadingGroupCreate({
    required this.name,
    this.description,
    required this.bookId,
    this.isPrivate = false,
    this.readingGoal,
    this.memberIds,
  });

  @override
  List<Object?> get props =>
      [name, description, bookId, isPrivate, readingGoal, memberIds];
}

class ReadingGroupUpdate extends ReadingGroupEvent {
  final String groupId;
  final String? name;
  final String? description;
  final bool? isPrivate;
  final ReadingGoal? readingGoal;

  const ReadingGroupUpdate({
    required this.groupId,
    this.name,
    this.description,
    this.isPrivate,
    this.readingGoal,
  });

  @override
  List<Object?> get props =>
      [groupId, name, description, isPrivate, readingGoal];
}

class ReadingGroupSearchPublic extends ReadingGroupEvent {
  final String? query;
  final int page;
  final int limit;

  const ReadingGroupSearchPublic({
    this.query,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

class ReadingGroupJoin extends ReadingGroupEvent {
  final String groupId;

  const ReadingGroupJoin({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class ReadingGroupLeave extends ReadingGroupEvent {
  final String groupId;

  const ReadingGroupLeave({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class ReadingGroupManageMember extends ReadingGroupEvent {
  final String groupId;
  final String memberId;
  final String action; // 'promote', 'demote', 'kick'

  const ReadingGroupManageMember({
    required this.groupId,
    required this.memberId,
    required this.action,
  });

  @override
  List<Object?> get props => [groupId, memberId, action];
}

class ReadingGroupUpdateProgress extends ReadingGroupEvent {
  final String groupId;
  final int currentPage;

  const ReadingGroupUpdateProgress({
    required this.groupId,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [groupId, currentPage];
}

class ReadingGroupLoadMessages extends ReadingGroupEvent {
  final String groupId;
  final int page;
  final int limit;

  const ReadingGroupLoadMessages({
    required this.groupId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [groupId, page, limit];
}

class ReadingGroupSendMessage extends ReadingGroupEvent {
  final String groupId;
  final String text;

  const ReadingGroupSendMessage({
    required this.groupId,
    required this.text,
  });

  @override
  List<Object?> get props => [groupId, text];
}

// New socket-related events
class ReadingGroupReceiveMessage extends ReadingGroupEvent {
  final GroupMessage message;

  const ReadingGroupReceiveMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReadingGroupReceiveProgressUpdate extends ReadingGroupEvent {
  final Map<String, dynamic> data;

  const ReadingGroupReceiveProgressUpdate({required this.data});

  @override
  List<Object?> get props => [data];
}

class ReadingGroupKicked extends ReadingGroupEvent {
  final String groupId;

  const ReadingGroupKicked({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
