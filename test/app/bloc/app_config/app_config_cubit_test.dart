// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/data/datasources/config_data_source.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';

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

/// Boots with a store already holding [values], the way a relaunch would find
/// whatever the last session wrote.
Future<AppConfigCubit> bootWithStore(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
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

  group('the sack deduction', () {
    test('is off on a store that has never held it', () async {
      // The one that matters on an update. Defaulting the other way would take
      // a kilogram off every record already on file, unasked, on first launch.
      final cubit = await bootWith(null);
      addTearDown(cubit.close);

      expect(cubit.state.data.tarePolicy.enabled, isFalse);
      expect(cubit.state.data.tarePolicy.defaultRate, TareRate.standard);
    });

    test('comes back on with the rate it was left at', () async {
      final first = await bootWith(null);
      await first.setTareEnabled(true);
      await first.setTareDefaultRate(const TareRate(bags: 4, kgTenths: 5));
      await first.close();

      // Same store, fresh cubit: what a relaunch does.
      final second = AppConfigCubit();
      addTearDown(second.close);
      await Future<void>.delayed(Duration.zero);

      expect(second.state.data.tarePolicy.enabled, isTrue);
      expect(
        second.state.data.tarePolicy.defaultRate,
        const TareRate(bags: 4, kgTenths: 5),
      );
    });

    test('switching off leaves the default rate alone', () async {
      final cubit = await bootWith(null);
      addTearDown(cubit.close);

      await cubit.setTareEnabled(true);
      await cubit.setTareDefaultRate(const TareRate(bags: 4, kgTenths: 10));
      await cubit.setTareEnabled(false);

      expect(cubit.state.data.tarePolicy.enabled, isFalse);
      expect(
        cubit.state.data.tarePolicy.defaultRate.bags,
        4,
        reason: 'a stray tap on the switch must not cost the setup',
      );
    });

    test('an unusable default is refused rather than stored', () async {
      // It arrives from two text boxes, and the bags half is a divisor.
      final cubit = await bootWith(null);
      addTearDown(cubit.close);

      await cubit.setTareEnabled(true);
      await cubit.setTareDefaultRate(const TareRate(bags: 0, kgTenths: 10));

      expect(cubit.state.data.tarePolicy.defaultRate, TareRate.standard);
    });

    test('a stored rate that cannot be used falls back to the usual', () async {
      // Half a rate is what a write refused between the two keys leaves
      // behind; a zero is what a hand-edited prefs file could.
      final cubit = await bootWithStore({
        ConfigDataSourceImpl.tareEnabledKey: true,
        ConfigDataSourceImpl.tareDefaultBagsKey: 0,
        ConfigDataSourceImpl.tareDefaultKgTenthsKey: 10,
      });
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data.tarePolicy.defaultRate, TareRate.standard);
    });

    test('half a stored rate falls back rather than being half used', () async {
      final cubit = await bootWithStore({
        ConfigDataSourceImpl.tareEnabledKey: true,
        ConfigDataSourceImpl.tareDefaultBagsKey: 4,
      });
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data.tarePolicy.defaultRate, TareRate.standard);
    });
  });
}
