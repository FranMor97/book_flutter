import 'package:bloc/bloc.dart';
import 'package:book_app_f/data/repositories/book_repository.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/data/repositories/user_repository.dart';
import 'package:book_app_f/data/services/reading_group_socket_service.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:book_app_f/models/dtos/user_dto.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'reading_group_event.dart';
part 'reading_group_state.dart';

class ReadingGroupBloc extends Bloc<ReadingGroupEvent, ReadingGroupState> {
  final IReadingGroupRepository readingGroupRepository;
  final IUserRepository userRepository;
  final IBookRepository bookRepository;
  String? _currentGroupId;

  late final ReadingGroupSocketService _socketService;

  ReadingGroupBloc({
    required this.readingGroupRepository,
    required this.userRepository,
    required this.bookRepository,
    required SocketService socketService, // Hacerlo obligatorio
  }) : super(ReadingGroupInitial()) {
    _socketService = ReadingGroupSocketService(
      socketService: socketService,
      onNewMessage: _handleNewSocketMessage,
      onProgressUpdated: _handleProgressUpdate,
      onKickedFromGroup: _handleKickedFromGroup,
    );

    on<ReadingGroupLoadUserGroups>(_onLoadUserGroups);
    on<ReadingGroupLoadById>(_onLoadById);
    on<ReadingGroupCreate>(_onCreate);
    on<ReadingGroupUpdate>(_onUpdate);
    on<ReadingGroupSearchPublic>(_onSearchPublic);
    on<ReadingGroupJoin>(_onJoin);
    on<ReadingGroupLeave>(_onLeave);
    on<ReadingGroupManageMember>(_onManageMember);
    on<ReadingGroupUpdateProgress>(_onUpdateProgress);
    on<ReadingGroupLoadMessages>(_onLoadMessages);
    on<ReadingGroupSendMessage>(_onSendMessage);
    on<ReadingGroupReceiveMessage>(_onReceiveMessage);
    on<ReadingGroupReceiveProgressUpdate>(_onReceiveProgressUpdate);
    on<ReadingGroupKicked>(_onKicked);
  }

  @override
  Future<void> close() {
    _socketService?.dispose();
    return super.close();
  }

  // Socket event handlers
  void _handleNewSocketMessage(GroupMessage message) {
    add(ReadingGroupReceiveMessage(message: message));
  }

  void _handleProgressUpdate(Map<String, dynamic> data) {
    add(ReadingGroupReceiveProgressUpdate(data: data));
  }

  void _handleKickedFromGroup(String groupId) {
    add(ReadingGroupKicked(groupId: groupId));
  }

  // Event handlers
  Future<void> _onLoadUserGroups(
    ReadingGroupLoadUserGroups event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupLoading());

