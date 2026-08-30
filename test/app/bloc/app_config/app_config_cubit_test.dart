// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/data/datasources/config_data_source.dart';

Future<AppConfigCubit> bootWith(String? languageCode) async {
  SharedPreferences.setMockInitialValues(
    languageCode == null
        ? {}
        : {ConfigDataSourceImpl.languageCodeKey: languageCode},
  );
  await getIt.reset();
  await initDependencies();
  return AppConfigCubit();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a stored language code is used', () async {
    final cubit = await bootWith('vi');
    addTearDown(cubit.close);

    expect(cubit.state.data.locale?.languageCode, 'vi');
  });

  test(
    'a code that is no longer supported falls back instead of throwing',
    () async {
      // The stored code is only as current as the release that wrote it. This
      // used to throw a StateError out of firstWhere, and it runs inside the
      // constructor, so it would have crashed on every launch for anyone still
      // holding the dropped code — with no way out but clearing app data.
      final cubit = await bootWith('fr');
      addTearDown(cubit.close);

      expect(cubit.state.data.locale?.languageCode, 'en');
    },
  );

  test('an empty store falls back rather than failing', () async {
    final cubit = await bootWith(null);
    addTearDown(cubit.close);

    expect(cubit.state.data.locale, isNotNull);
  });
}
