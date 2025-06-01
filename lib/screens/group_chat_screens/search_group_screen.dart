// lib/screens/reading_groups/search_groups_screen.dart
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';

// Placeholder for GroupChatScreen - replace with actual import
// import 'group_chat_screen.dart';

class SearchGroupsScreen extends StatefulWidget {
  const SearchGroupsScreen({Key? key}) : super(key: key);

  @override
  State<SearchGroupsScreen> createState() => _SearchGroupsScreenState();
}

class _SearchGroupsScreenState extends State<SearchGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ReadingGroupBloc? _readingGroupBloc;

  @override
  void initState() {
    super.initState();
    _readingGroupBloc =
        BlocProvider.of<ReadingGroupBloc>(context, listen: false);
    // Optionally, load initial public groups or wait for search
    // _readingGroupBloc.add(ReadingGroupSearchPublicGroups(query: ''));
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      _readingGroupBloc?.add(ReadingGroupSearchPublicGroups(query: query));
    } else {
      // Optionally, clear results or load default list
      _readingGroupBloc?.add(ReadingGroupSearchPublicGroups(
          query: '')); // Example: load all public if query is empty
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
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
              builder: (context, state) {
                if (state is ReadingGroupLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  );
                }

                if (state is ReadingGroupPublicGroupsLoaded) {
                  if (state.groups.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron grupos públicos o la búsqueda está vacía.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
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
                              _readingGroupBloc?.add(
                                  ReadingGroupSearchPublicGroups(
                                      query: _searchController.text));
                            }
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Introduce un término de búsqueda para encontrar grupos.',
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
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
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
            child: Row(
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
                      const SizedBox(height: 8),
                      Text(
                        book?.title ?? 'Libro sin título',
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.members.length} miembros',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                  onPressed: () {
                    // Assuming ReadingGroupBloc has a ReadingGroupJoin event
                    context.read<ReadingGroupBloc>().add(ReadingGroupJoin(
                          groupId: group.id,
                        ));
                    // Optionally, navigate or show confirmation
                  },
                  child: const Text('Unirse',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
