import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _currentPage = 1;
  static const int _messagesPerPage = 20;

  // Additional methods to complete the GroupChatScreen

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

              // Give some time for the operation to complete before popping
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.pop(context); // Return to the previous screen
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Abandonar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// Add this function to the GroupChatScreen class to get user-friendly message times
  String _getFormattedMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 7) {
      // Format as date if older than a week
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    } else if (difference.inDays > 0) {
      // Format as days ago if within a week
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'} atrás';
    } else if (difference.inHours > 0) {
      // Format as hours ago
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else if (difference.inMinutes > 0) {
      // Format as minutes ago
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
    } else {
      // Just now
      return 'ahora';
    }
  }

  @override
  void initState() {
    super.initState();
    _readingGroupBloc = context.read<ReadingGroupBloc>();
    _readingGroupBloc.add(ReadingGroupLoadMessages(
        groupId: widget.group.id, page: 1, limit: _messagesPerPage));

    _setupScrollListener();
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
        limit: _messagesPerPage));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _readingGroupBloc.add(
        ReadingGroupSendMessage(
          groupId: widget.group.id,
          text: _messageController.text.trim(),
        ),
      );
      _messageController.clear();
      // Scroll to bottom after sending, might need a slight delay for UI update
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showUpdateProgressDialog() {
    final progressController = TextEditingController();
    // Find current user in the group members
    final currentMember = widget.group.members.firstWhere(
      (m) => m.userId == 'currentUserId', // Replace with actual current user ID
      orElse: () => widget.group.members.first,
    );

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
              if (page != null && page >= 0) {
                Navigator.pop(context);
                _readingGroupBloc.add(
                  ReadingGroupUpdateProgress(
                    groupId: widget.group.id,
                    currentPage: page,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Por favor, introduce un número de página válido.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(widget.group.name,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A1A2E),
            onSelected: (value) {
              if (value == 'update_progress') {
                _showUpdateProgressDialog();
              } else if (value == 'leave_group') {
                _showLeaveGroupConfirmation();
              } else if (value == 'view_members') {
                _navigateToMembersScreen();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update_progress',
                child: Text('Actualizar Progreso',
                    style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'view_members',
                child:
                    Text('Ver Miembros', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'leave_group',
                child: Text('Abandonar Grupo',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ReadingGroupBloc, ReadingGroupState>(
              listener: (context, state) {
                if (state is ReadingGroupMessagesLoaded) {
                  setState(() {
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
                if (state is ReadingGroupMessagesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  );
                }

                List<GroupMessage> messages = [];
                if (state is ReadingGroupMessagesLoaded) {
                  messages = state.messages;
                }

                if (messages.isEmpty && state is! ReadingGroupMessagesLoading) {
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
                      itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                      reverse: true, // Show newest messages at the bottom
                      itemBuilder: (context, index) {
                        // Show loading indicator at the top when loading more
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

                        // Adjust index for the actual messages
                        final messageIndex = _isLoadingMore ? index - 1 : index;
                        final message = messages[messageIndex];

                        // Determine if the message is from the current user
                        final bool isMe = message.userId ==
                            'currentUserId'; // Replace with actual user ID

                        return _buildMessageBubble(message, isMe);
                      },
                    ),

                    // Show a loading indicator when sending a message
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

  Widget _buildMessageBubble(GroupMessage message, bool isMe) {
    final dateFormat = DateFormat('dd/MM/yy HH:mm');
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
            color: isMe ? const Color(0xFF8B5CF6) : const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12.0),
            border: isMe ? null : Border.all(color: Colors.grey[700]!)),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.user?.firstName ?? 'Usuario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.purple[300],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          border: Border(top: BorderSide(color: Colors.grey[800]!))),
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

  void _navigateToMembersScreen() {
    // Navigate to members screen
    // This would be implemented depending on your navigation setup
    // For example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => GroupMembersList(
    //       group: widget.group,
    //       currentUserId: 'currentUserId', // Replace with actual ID
    //       isAdmin: widget.group.isAdmin('currentUserId'), // Check if user is admin
    //     ),
    //   ),
    // );
  }
}