    try {
      final groups = await readingGroupRepository.getUserGroups();
      emit(ReadingGroupUserGroupsLoaded(groups: groups));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onLoadById(
    ReadingGroupLoadById event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupLoading());

    try {
      ReadingGroup group =
          await readingGroupRepository.getGroupById(event.groupId);

      _currentGroupId = event.groupId;
      // Join group chat via socket
      _socketService.joinGroupChat(event.groupId);

      UserDto? creator = await userRepository.getUserById(group.creatorId);
      BookDto? book = await bookRepository.getBookById(group.bookId);
      group = group.copyWithRelatedData(
        creator: creator,
        book: book,
      );

      emit(ReadingGroupLoaded(group: group));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onCreate(
    ReadingGroupCreate event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupActionInProgress());

    try {
      final group = await readingGroupRepository.createGroup(
        name: event.name,
        description: event.description,
        bookId: event.bookId,
        isPrivate: event.isPrivate,
        readingGoal: event.readingGoal,
      );

      emit(ReadingGroupCreated(group: group));

      // Load user groups after creation
      add(ReadingGroupLoadUserGroups());
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onUpdate(
    ReadingGroupUpdate event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupActionInProgress());

    try {
      final group = await readingGroupRepository.updateGroup(
        groupId: event.groupId,
        name: event.name,
        description: event.description,
        isPrivate: event.isPrivate,
        readingGoal: event.readingGoal,
      );

      emit(ReadingGroupUpdated(group: group));

      // Reload the group to show updated information
      add(ReadingGroupLoadById(groupId: event.groupId));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onSearchPublic(
    ReadingGroupSearchPublic event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupSearching());

    try {
      final groups = await readingGroupRepository.searchPublicGroups(
        query: event.query,
        page: event.page,
        limit: event.limit,
      );

      emit(ReadingGroupPublicSearchResults(
        groups: groups,
        query: event.query,
        page: event.page,
        hasMorePages: groups.length >= event.limit,
      ));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onJoin(
    ReadingGroupJoin event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupActionInProgress());

    try {
      final group = await readingGroupRepository.joinGroup(event.groupId);

      // Join the group chat via socket
      _socketService?.joinGroupChat(event.groupId);

      emit(ReadingGroupJoined(group: group));

      // Reload user groups after joining
      add(ReadingGroupLoadUserGroups());
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onLeave(
    ReadingGroupLeave event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupActionInProgress());

    try {
      await readingGroupRepository.leaveGroup(event.groupId);
      emit(const ReadingGroupLeft());

      // Reload user groups after leaving
      add(ReadingGroupLoadUserGroups());
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onManageMember(
    ReadingGroupManageMember event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupActionInProgress());

    try {
      final group = await readingGroupRepository.manageMember(
        groupId: event.groupId,
        memberId: event.memberId,
        action: event.action,
      );

      emit(ReadingGroupMemberManaged(
        group: group,
        memberId: event.memberId,
        action: event.action,
      ));

      // Reload group to show updated members
      add(ReadingGroupLoadById(groupId: event.groupId));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProgress(
    ReadingGroupUpdateProgress event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupActionInProgress());

    try {
      // Update via API
      final group = await readingGroupRepository.updateReadingProgress(
        groupId: event.groupId,
        currentPage: event.currentPage,
      );

      // Also update via socket for real-time updates to other members
      _socketService?.updateReadingProgress(event.groupId, event.currentPage);

      emit(ReadingGroupProgressUpdated(
        group: group,
        currentPage: event.currentPage,
      ));

      // Reload group to show updated progress
      add(ReadingGroupLoadById(groupId: event.groupId));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    ReadingGroupLoadMessages event,
    Emitter<ReadingGroupState> emit,
  ) async {
    // If it's a refresh (page 1), show loading state
    if (event.page == 1) {
      emit(ReadingGroupMessagesLoading());
    } else {
      // For pagination, we need to keep the current state (don't show loading)
      final currentState = state;
      if (currentState is ReadingGroupMessagesLoaded) {
        emit(ReadingGroupMessagesLoadingMore(
          groupId: currentState.groupId,
          messages: currentState.messages,
          page: currentState.page,
        ));
      }
    }

    try {
      final messages = await readingGroupRepository.getGroupMessages(
        groupId: event.groupId,
        page: event.page,
        limit: event.limit,
      );

      // If we're loading a page beyond the first, we need to combine messages
      final currentState = state;
      if (currentState is ReadingGroupMessagesLoaded && event.page > 1) {
        final combinedMessages = [...currentState.messages, ...messages];
        emit(ReadingGroupMessagesLoaded(
          groupId: event.groupId,
          messages: combinedMessages,
          page: event.page,
          isFirstLoad: false,
          hasMoreMessages: messages.length >= event.limit,
        ));
      } else {
        // First load or refresh
        emit(ReadingGroupMessagesLoaded(
          groupId: event.groupId,
          messages: messages,
          page: event.page,
          isFirstLoad: event.page == 1,
          hasMoreMessages: messages.length >= event.limit,
        ));
      }
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    ReadingGroupSendMessage event,
    Emitter<ReadingGroupState> emit,
  ) async {
    // Store current state to return to it if needed
    final currentState = state;

    try {
      // Send message via API
      final message = await readingGroupRepository.sendGroupMessage(
        groupId: event.groupId,
        text: event.text,
      );

      // Also send via socket for real-time updates
      _socketService?.sendGroupMessage(event.groupId, event.text);

      // If we're in the messages state, update it with the new message
      if (currentState is ReadingGroupMessagesLoaded) {
        // Add the new message to the top of the list (most recent first)
        final updatedMessages = [message, ...currentState.messages];

        emit(ReadingGroupMessagesLoaded(
          groupId: currentState.groupId,
          messages: updatedMessages,
          page: currentState.page,
          isFirstLoad: false,
          hasMoreMessages: currentState.hasMoreMessages,
        ));
      }

      // Emit a specific "message sent" state that can be used for showing a temporary notification
      emit(ReadingGroupMessageSent(message: message));

      // Return to the previous state if needed
      if (currentState is ReadingGroupState &&
          !(currentState is ReadingGroupMessagesLoaded)) {
        emit(currentState);
      }
    } catch (e) {
      emit(ReadingGroupMessageError(message: e.toString()));

      // Return to the previous state after showing the error
      if (currentState is ReadingGroupState) {
        emit(currentState);
      }
    }
  }

  // Handle real-time updates from sockets
  void _onReceiveMessage(
    ReadingGroupReceiveMessage event,
    Emitter<ReadingGroupState> emit,
  ) {
    final currentState = state;

    if (currentState is ReadingGroupMessagesLoaded &&
        event.message.groupId == currentState.groupId) {
      // Verificar si el mensaje ya existe
      final messageExists =
          currentState.messages.any((m) => m.id == event.message.id);

      if (!messageExists) {
        // Crear una nueva lista con el mensaje nuevo al principio
        final updatedMessages = [event.message, ...currentState.messages];

        // Emitir un nuevo estado con la lista actualizada y la bandera para scrollear
        emit(currentState.copyWith(
          messages: updatedMessages,
          needsToScrollToBottom: true,
        ));
      }
    }
  }

  void _onReceiveProgressUpdate(
    ReadingGroupReceiveProgressUpdate event,
    Emitter<ReadingGroupState> emit,
  ) {
    final currentState = state;
    if (currentState is ReadingGroupLoaded) {
      // Extract data from the socket event
      final String userId = event.data['userId'];
      final int currentPage = event.data['currentPage'];
      final String groupId = event.data['groupId'];

      // Only update if this is for the current group
      if (groupId == currentState.group.id) {
        // Update the member's progress in the group
        final updatedMembers = currentState.group.members.map((member) {
          if (member.userId == userId) {
            // Create a new member with updated progress
            return GroupMember(
              userId: member.userId,
              role: member.role,
              currentPage: currentPage,
              joinedAt: member.joinedAt,
              user: member.user,
            );
          }
          return member;
        }).toList();

        // Create a new group with updated members
        final updatedGroup = ReadingGroup(
          id: currentState.group.id,
          name: currentState.group.name,
          description: currentState.group.description,
          bookId: currentState.group.bookId,
          creatorId: currentState.group.creatorId,
          members: updatedMembers,
          isPrivate: currentState.group.isPrivate,
          readingGoal: currentState.group.readingGoal,
          createdAt: currentState.group.createdAt,
          updatedAt: currentState.group.updatedAt,
        );

        emit(ReadingGroupLoaded(group: updatedGroup));
      }
    }
  }

  void _onKicked(
    ReadingGroupKicked event,
    Emitter<ReadingGroupState> emit,
  ) {
    final currentState = state;

    // Emit a kicked state to notify the user
    emit(ReadingGroupKickedFromGroup(groupId: event.groupId));

    // If the user was viewing the group they were kicked from, redirect to groups list
    if (currentState is ReadingGroupLoaded &&
        currentState.group.id == event.groupId) {
      // Reload user groups to get updated list
      add(ReadingGroupLoadUserGroups());
    } else if (currentState is ReadingGroupState) {
      // Otherwise return to previous state
      emit(currentState);
    }
  }
}
