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
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'reading_group_event.dart';

part 'reading_group_state.dart';

class ReadingGroupBloc extends Bloc<ReadingGroupEvent, ReadingGroupState> {
  final IReadingGroupRepository readingGroupRepository;
  final IUserRepository userRepository;
  final IBookRepository bookRepository;
  final SocketService socketService;

  String? _currentGroupId;
  ReadingGroupSocketService? _socketServiceInstance;

  // Track processed message IDs to avoid duplicates
  final Set<String> _processedMessageIds = {};

  // Track if we're currently sending a message to avoid duplicates
  bool _isSendingMessage = false;

  ReadingGroupBloc({
    required this.readingGroupRepository,
    required this.userRepository,
    required this.bookRepository,
    required this.socketService,
  }) : super(ReadingGroupInitial()) {
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

  void _initializeSocketService() {
    // Dispose previous instance if exists
    _disposeSocketService();

    _socketServiceInstance = ReadingGroupSocketService(
      socketService: socketService,
      onNewMessage: _handleNewSocketMessage,
      onProgressUpdated: _handleProgressUpdate,
      onKickedFromGroup: _handleKickedFromGroup,
    );

    debugPrint('ReadingGroupBloc: Socket service initialized');
  }

  void _disposeSocketService() {
    if (_socketServiceInstance != null) {
      _socketServiceInstance!.dispose();
      _socketServiceInstance = null;
      debugPrint('ReadingGroupBloc: Socket service disposed');
    }
  }

  @override
  Future<void> close() {
    _disposeSocketService();
    _processedMessageIds.clear();
    return super.close();
  }

  // Socket event handlers
  void _handleNewSocketMessage(GroupMessage message) {
    // Create a unique ID for the message if it doesn't have one
    final messageId = message.id ??
        '${message.userId}_${message.text}_${message.createdAt.millisecondsSinceEpoch}';

    // Check if we've already processed this message
    if (_processedMessageIds.contains(messageId)) {
      debugPrint('ReadingGroupBloc: Ignoring duplicate message: $messageId');
      return;
    }

    // Check if this message is for the current group
    if (_currentGroupId != null && message.groupId == _currentGroupId) {
      _processedMessageIds.add(messageId);

      // Clean up old message IDs if too many
      if (_processedMessageIds.length > 1000) {
        _processedMessageIds.clear();
      }

      add(ReadingGroupReceiveMessage(message: message));
    }
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
      final List<ReadingGroup> finalList = [];
      for (var group in groups) {
        ReadingGroup groupF =
            await readingGroupRepository.getGroupById(group.id);
        UserDto? creator = await userRepository.getUserById(groupF.creatorId);
        BookDto? book = await bookRepository.getBookById(groupF.bookId);
        group = group.copyWithRelatedData(
          creator: creator,
          book: book,
        );
        finalList.add(group);
      }

      emit(ReadingGroupUserGroupsLoaded(groups: finalList));
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
      // Leave previous group if different
      if (_currentGroupId != null && _currentGroupId != event.groupId) {}

      ReadingGroup group =
          await readingGroupRepository.getGroupById(event.groupId);

      _currentGroupId = event.groupId;

      // Clear processed messages when changing groups
      _processedMessageIds.clear();

      // Initialize socket service if not already done
      if (_socketServiceInstance == null) {
        _initializeSocketService();
      }

      // Join group chat via socket
      _socketServiceInstance?.joinGroupChat(event.groupId);

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
        memberIds: event.memberIds, // Pasar los memberIds
      );

      emit(ReadingGroupCreated(group: group));
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

      // Initialize socket service if needed
      if (_socketServiceInstance == null) {
        _initializeSocketService();
      }

      _socketServiceInstance?.joinGroupChat(event.groupId);

      emit(ReadingGroupJoined(group: group));
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

      // Leave socket roomDateTime.now().millisecondsSinceEpoch,

      if (_currentGroupId == event.groupId) {
        _currentGroupId = null;
      }

      emit(const ReadingGroupLeft());
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

      add(ReadingGroupLoadById(groupId: event.groupId));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProgress(
    ReadingGroupUpdateProgress event,
    Emitter<ReadingGroupState> emit,
  ) async {
    final currentState = state;

    try {
      // Update via API ONLY (server will broadcast via socket)
      final group = await readingGroupRepository.updateReadingProgress(
        groupId: event.groupId,
        currentPage: event.currentPage,
      );

      // Don't send via socket here - the server will broadcast it
      // This prevents duplicate progress updates

      // If we're in messages loaded state, preserve it
      if (currentState is ReadingGroupMessagesLoaded) {
        emit(currentState);
      } else {
        emit(ReadingGroupProgressUpdated(
          group: group,
          currentPage: event.currentPage,
        ));
      }
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));

      // Return to previous state
      if (currentState is ReadingGroupMessagesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onLoadMessages(
    ReadingGroupLoadMessages event,
    Emitter<ReadingGroupState> emit,
  ) async {
    if (event.page == 1) {
      emit(ReadingGroupMessagesLoading());
    } else {
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

      // Add message IDs to processed set
      for (var message in messages) {
        if (message.id != null) {
          _processedMessageIds.add(message.id!);
        }
      }

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
    // Prevent duplicate sends
    if (_isSendingMessage) {
      debugPrint(
          'ReadingGroupBloc: Already sending message, ignoring duplicate');
      return;
    }

    _isSendingMessage = true;
    final currentState = state;

    try {
      // Send message via API ONLY (the server will broadcast via socket)
      final message = await readingGroupRepository.sendGroupMessage(
        groupId: event.groupId,
        text: event.text,
      );

      if (message.id != null) {
        _processedMessageIds.add(message.id!);
      }

      if (currentState is ReadingGroupMessagesLoaded) {
        // Keep the current state, the message will be added when received via socket
        emit(currentState);
      }
    } catch (e) {
      emit(ReadingGroupMessageError(message: e.toString()));

      if (currentState is ReadingGroupState) {
        emit(currentState);
      }
    } finally {
      _isSendingMessage = false;
    }
  }

  void _onReceiveMessage(
    ReadingGroupReceiveMessage event,
    Emitter<ReadingGroupState> emit,
  ) {
    final currentState = state;

    if (currentState is ReadingGroupMessagesLoaded &&
        event.message.groupId == currentState.groupId) {
      // Create a unique identifier for the message
      final messageId = event.message.id ??
          '${event.message.userId}_${event.message.text.hashCode}_${event.message.createdAt.millisecondsSinceEpoch}';

      // Add to processed set
      _processedMessageIds.add(messageId);

      // Add message to the list
      final updatedMessages = [
        ...currentState.messages,
        event.message,
      ];

      // Sort messages by creation date to ensure correct order
      updatedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // emit(currentState.copyWith(
      //     messages: updatedMessages, hasMoreMessages: true));
      add(ReadingGroupLoadMessages(groupId: currentState.groupId, page: 1));
    }
  }

  void _onReceiveProgressUpdate(
    ReadingGroupReceiveProgressUpdate event,
    Emitter<ReadingGroupState> emit,
  ) {
    final currentState = state;

    // Handle progress update for both ReadingGroupLoaded and ReadingGroupMessagesLoaded states
    if (currentState is ReadingGroupLoaded ||
        currentState is ReadingGroupMessagesLoaded) {
      final String userId = event.data['userId'];
      final int currentPage = event.data['currentPage'];
      final String groupId = event.data['groupId'];

      if (groupId == _currentGroupId) {
        // If we're in messages loaded state, just emit the current state
        // The UI will update based on the progress message
        if (currentState is ReadingGroupMessagesLoaded) {
          emit(currentState);
        }
      }
    }
  }

  void _onKicked(
    ReadingGroupKicked event,
    Emitter<ReadingGroupState> emit,
  ) {
    final currentState = state;

    emit(ReadingGroupKickedFromGroup(groupId: event.groupId));

    if (_currentGroupId == event.groupId) {
      _currentGroupId = null;
      add(ReadingGroupLoadUserGroups());
    } else if (currentState is ReadingGroupState) {
      emit(currentState);
    }
  }
}
