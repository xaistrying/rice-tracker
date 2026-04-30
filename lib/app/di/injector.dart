// Package imports:
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../data/datasources/config_data_source.dart';
import '../../data/repositories/config_repository_impl.dart';
import '../../domain/repositories/config_repository.dart';
import '../service/app_prefs_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Dependencies //
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Service //
  getIt.registerSingleton<AppPrefsServiceHelper>(AppPrefsServiceHelper());

  // Data Source //
  getIt.registerLazySingleton<ConfigDataSource>(() => ConfigDataSourceImpl());

  // Repository //
  getIt.registerLazySingleton<ConfigRepository>(() => ConfigRepositoryImpl());
}
