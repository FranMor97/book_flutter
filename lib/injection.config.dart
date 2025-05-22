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

import 'data/Implementations/dio_book_repository.dart' as _i940;
import 'data/Implementations/dio_book_user.dart' as _i981;
import 'data/repositories/book_repository.dart' as _i438;
import 'data/repositories/book_user_repository.dart' as _i914;
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
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
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
    return this;
  }
}

class _$AppModule extends _i984.AppModule {}
