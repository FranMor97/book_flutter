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

import 'data/Implementations/api_user_repository.dart' as _i654;
import 'data/repositories/user_repository.dart' as _i443;
import 'injection/app_module.dart' as _i984;

const String _dev = 'dev';
const String _test = 'test';
const String _prod = 'prod';

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
    gh.lazySingleton<_i654.CacheStore>(
        () => _i654.SharedPrefsCacheStore(gh<_i460.SharedPreferences>()));
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
        () => _i654.CacheManager(gh<_i654.CacheStore>()));
    gh.lazySingleton<_i443.UserRepository>(
      () => _i654.ApiUserRepository(
        dio: gh<_i361.Dio>(),
        baseUrl: gh<String>(instanceName: 'apiBaseUrl'),
        cacheManager: gh<_i654.CacheManager>(),
      ),
      registerFor: {
        _prod,
        _dev,
      },
    );
    return this;
  }
}

class _$AppModule extends _i984.AppModule {}
