// lib/screens/group_chat_screens/group_chat_screen.dart
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:book_app_f/data/services/reading_group_socket_service.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:book_app_f/screens/group_chat_screens/group_member_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _progressController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late ReadingGroupBloc _readingGroupBloc;
  String? _currentUserId;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  late ReadingGroupSocketService _groupSocketService;
  int _currentPage = 1;
  static const int _messagesPerPage = 20;
  List<GroupMessage> _messages = [];
  ReadingGroup? _currentGroup;
  bool _showProgressDialog = false;
  bool _showLeaveDialog = false;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _loadCurrentUser();
    _setupScrollListener();
  }

  void _initializeComponents() {
    _readingGroupBloc = context.read<ReadingGroupBloc>();
    final socketService = context.read<SocketService>();
    _groupSocketService = ReadingGroupSocketService(
      socketService: socketService,
      onNewMessage: _handleNewMessage,
      onProgressUpdated: _handleProgressUpdate,
    );
  }

  void _handleNewMessage(GroupMessage message) {
    if (mounted) {
      setState(() {
        _messages.insert(0, message);
      });
      _scrollToBottom();
    }
  }

  void _handleProgressUpdate(Map<String, dynamic> data) {
    if (mounted && data['groupId'] == widget.groupId) {
      _readingGroupBloc.add(ReadingGroupLoadById(groupId: widget.groupId));
    }
  }

  Future<void> _loadCurrentUser() async {
    final authRepository = getIt<IAuthRepository>();
    _currentUserId = await authRepository.getCurrentUserId();
    if (mounted) setState(() {});
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMoreMessages) {
        _loadMoreMessages();
      }
    });
  }

  void _connectToSocket() {
    if (_currentGroup != null) {
      _groupSocketService.joinGroupChat(_currentGroup!.id);
    }
  }

  void _loadInitialMessages() {
    if (_currentGroup != null) {
      _readingGroupBloc.add(ReadingGroupLoadMessages(
        groupId: _currentGroup!.id,
        page: 1,
        limit: _messagesPerPage,
      ));
    }
  }

  void _loadMoreMessages() {
    if (_currentGroup == null) return;

    setState(() => _isLoadingMore = true);
    _readingGroupBloc.add(ReadingGroupLoadMessages(
      groupId: _currentGroup!.id,
      page: _currentPage + 1,
      limit: _messagesPerPage,
    ));
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _currentGroup == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    _readingGroupBloc.add(ReadingGroupSendMessage(
      groupId: _currentGroup!.id,
      text: text,
    ));

    _groupSocketService.sendGroupMessage(_currentGroup!.id, text);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _updateProgress() {
    if (_currentGroup == null || _currentUserId == null) return;

    final currentMember = _currentGroup!.getMember(_currentUserId!);
    if (currentMember == null) return;

    final page = int.tryParse(_progressController.text);
    final maxPages = _currentGroup!.book?.pageCount ?? 0;

    if (page != null && page >= 0 && (maxPages == 0 || page <= maxPages)) {
      setState(() => _showProgressDialog = false);

      _readingGroupBloc.add(ReadingGroupUpdateProgress(
        groupId: _currentGroup!.id,
        currentPage: page,
      ));

      _groupSocketService.updateReadingProgress(_currentGroup!.id, page);
    } else {
      _showSnackBar(
        maxPages > 0
            ? 'Por favor, introduce un número entre 0 y $maxPages'
            : 'Por favor, introduce un número válido',
        isError: true,
      );
    }
  }

  void _leaveGroup() {
    if (_currentGroup == null) return;

    setState(() => _showLeaveDialog = false);
    _readingGroupBloc.add(ReadingGroupLeave(groupId: _currentGroup!.id));
    Navigator.pop(context);
  }

  void _navigateToMembersScreen() {
    if (_currentUserId == null || _currentGroup == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupMembersList(
          group: _currentGroup!,
          currentUserId: _currentUserId!,
          isAdmin: _currentGroup!.isAdmin(_currentUserId!),
        ),
      ),
    );
  }

  void _navigateToBookDetail() {
    if (_currentGroup?.book?.id != null) {
      context.pushNamed(
        'book-detail',
        pathParameters: {'id': _currentGroup!.book!.id!},
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _progressController.dispose();
    _scrollController.dispose();
    _groupSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReadingGroupBloc, ReadingGroupState>(
      listener: _handleBlocState,
      builder: (context, state) {
        if (_showProgressDialog) {
          return _buildProgressDialogScreen();
        }

        if (_showLeaveDialog) {
          return _buildLeaveDialogScreen();
        }

        if (state is ReadingGroupLoading ||
            (_currentGroup == null && state is! ReadingGroupError)) {
          return _buildLoadingScreen();
        }

        if (state is ReadingGroupError && _currentGroup == null) {
          return _buildErrorScreen(state.message);
        }

        if (_currentGroup != null) {
          return _buildChatScreen();
        }

        return _buildLoadingScreen();
      },
    );
  }

  void _handleBlocState(BuildContext context, ReadingGroupState state) {
    if (state is ReadingGroupLoaded) {
      _currentGroup = state.group;
      _connectToSocket();
      _loadInitialMessages();
    } else if (state is ReadingGroupMessagesLoaded) {
      setState(() {
        if (state.page == 1) {
          _messages = state.messages;
        } else {
          _messages.addAll(state.messages);
        }
        _currentPage = state.page;
        _hasMoreMessages = state.hasMoreMessages;
        _isLoadingMore = false;
      });

      if (state.isFirstLoad) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } else if (state is ReadingGroupError) {
      _showSnackBar('Error: ${state.message}', isError: true);
      setState(() => _isLoadingMore = false);
    } else if (state is ReadingGroupProgressUpdated) {
      _showSnackBar('Progreso actualizado correctamente');
    }
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0F),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error: $message',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _readingGroupBloc
                    .add(ReadingGroupLoadById(groupId: widget.groupId));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6)),
              child: const Text('Reintentar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDialogScreen() {
    final currentMember = _currentGroup!.getMember(_currentUserId!);
    final maxPages = _currentGroup!.book?.pageCount ?? 0;

    if (_progressController.text.isEmpty) {
      _progressController.text = currentMember?.currentPage.toString() ?? '0';
    }

    final progress = maxPages > 0 && currentMember != null
        ? currentMember.currentPage / maxPages
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Actualizar Progreso',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _showProgressDialog = false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _progressController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Página Actual',
                labelStyle: const TextStyle(color: Colors.grey),
                helperText: maxPages > 0 ? 'Máximo: $maxPages páginas' : null,
                helperStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (maxPages > 0) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[800],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Text(
                '${(progress * 100).round()}% completado',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _showProgressDialog = false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Guardar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDialogScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Abandonar Grupo',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _showLeaveDialog = false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 64),
            const SizedBox(height: 24),
            const Text(
              '¿Estás seguro de que quieres abandonar este grupo?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta acción no se puede deshacer y perderás acceso a todos los mensajes y progreso del grupo.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showLeaveDialog = false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _leaveGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Abandonar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildGroupProgressBar(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentGroup!.name,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(
            '${_currentGroup!.members.length} miembros',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_currentUserId != null) _buildProgressIndicator(),
        _buildPopupMenu(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final currentMember = _currentGroup!.getMember(_currentUserId!);

    if (currentMember == null) return const SizedBox.shrink();

    final book = _currentGroup!.book;
    final progress = book?.pageCount != null && book!.pageCount! > 0
        ? currentMember.currentPage / book.pageCount!
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _showProgressDialog = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: const Color(0xFF1A1A2E),
      onSelected: (value) {
        switch (value) {
          case 'update_progress':
            setState(() => _showProgressDialog = true);
            break;
          case 'view_members':
            _navigateToMembersScreen();
            break;
          case 'view_book':
            _navigateToBookDetail();
            break;
          case 'leave_group':
            setState(() => _showLeaveDialog = true);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'update_progress',
          child: Row(
            children: [
              Icon(Icons.menu_book, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text('Actualizar Progreso',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'view_members',
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.white),
              SizedBox(width: 8),
              Text('Ver Miembros', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'view_book',
          child: Row(
            children: [
              Icon(Icons.book, color: Colors.white),
              SizedBox(width: 8),
              Text('Ver Libro', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'leave_group',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Abandonar Grupo',
                  style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupProgressBar() {
    final book = _currentGroup!.book;
    if (book?.pageCount == null || book!.pageCount! <= 0) {
      return const SizedBox.shrink();
    }

    int totalPages = 0;
    for (var member in _currentGroup!.members) {
      totalPages += member.currentPage;
    }
    final averageProgress =
        totalPages / (_currentGroup!.members.length * book.pageCount!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso del grupo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${(averageProgress * 100).round()}%',
                style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: averageProgress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No hay mensajes aún. ¡Sé el primero!',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
      builder: (context, state) {
        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
              reverse: true,
              itemBuilder: (context, index) {
                if (_isLoadingMore && index == 0) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  );
                }

                final messageIndex = _isLoadingMore ? index - 1 : index;
                final message = _messages[messageIndex];
                final isMe = message.userId == _currentUserId;

                return _buildMessageBubble(message, isMe);
              },
            ),
            if (state is ReadingGroupActionInProgress)
              Positioned(
                bottom: 70,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(GroupMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: _getMessageColor(message.type, isMe),
          borderRadius: BorderRadius.circular(12.0),
          border: !isMe && message.type == MessageType.text
              ? Border.all(color: Colors.grey[700]!)
              : null,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.user?.firstName ?? 'Usuario',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getUserNameColor(message.type),
                  fontSize: 12,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                color: isMe || message.type != MessageType.text
                    ? Colors.white
                    : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedMessageTime(message.createdAt),
              style: TextStyle(
                color: isMe || message.type != MessageType.text
                    ? Colors.white70
                    : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMessageColor(MessageType type, bool isMe) {
    if (isMe && type == MessageType.text) {
      return const Color(0xFF8B5CF6);
    }

    switch (type) {
      case MessageType.system:
        return Colors.grey[800]!;
      case MessageType.progress:
        return const Color(0xFFEC4899).withOpacity(0.8);
      case MessageType.text:
      default:
        return const Color(0xFF1A1A2E);
    }
  }

  Color _getUserNameColor(MessageType type) {
    switch (type) {
      case MessageType.system:
        return Colors.grey[400]!;
      case MessageType.progress:
        return Colors.pink[300]!;
      case MessageType.text:
      default:
        return Colors.purple[300]!;
    }
  }

  String _getFormattedMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(messageTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
    } else {
      return 'ahora';
    }
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF0A0A0F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF8B5CF6)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
