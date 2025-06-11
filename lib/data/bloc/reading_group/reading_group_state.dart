part of 'reading_group_bloc.dart';

@immutable
abstract class ReadingGroupState extends Equatable {
  const ReadingGroupState();

  @override
  List<Object?> get props => [];
}

class ReadingGroupInitial extends ReadingGroupState {}

class ReadingGroupLoading extends ReadingGroupState {}

class ReadingGroupSearching extends ReadingGroupState {}

class ReadingGroupActionInProgress extends ReadingGroupState {}

class ReadingGroupMessagesLoading extends ReadingGroupState {}

class ReadingGroupMessagesLoadingMore extends ReadingGroupState {
  final String groupId;
  final List<GroupMessage> messages;
  final int page;

  const ReadingGroupMessagesLoadingMore({
    required this.groupId,
    required this.messages,
    required this.page,
  });

  @override
  List<Object?> get props => [groupId, messages, page];
}

class ReadingGroupUserGroupsLoaded extends ReadingGroupState {
  final List<ReadingGroup> groups;

  const ReadingGroupUserGroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class ReadingGroupLoaded extends ReadingGroupState {
  final ReadingGroup group;

  const ReadingGroupLoaded({
    required this.group,
  });

  @override
  List<Object?> get props => [
        group,
      ];
}

class ReadingGroupCreated extends ReadingGroupState {
  final ReadingGroup group;

  const ReadingGroupCreated({required this.group});

  @override
  List<Object?> get props => [group];
}

class ReadingGroupUpdated extends ReadingGroupState {
  final ReadingGroup group;

  const ReadingGroupUpdated({required this.group});

  @override
  List<Object?> get props => [group];
}

class ReadingGroupPublicSearchResults extends ReadingGroupState {
  final List<ReadingGroup> groups;
  final String? query;
  final int page;
  final bool hasMorePages;

  const ReadingGroupPublicSearchResults({
    required this.groups,
    this.query,
    this.page = 1,
    this.hasMorePages = false,
  });

  @override
  List<Object?> get props => [groups, query, page, hasMorePages];
}

class ReadingGroupJoined extends ReadingGroupState {
  final ReadingGroup group;

  const ReadingGroupJoined({required this.group});

  @override
  List<Object?> get props => [group];
}

class ReadingGroupLeft extends ReadingGroupState {
  const ReadingGroupLeft();
}

class ReadingGroupMemberManaged extends ReadingGroupState {
  final ReadingGroup group;
  final String memberId;
  final String action;

  const ReadingGroupMemberManaged({
    required this.group,
    required this.memberId,
    required this.action,
  });

  @override
  List<Object?> get props => [group, memberId, action];
}

class ReadingGroupProgressUpdated extends ReadingGroupState {
  final ReadingGroup group;
  final int currentPage;

  const ReadingGroupProgressUpdated({
    required this.group,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [group, currentPage];
}

class ReadingGroupMessagesLoaded extends ReadingGroupState {
  final String groupId;
  final List<GroupMessage> messages;
  final int page;
  final bool isFirstLoad;
  final bool hasMoreMessages;
  final bool needsToScrollToBottom; // Nueva propiedad

  const ReadingGroupMessagesLoaded({
    required this.groupId,
    required this.messages,
    required this.page,
    this.isFirstLoad = true,
    this.hasMoreMessages = false,
    this.needsToScrollToBottom = false, // Por defecto no es necesario scrollear
  });

  // Método de ayuda para crear un nuevo estado con mensajes actualizados
  ReadingGroupMessagesLoaded copyWith({
    String? groupId,
    List<GroupMessage>? messages,
    int? page,
    bool? isFirstLoad,
    bool? hasMoreMessages,
    bool? needsToScrollToBottom,
  }) {
    return ReadingGroupMessagesLoaded(
      groupId: groupId ?? this.groupId,
      messages: messages ?? this.messages,
      page: page ?? this.page,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      needsToScrollToBottom:
          needsToScrollToBottom ?? this.needsToScrollToBottom,
    );
  }

  @override
  List<Object?> get props => [
        groupId,
        messages,
        page,
        isFirstLoad,
        hasMoreMessages,
        needsToScrollToBottom,
      ];
}

class ReadingGroupMessageSent extends ReadingGroupState {
  final GroupMessage message;

  const ReadingGroupMessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

// New states for socket events
class ReadingGroupMessageReceived extends ReadingGroupState {
  final GroupMessage message;

  const ReadingGroupMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReadingGroupKickedFromGroup extends ReadingGroupState {
  final String groupId;

  const ReadingGroupKickedFromGroup({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class ReadingGroupOperationSuccess extends ReadingGroupState {
  final String message;

  const ReadingGroupOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReadingGroupError extends ReadingGroupState {
  final String message;

  const ReadingGroupError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ReadingGroupMessageError extends ReadingGroupState {
  final String message;

  const ReadingGroupMessageError({required this.message});

  @override
  List<Object?> get props => [message];
}
