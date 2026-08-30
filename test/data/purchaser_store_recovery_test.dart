// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/data/datasources/purchaser_data_source.dart';
import 'package:rice_tracker/domain/repositories/purchaser_repository.dart';

/// Lets the best-effort backup, which is deliberately not awaited, run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

/// [rawId] writes the id as raw JSON, so a test can store one of the wrong
/// type the way a schema change would.
String record(String id, String name, {String? rawId}) =>
    '{"id":${rawId ?? '"$id"'},"name":"$name",'
    '"listOfRiceBagWeights":[{"id":"b$id","weight":50.0}],'
    '"quantity":1,"totalWeight":50.0,'
    '"dateAdded":"29/08/2026 09:00"}';

final healthy =
    '[${record('1', 'Alice')},'
    '${record('2', 'Bob')},'
    '${record('3', 'Carol')}]';

/// The same store with Bob's id written as a number rather than a string.
///
/// PurchaserModel declares it String?, so only that record fails to parse.
final oneBadRecord =
    '[${record('1', 'Alice')},'
    '${record('2', 'Bob', rawId: '2')},'
    '${record('3', 'Carol')}]';

const unreadable = '{not json';

String? mainStore() => getIt<SharedPreferences>().getString(
  PurchaserDataSourceImpl.purchaserListKey,
);

String? backupStore() => getIt<SharedPreferences>().getString(
  PurchaserDataSourceImpl.purchaserListBackupKey,
);

Future<AppDataCubit> bootWith(String? stored) async {
  SharedPreferences.setMockInitialValues(
    stored == null ? {} : {PurchaserDataSourceImpl.purchaserListKey: stored},
  );
  await getIt.reset();
  await initDependencies();
  return AppDataCubit();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('a healthy store', () {
    test('loads every record', () async {
      final cubit = await bootWith(healthy);
      addTearDown(cubit.close);

      expect(cubit.state.data.purchaserList.map((e) => e.name), [
        'Alice',
        'Bob',
        'Carol',
      ]);
    });

    test('is not backed up', () async {
      final cubit = await bootWith(healthy);
      addTearDown(cubit.close);
      await settle();

      // A backup on every launch would be noise, and would eventually be taken
      // from a state no better than the live one.
      expect(backupStore(), isNull);
    });
  });

  group('one record cannot be read', () {
    test('the readable records still load', () async {
      final cubit = await bootWith(oneBadRecord);
      addTearDown(cubit.close);

      expect(cubit.state.data.purchaserList.map((e) => e.name), [
        'Alice',
        'Carol',
      ], reason: 'one bad record must not cost the whole list');
    });

    test('the original is copied aside before an edit overwrites it', () async {
      final cubit = await bootWith(oneBadRecord);
      addTearDown(cubit.close);
      await settle();

      await cubit.addNewPurchaser(name: 'Dave');

      expect(
        mainStore(),
        isNot(contains('Bob')),
        reason: 'the write drops the record that could not be parsed',
      );
      expect(
        backupStore(),
        contains('Bob'),
        reason: 'so it has to survive somewhere',
      );
    });
  });

  group('the store cannot be read at all', () {
    test('is not silently treated as an empty store', () async {
      final result = await bootWith(unreadable).then((cubit) {
        addTearDown(cubit.close);
        return getIt<PurchaserRepository>().getPurchaserList();
      });

      expect(
        result.isLeft(),
        isTrue,
        reason: 'an empty Right here is what destroyed the data',
      );
    });

    test(
      'the raw value is copied aside before an edit overwrites it',
      () async {
        final cubit = await bootWith(unreadable);
        addTearDown(cubit.close);
        await settle();

        expect(backupStore(), unreadable);

        await cubit.addNewPurchaser(name: 'Dave');

        expect(mainStore(), contains('Dave'));
        expect(
          backupStore(),
          unreadable,
          reason: 'the original is still recoverable after the overwrite',
        );
      },
    );
  });

  group('the backup', () {
    test('is taken once and never replaced', () async {
      final cubit = await bootWith(unreadable);
      addTearDown(cubit.close);
      await settle();

      expect(backupStore(), unreadable);

      // A second, later attempt must not overwrite the first copy with a state
      // that has already been damaged further.
      final second = await getIt<PurchaserRepository>().backupPurchaserList();

      expect(second.getOrElse((_) => true), isFalse);
      expect(backupStore(), unreadable);
    });

    test('is not taken when there is nothing stored', () async {
      final cubit = await bootWith(null);
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.data.purchaserList, isEmpty);
      expect(backupStore(), isNull);
    });
  });
}
