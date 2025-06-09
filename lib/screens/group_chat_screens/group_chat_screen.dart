// lib/screens/group_chat_screens/group_chat_screen.dart
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:book_app_f/screens/group_chat_screens/group_member_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final ReadingGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ReadingGroupBloc _readingGroupBloc;
  String? _currentUserId;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _currentPage = 1;
  static const int _messagesPerPage = 20;
  List<GroupMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _readingGroupBloc = context.read<ReadingGroupBloc>();
    _loadCurrentUser();
    _loadInitialMessages();
    _setupScrollListener();
    _connectToSocket();
  }

  Future<void> _loadCurrentUser() async {
    final authRepository = getIt<IAuthRepository>();
    _currentUserId = await authRepository.getCurrentUserId();
    setState(() {});
  }

  void _loadInitialMessages() {
    _readingGroupBloc.add(ReadingGroupLoadMessages(
      groupId: widget.group.id,
      page: 1,
      limit: _messagesPerPage,
    ));
  }

  void _connectToSocket() {
    final socketService = context.read<SocketService>();

    // Unirse al grupo
    socketService.joinGroupChat(widget.group.id);

    // Escuchar nuevos mensajes
    socketService.on('group-message:new', (data) {
      if (mounted) {
        final message = GroupMessage.fromJson(data);
        setState(() {
          _messages.insert(0, message);
        });
        _scrollToBottom();
      }
    });

    // Escuchar actualizaciones de progreso
    socketService.on('reading-progress:updated', (data) {
      if (mounted && data['groupId'] == widget.group.id) {
        // Actualizar el estado del grupo si es necesario
        _readingGroupBloc.add(ReadingGroupLoadById(groupId: widget.group.id));
      }
    });
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

  void _loadMoreMessages() {
    setState(() {
      _isLoadingMore = true;
    });

    _readingGroupBloc.add(ReadingGroupLoadMessages(
      groupId: widget.group.id,
      page: _currentPage + 1,
      limit: _messagesPerPage,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    // Desconectar del socket
    final socketService = context.read<SocketService>();
    socketService.off('group-message:new');
    socketService.off('reading-progress:updated');

    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final text = _messageController.text.trim();
      _messageController.clear();

      // Enviar a través del bloc (HTTP)
      _readingGroupBloc.add(
        ReadingGroupSendMessage(
          groupId: widget.group.id,
          text: text,
        ),
      );

      // También enviar por socket para actualización en tiempo real
      final socketService = context.read<SocketService>();
      socketService.sendGroupMessage(widget.group.id, text);
    }
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

  void _showUpdateProgressDialog() {
    final progressController = TextEditingController();
    final currentMember = widget.group.getMember(_currentUserId ?? '');

    if (currentMember == null) return;

    progressController.text = currentMember.currentPage.toString();
    final book = widget.group.book;
    final int maxPages = book?.pageCount ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Actualizar Progreso',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: progressController,
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
            const SizedBox(height: 16),
            // Barra de progreso visual
            if (maxPages > 0) ...[
              LinearProgressIndicator(
                value: currentMember.currentPage / maxPages,
                backgroundColor: Colors.grey[800],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 8),
              Text(
                '${(currentMember.currentPage / maxPages * 100).round()}% completado',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(progressController.text);
              if (page != null &&
                  page >= 0 &&
                  (maxPages == 0 || page <= maxPages)) {
                Navigator.pop(context);

                // Actualizar progreso
                _readingGroupBloc.add(
                  ReadingGroupUpdateProgress(
                    groupId: widget.group.id,
                    currentPage: page,
                  ),
                );

                // También actualizar por socket
                final socketService = context.read<SocketService>();
                socketService.updateReadingProgress(widget.group.id, page);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(maxPages > 0
                        ? 'Por favor, introduce un número entre 0 y $maxPages'
                        : 'Por favor, introduce un número válido'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Abandonar Grupo',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            '¿Estás seguro de que quieres abandonar este grupo? Esta acción no se puede deshacer.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _readingGroupBloc.add(ReadingGroupLeave(
                groupId: widget.group.id,
              ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Abandonar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToMembersScreen() {
    if (_currentUserId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupMembersList(
          group: widget.group,
          currentUserId: _currentUserId!,
          isAdmin: widget.group.isAdmin(_currentUserId!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(
              '${widget.group.members.length} miembros',
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
          // Mostrar progreso del usuario actual
          if (_currentUserId != null) _buildProgressIndicator(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A1A2E),
            onSelected: (value) {
              switch (value) {
                case 'update_progress':
                  _showUpdateProgressDialog();
                  break;
                case 'view_members':
                  _navigateToMembersScreen();
                  break;
                case 'view_book':
                  if (widget.group.book?.id != null) {
                    Navigator.pushNamed(
                      context,
                      'book-detail',
                      arguments: widget.group.book!.id,
                    );
                  }
                  break;
                case 'leave_group':
                  _showLeaveGroupConfirmation();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso del grupo
          _buildGroupProgressBar(),

          // Mensajes del chat
          Expanded(
            child: BlocConsumer<ReadingGroupBloc, ReadingGroupState>(
              listener: (context, state) {
                if (state is ReadingGroupMessagesLoaded) {
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
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());
                  }
                } else if (state is ReadingGroupError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _isLoadingMore = false;
                  });
                } else if (state is ReadingGroupProgressUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progreso actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ReadingGroupMessagesLoading && _messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  );
                }

                if (_messages.isEmpty &&
                    state is! ReadingGroupMessagesLoading) {
                  return const Center(
                    child: Text(
                      'No hay mensajes aún. ¡Sé el primero!',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

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
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final currentMember = widget.group.getMember(_currentUserId!);
    if (currentMember == null) return const SizedBox.shrink();

    final book = widget.group.book;
    final progress = book?.pageCount != null && book!.pageCount! > 0
        ? currentMember.currentPage / book.pageCount!
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: _showUpdateProgressDialog,
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

  Widget _buildGroupProgressBar() {
    final book = widget.group.book;
    if (book?.pageCount == null || book!.pageCount! <= 0) {
      return const SizedBox.shrink();
    }

    // Calcular progreso promedio del grupo
    int totalPages = 0;
    for (var member in widget.group.members) {
      totalPages += member.currentPage;
    }
    final averageProgress =
        totalPages / (widget.group.members.length * book.pageCount!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso del grupo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(averageProgress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
