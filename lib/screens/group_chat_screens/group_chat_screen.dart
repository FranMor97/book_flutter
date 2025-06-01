// lib/screens/reading_groups/group_chat_screen.dart
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/models/comments_group.dart'; // Assuming GroupMessage is here
import 'package:book_app_f/models/reading_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting

class GroupChatScreen extends StatefulWidget {
  final ReadingGroup group;

  const GroupChatScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ReadingGroupBloc _readingGroupBloc;

  @override
  void initState() {
    super.initState();
    _readingGroupBloc = context.read<ReadingGroupBloc>();
    _readingGroupBloc.add(ReadingGroupLoadMessages(groupId: widget.group.id));
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
    // Potentially pre-fill with current progress if available and makes sense
    // final currentMember = widget.group.members.firstWhere((m) => m.userId == /* currentUserId */, orElse: () => null);
    // if (currentMember != null) progressController.text = currentMember.currentPage.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Actualizar Progreso',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: progressController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Página Actual',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8B5CF6))),
          ),
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
                _readingGroupBloc.add(ReadingGroupUpdateProgress(
                    groupId: widget.group.id, currentPage: page));
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Por favor, introduce un número de página válido.'),
                      backgroundColor: Colors.red),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

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
                // Show confirmation dialog before leaving
                showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A2E),
                          title: const Text('Abandonar Grupo',
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              '¿Estás seguro de que quieres abandonar este grupo?',
                              style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancelar',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _readingGroupBloc.add(ReadingGroupLeave(
                                  groupId: widget.group.id,
                                ));
                                Navigator.pop(dialogContext); // Close dialog
                                Navigator.pop(context); // Close chat screen
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent),
                              child: const Text('Abandonar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ));
              }
              // Add more actions: view members, edit group (if admin)
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update_progress',
                child: Text('Actualizar Progreso',
                    style: TextStyle(color: Colors.white)),
              ),
              // TODO: Add View Members, Edit Group (conditional on admin status)
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
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                } else if (state is ReadingGroupError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red),
                  );
                } else if (state is ReadingGroupOperationSuccess &&
                    ModalRoute.of(context)?.isCurrent != true) {
                  // Potentially a success message after an operation like updating progress
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Operación completada'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              builder: (context, state) {
                if (state is ReadingGroupLoading &&
                    state is! ReadingGroupMessagesLoaded) {
                  // Avoid full screen loader if messages are already loaded
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF8B5CF6)));
                }

                List<GroupMessage> messages = [];
                if (state is ReadingGroupMessagesLoaded) {
                  messages = state.messages;
                } else if (state is ReadingGroupSingleLoaded &&
                    state.group.id == widget.group.id) {
                  // If messages are part of the group model or another mechanism updates them
                  // This part depends on how you manage message state updates
                }

                if (messages.isEmpty && state is! ReadingGroupLoading) {
                  return const Center(
                    child: Text(
                      'No hay mensajes aún. ¡Sé el primero!',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // final bool isMe = message.userId == /* currentUserId */ ; // Determine if the message is from the current user
                    // For now, let's assume a placeholder for isMe or style all messages similarly
                    // You'll need to get the current user's ID, e.g., from AuthRepository
                    // final currentUserId = getIt<IAuthRepository>().getCurrentUserId(); // This might be async
                    // For simplicity, not implementing isMe differentiation fully here.

                    return _buildMessageBubble(
                        message, false /* isMe placeholder */);
                  },
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
              message.user?.firstName ??
                  'Usuario', // Assuming user info is part of GroupMessage
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
                fillColor: const Color(0xFF0A0A0F), // Darker input field
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
