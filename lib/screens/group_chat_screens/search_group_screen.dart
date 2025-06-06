// lib/screens/group_chat_screens/search_group_screen.dart
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:book_app_f/screens/group_chat_screens/group_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchGroupsScreen extends StatefulWidget {
  const SearchGroupsScreen({Key? key}) : super(key: key);

  @override
  State<SearchGroupsScreen> createState() => _SearchGroupsScreenState();
}

class _SearchGroupsScreenState extends State<SearchGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ReadingGroupBloc? _readingGroupBloc;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _groupsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _readingGroupBloc = context.read<ReadingGroupBloc>();

    // Load initial public groups with empty query
    _readingGroupBloc?.add(const ReadingGroupSearchPublic(
        query: '', page: 1, limit: _groupsPerPage));

    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final currentState = _readingGroupBloc?.state;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          currentState is ReadingGroupPublicSearchResults &&
          currentState.hasMorePages) {
        _loadMoreGroups();
      }
    });
  }

  void _loadMoreGroups() {
    setState(() {
      _isLoadingMore = true;
    });

    final currentState = _readingGroupBloc?.state;
    if (currentState is ReadingGroupPublicSearchResults) {
      _readingGroupBloc?.add(ReadingGroupSearchPublic(
          query: currentState.query,
          page: _currentPage + 1,
          limit: _groupsPerPage));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel any in-progress search when typing new characters
    // We could implement debounce here for better UX

    if (query.isNotEmpty) {
      _readingGroupBloc?.add(ReadingGroupSearchPublic(
          query: query, page: 1, limit: _groupsPerPage));
    } else {
      // Load all public groups if query is empty
      _readingGroupBloc?.add(const ReadingGroupSearchPublic(
          query: '', page: 1, limit: _groupsPerPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Buscar Grupos Públicos',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o tema...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocConsumer<ReadingGroupBloc, ReadingGroupState>(
              listener: (context, state) {
                if (state is ReadingGroupPublicSearchResults) {
                  setState(() {
                    _currentPage = state.page;
                    _isLoadingMore = false;
                  });
                } else if (state is ReadingGroupJoined) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Te has unido al grupo exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to the group chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatScreen(
                        group: state.group,
                      ),
                    ),
                  );
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
                }
              },
              builder: (context, state) {
                if (state is ReadingGroupLoading ||
                    state is ReadingGroupSearching) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  );
                }

                if (state is ReadingGroupPublicSearchResults) {
                  if (state.groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 60,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No hay grupos públicos disponibles'
                                : 'No se encontraron grupos para "${_searchController.text}"',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to create group screen
                              // This would be implemented depending on your navigation setup
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear grupo'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildSearchResultsList(context, state.groups);
                }

                if (state is ReadingGroupError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              _readingGroupBloc?.add(ReadingGroupSearchPublic(
                                  query: _searchController.text,
                                  page: 1,
                                  limit: _groupsPerPage));
                            } else {
                              _readingGroupBloc?.add(
                                  const ReadingGroupSearchPublic(
                                      query: '',
                                      page: 1,
                                      limit: _groupsPerPage));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                // Default state
                return const Center(
                  child: Text(
                    'Busca grupos por nombre, libro o tema',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(
      BuildContext context, List<ReadingGroup> groups) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: groups.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom when loading more
        if (_isLoadingMore && index == groups.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          );
        }

        final group = groups[index];
        final book = group.book;

        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Name and Member Count
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  color: Colors.grey, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${group.members.length} miembros',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Private/Public indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: group.isPrivate
                            ? Colors.red.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        group.isPrivate ? 'Privado' : 'Público',
                        style: TextStyle(
                          color: group.isPrivate ? Colors.red : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Book information if available
                if (book != null) ...[
                  Text(
                    'Libro: ${book.title}',
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 14,
                    ),
                  ),
                  if (book.authors.isNotEmpty)
                    Text(
                      'Autor: ${book.authors.first}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],

                // Description if available
                if (group.description != null &&
                    group.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    group.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // Join button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View details button
                    OutlinedButton(
                      onPressed: () {
                        _showGroupDetailsDialog(context, group);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Ver detalles'),
                    ),
                    const SizedBox(width: 8),

                    // Join button
                    // lib/screens/group_chat_screens/search_group_screen.dart (continued)
                    // Join button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                      onPressed: () {
                        // Check if the group is private before joining
                        if (group.isPrivate) {
                          _showPrivateGroupDialog(context);
                        } else {
                          // Join the public group
                          context.read<ReadingGroupBloc>().add(
                                ReadingGroupJoin(groupId: group.id),
                              );
                        }
                      },
                      child: const Text('Unirse',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGroupDetailsDialog(BuildContext context, ReadingGroup group) {
    final book = group.book;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name and privacy indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: group.isPrivate
                          ? Colors.red.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      group.isPrivate ? 'Privado' : 'Público',
                      style: TextStyle(
                        color: group.isPrivate ? Colors.red : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Creator info
              if (group.creator != null) ...[
                const Text(
                  'Creado por:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.creator!.firstName} ${group.creator!.lastName1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Description
              if (group.description != null &&
                  group.description!.isNotEmpty) ...[
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Book information
              if (book != null) ...[
                const Text(
                  'Libro:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Book cover if available
                    if (book.coverImage != null && book.coverImage!.isNotEmpty)
                      Container(
                        width: 60,
                        height: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(book.coverImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // Book info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (book.authors.isNotEmpty)
                            Text(
                              book.authors.first,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          if (book.pageCount != null)
                            Text(
                              '${book.pageCount} páginas',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Reading goal if available
              if (group.readingGoal != null) ...[
                const Text(
                  'Objetivo de lectura:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (group.readingGoal!.pagesPerDay != null)
                  Text(
                    '${group.readingGoal!.pagesPerDay} páginas por día',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                if (group.readingGoal!.targetFinishDate != null)
                  Text(
                    'Fecha objetivo: ${_formatDate(group.readingGoal!.targetFinishDate!)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Members count
              Text(
                'Miembros: ${group.members.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      // Check if the group is private before joining
                      if (group.isPrivate) {
                        _showPrivateGroupDialog(context);
                      } else {
                        // Join the public group
                        context.read<ReadingGroupBloc>().add(
                              ReadingGroupJoin(groupId: group.id),
                            );
                      }
                    },
                    child: const Text('Unirse al grupo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Grupo Privado',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Este es un grupo privado. Solo se puede acceder por invitación del administrador.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(color: Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
