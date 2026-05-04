// Package imports:
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/data/datasources/purchaser_data_source.dart';
import 'package:rice_tracker/domain/repositories/config_repository.dart';
import 'package:rice_tracker/domain/repositories/purchaser_repository.dart';
import '../../data/datasources/config_data_source.dart';
import '../../data/repositories/config_repository_impl.dart';
import '../../data/repositories/purchaser_repository_impl.dart';
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
  getIt.registerLazySingleton<PurchaserDataSource>(
    () => PurchaserDataSourceImpl(),
  );

  // Repository //
  getIt.registerLazySingleton<ConfigRepository>(() => ConfigRepositoryImpl());
  getIt.registerLazySingleton<PurchaserRepository>(
    () => PurchaserRepositoryImpl(),
  );
}
