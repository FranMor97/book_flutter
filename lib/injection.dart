import 'package:book_app_f/data/bloc/user_library/user_library_bloc.dart';
import 'package:book_app_f/data/repositories/auth_repository.dart'
    show IAuthRepository;
import 'package:book_app_f/data/repositories/book_user_repository.dart';
import 'package:book_app_f/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String? env}) async =>
    await getIt.init(environment: env);

UserLibraryBloc createUserLibraryBloc() {
  return UserLibraryBloc(
    bookUserRepository: getIt<IBookUserRepository>(),
    authRepository: getIt<IAuthRepository>(),
  );
}
