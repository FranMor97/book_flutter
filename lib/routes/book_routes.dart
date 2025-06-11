// lib/routes/book_routes.dart
import 'package:book_app_f/data/bloc/book_detail/book_detail_bloc.dart';
import 'package:book_app_f/data/bloc/book_library/book_library_bloc.dart';
import 'package:book_app_f/data/bloc/friendship/friendship_bloc.dart';
import 'package:book_app_f/data/bloc/home/home_bloc.dart';
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/bloc/user_library/user_library_bloc.dart'; // Importar el nuevo bloc
import 'package:book_app_f/data/bloc/user_profile/user_profile_bloc.dart';
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/screens/bibliotheque/user_library_screen.dart';
import 'package:book_app_f/screens/book_comments_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/create_group_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/group_chat_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/reading_groups_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/search_group_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/select_book_screen.dart';
import 'package:book_app_f/screens/login/views/login_screen.dart';
import 'package:book_app_f/screens/login/views/register_screen.dart';
import 'package:book_app_f/screens/splash_screen.dart';
import 'package:book_app_f/screens/home_screen/home_screen.dart';
import 'package:book_app_f/screens/user_screens/friends_screens.dart';
import 'package:book_app_f/screens/user_screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/bloc/login/login_bloc.dart';
import '../data/bloc/register_bloc/register_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/book_user_repository.dart';
import '../injection.dart';
import '../screens/search_books/book_detail.dart';
import '../screens/search_books/explore_screen.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() => _instance;

  AppRouter._internal();

  GoRouter get router => _router;

  // Definición de nombres de rutas
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String explore = 'explore';
  static const String bookDetail = 'book-detail';
  static const String userLibrary = 'user-library'; // Nueva ruta
  static const String main = 'main';
  static const String bookComments = 'book-comments';
  static const String userProfile = 'user-profile';
  static const String readingGroups = 'reading-groups';
  static const String searchGroups = 'search-groups';
  static const String groupChat = 'group-chat';
  static const String friendScreen = 'friend-screen';
  static const String createGroupScreen = 'create-group';
  static const String selectBookScreen = 'select-book-screen';

  // Definición de las rutas
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String explorePath = '/explore';
  static const String bookDetailPath = '/book/:id';
  static const String userLibraryPath = '/library'; // Nueva ruta
  static const String mainPath = '/';
  static const String bookCommentsPath = '/book/:id/comments';
  static const String userProfilePath = '/profile';
  static const String readingGroupsPath = '/reading-groups';
  static const String searchGroupsPath = '/search-groups';
  static const String groupChatPath = '/group-chat/:id';
  static const String friendScreenPath = '/friend-screen';
  static const String createGroupScreenPath = '/create-group';
  static const String selectBookScreenPath = '/select-book-screen';

  final _router = GoRouter(
    initialLocation: splashPath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: splash,
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: login,
        path: loginPath,
        builder: (context, state) => BlocProvider(
          key: UniqueKey(),
          create: (context) => LoginBloc(
            userRepository: getIt<IUserRepository>(),
          ),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        name: register,
        path: registerPath,
        builder: (context, state) => BlocProvider(
          create: (context) => RegisterBloc(
            userRepository: getIt<IUserRepository>(),
          ),
          child: const RegisterScreen(),
        ),
      ),
      // Añadir la ruta 'home' que falta
      GoRoute(
        name: home,
        path: homePath,
        builder: (context, state) => BlocProvider(
          key: UniqueKey(),
          create: (context) => HomeBloc(
            bookUserRepository: getIt<IBookUserRepository>(),
            bookRepository: getIt<IBookRepository>(),
            iAuthRepository: getIt<IAuthRepository>(),
          )..add(HomeLoadDashboard()),
          child: const HomeScreen(),
        ),
      ),
      // Ruta para explorar libros
      GoRoute(
        name: explore,
        path: explorePath,
        builder: (context, state) => BlocProvider(
          create: (context) =>
              BookLibraryBloc(bookRepository: getIt<IBookRepository>())
                ..add(BookLibraryLoadBooks()),
          child: const ExploreScreen(),
        ),
      ),
      // Ruta para detalles de libro
      GoRoute(
        name: bookDetail,
        path: bookDetailPath,
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) =>
                getIt<BookDetailBloc>()..add(BookDetailLoad(bookId: bookId)),
            child: BookDetailScreen(bookId: bookId),
          );
        },
      ),
      // Ruta para la biblioteca del usuario
      GoRoute(
        name: userLibrary,
        path: userLibraryPath,
        builder: (context, state) => BlocProvider(
          key: UniqueKey(),
          create: (context) => UserLibraryBloc(
            bookUserRepository: getIt<IBookUserRepository>(),
            authRepository: getIt<IAuthRepository>(),
          )..add(UserLibraryLoadBooks()),
          child: const UserLibraryScreen(),
        ),
      ),
      GoRoute(
        name: bookComments,
        path: bookCommentsPath,
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BookCommentsScreen(bookId: bookId);
        },
      ),
      GoRoute(
        name: userProfile,
        path: userProfilePath,
        builder: (context, state) => BlocProvider(
          key: UniqueKey(),
          create: (context) => UserProfileBloc(
            userRepository: getIt<IUserRepository>(),
          )..add(UserProfileLoad()),
          child: const UserProfileScreen(),
        ),
      ),
      GoRoute(
        name: 'select-book-screen',
        path: '/select-book',
        builder: (context, state) => BlocProvider(
          create: (context) =>
              BookLibraryBloc(bookRepository: getIt<IBookRepository>())
                ..add(BookLibraryLoadBooks()),
          child: const SelectBookScreen(),
        ),
      ),

      GoRoute(
        name: readingGroups,
        path: readingGroupsPath,
        builder: (context, state) => BlocProvider(
          create: (context) => ReadingGroupBloc(
            readingGroupRepository: getIt<IReadingGroupRepository>(),
            userRepository: getIt<IUserRepository>(),
            bookRepository: getIt<IBookRepository>(),
            socketService: getIt<SocketService>(), // Añadir SocketService
          )..add(ReadingGroupLoadUserGroups()),
          child: const ReadingGroupsScreen(),
        ),
      ),
      GoRoute(
          name: friendScreen,
          path: friendScreenPath,
          builder: (context, state) => BlocProvider(
                key: UniqueKey(),
                create: (context) => FriendshipBloc(
                  friendshipRepository: getIt<IFriendshipRepository>(),
                )..add(FriendshipLoadFriends()),
                child: const FriendsScreen(),
              )),

      // Búsqueda de grupos
      GoRoute(
        name: searchGroups,
        path: searchGroupsPath,
        builder: (context, state) => BlocProvider(
          create: (context) => ReadingGroupBloc(
            readingGroupRepository: getIt<IReadingGroupRepository>(),
            userRepository: getIt<IUserRepository>(),
            bookRepository: getIt<IBookRepository>(),
            socketService: getIt<SocketService>(), // Añadir SocketService
          ),
          child: const SearchGroupsScreen(),
        ),
      ),

      // Chat de grupo (necesita el ID del grupo)

      GoRoute(
        name: groupChat,
        path: groupChatPath,
        builder: (context, state) {
          final groupId = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => ReadingGroupBloc(
              readingGroupRepository: getIt<IReadingGroupRepository>(),
              userRepository: getIt<IUserRepository>(),
              bookRepository: getIt<IBookRepository>(),
              socketService: getIt<SocketService>(),
            )..add(ReadingGroupLoadById(groupId: groupId)),
            child: GroupChatScreen(groupId: groupId),
          );
        },
      ),
      GoRoute(
        name: createGroupScreen,
        path: createGroupScreenPath,
        builder: (context, state) => BlocProvider(
          create: (context) => ReadingGroupBloc(
            readingGroupRepository: getIt<IReadingGroupRepository>(),
            userRepository: getIt<IUserRepository>(),
            bookRepository: getIt<IBookRepository>(),
            socketService: getIt<SocketService>(), // Añadir SocketService
          ),
          child: const CreateGroupScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'La ruta ${state.uri.path} no existe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(mainPath),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
    redirect: (BuildContext context, GoRouterState state) {
      return null;
    },
  );
}
