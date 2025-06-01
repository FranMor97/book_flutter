// lib/data/bloc/reading_group/reading_group_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'reading_group_event.dart';
part 'reading_group_state.dart';

class ReadingGroupBloc extends Bloc<ReadingGroupEvent, ReadingGroupState> {
  final IReadingGroupRepository readingGroupRepository;

  ReadingGroupBloc({required this.readingGroupRepository})
      : super(ReadingGroupInitial()) {
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
  }

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
      final group = await readingGroupRepository.getGroupById(event.groupId);
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
      emit(ReadingGroupJoined(group: group));
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

      // Recargar grupos del usuario
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
      final group = await readingGroupRepository.updateReadingProgress(
        groupId: event.groupId,
        currentPage: event.currentPage,
      );

      emit(ReadingGroupProgressUpdated(
        group: group,
        currentPage: event.currentPage,
      ));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    ReadingGroupLoadMessages event,
    Emitter<ReadingGroupState> emit,
  ) async {
    emit(ReadingGroupMessagesLoading());

    try {
      final messages = await readingGroupRepository.getGroupMessages(
        groupId: event.groupId,
        page: event.page,
        limit: event.limit,
      );

      emit(ReadingGroupMessagesLoaded(
        groupId: event.groupId,
        messages: messages,
        page: event.page,
        isFirstLoad: event.page == 1,
      ));
    } catch (e) {
      emit(ReadingGroupError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    ReadingGroupSendMessage event,
    Emitter<ReadingGroupState> emit,
  ) async {
    final currentState = state;

    try {
      final message = await readingGroupRepository.sendGroupMessage(
        groupId: event.groupId,
        text: event.text,
      );

      if (currentState is ReadingGroupMessagesLoaded) {
        // Actualizar la lista de mensajes
        final updatedMessages = [message, ...currentState.messages];

        emit(ReadingGroupMessagesLoaded(
          groupId: currentState.groupId,
          messages: updatedMessages,
          page: currentState.page,
          isFirstLoad: false,
        ));
      }

      emit(ReadingGroupMessageSent(message: message));

      if (currentState is ReadingGroupMessagesLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(ReadingGroupMessageError(message: e.toString()));

      if (currentState is ReadingGroupState) {
        emit(currentState);
      }
    }
  }
}
