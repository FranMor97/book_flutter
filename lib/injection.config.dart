// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'data/bloc/book_detail/book_detail_bloc.dart' as _i21;
import 'data/Implementations/api_user_repository.dart' as _i654;
import 'data/Implementations/dio_auth_repository.dart' as _i506;
import 'data/Implementations/dio_book_repository.dart' as _i940;
import 'data/Implementations/dio_book_user.dart' as _i981;
import 'data/Implementations/dio_frienship_repository.dart' as _i274;
import 'data/Implementations/dio_reading_group_repository.dart' as _i936;
import 'data/repositories/auth_repository.dart' as _i593;
import 'data/repositories/book_repository.dart' as _i438;
import 'data/repositories/book_user_repository.dart' as _i914;
import 'data/repositories/friendship_repository.dart' as _i233;
import 'data/repositories/reading_group_repository.dart' as _i228;
import 'data/repositories/user_repository.dart' as _i443;
import 'injection/app_module.dart' as _i984;

const String _dev = 'dev';
const String _prod = 'prod';
const String _test = 'test';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(
        () => appModule.dio(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i654.CacheStore>(
        () => appModule.cacheStore(gh<_i460.SharedPreferences>()));
    gh.factory<String>(
      () => appModule.devApiBaseUrl,
      instanceName: 'apiBaseUrl',
      registerFor: {_dev},
    );
    gh.lazySingleton<_i914.IBookUserRepository>(
      () => _i981.DioBookUserRepository(
        dio: gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
      ),
      registerFor: {
        _dev,
        _prod,
      },
    );
    gh.lazySingleton<_i593.IAuthRepository>(
        () => _i506.DioAuthRepository(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i233.IFriendshipRepository>(
      () => _i274.DioFriendshipRepository(
        dio: gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
      ),
      registerFor: {
        _dev,
        _prod,
      },
    );
    gh.lazySingleton<_i438.IBookRepository>(
      () => _i940.DioBookRepository(
        dio: gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
      ),
      registerFor: {
        _dev,
        _prod,
      },
    );
    gh.factory<_i21.BookDetailBloc>(() => _i21.BookDetailBloc(
          bookRepository: gh<_i438.IBookRepository>(),
          bookUserRepository: gh<_i914.IBookUserRepository>(),
          authRepository: gh<_i593.IAuthRepository>(),
        ));
    gh.factory<String>(
      () => appModule.testApiBaseUrl,
      instanceName: 'apiBaseUrl',
      registerFor: {_test},
    );
    gh.factory<String>(
      () => appModule.apiBaseUrl,
      instanceName: 'apiBaseUrl',
      registerFor: {_prod},
    );
    gh.lazySingleton<_i654.CacheManager>(
        () => appModule.cacheManager(gh<_i654.CacheStore>()));
    gh.lazySingleton<_i228.IReadingGroupRepository>(
        () => _i936.DioReadingGroupRepository(
              dio: gh<_i361.Dio>(),
              baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
            ));
    gh.lazySingleton<_i443.IUserRepository>(
      () => _i654.ApiUserRepository(
        dio: gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
        cacheManager: gh<_i654.CacheManager>(),
      ),
      registerFor: {
        _dev,
        _prod,
      },
    );
    return this;
  }
}

class _$AppModule extends _i984.AppModule {}
