// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/data/datasources/purchaser_data_source.dart';
import 'package:rice_tracker/domain/models/stored_purchaser_list.dart';
import 'package:rice_tracker/domain/repositories/config_repository.dart';
import 'package:rice_tracker/domain/repositories/purchaser_repository.dart';

/// Lets a state emission be observed before asserting on it.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDataCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await initDependencies();
    cubit = AppDataCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  /// Records every state the cubit emits from this point on.
  List<AppDataState> record() {
    final emitted = <AppDataState>[];
    cubit.stream.listen(emitted.add);
    return emitted;
  }

  group('purchaser edits produce a distinct state', () {
    // The models have no `==`, and the state compares its list with
    // DeepCollectionEquality, so an edit that reused an instance would leave
    // the new state equal to the old one and Cubit would silently drop the
    // emit. The fields are final now, so that particular mistake no longer
    // compiles; these cover the behaviour that depends on it.
    test('rename emits, and leaves the previous state untouched', () async {
      await cubit.addNewPurchaser(name: 'Alice');
      final id = cubit.state.data.purchaserList.single.id;
      final before = cubit.state.data;
      await settle();

      final emitted = record();
      await cubit.updatePurchaserName(id: id, newName: 'Alice Renamed');
      await settle();

      expect(emitted, hasLength(1), reason: 'the emit must not be dropped');
      expect(cubit.state.data.purchaserList.single.name, 'Alice Renamed');
      expect(
        before.purchaserList.single.name,
        'Alice',
        reason: 'the previous state must not be mutated',
      );
      expect(before, isNot(cubit.state.data));
    });

    test('adding a bag emits', () async {
      await cubit.addNewPurchaser(name: 'Alice');
      final id = cubit.state.data.purchaserList.single.id;
      await settle();

      final emitted = record();
      await cubit.addBagToPurchaser(id: id, weight: '10');
      await settle();

      expect(emitted, hasLength(1));
    });

    test('removing a bag emits', () async {
      await cubit.addNewPurchaser(name: 'Alice');
      final id = cubit.state.data.purchaserList.single.id;
      await cubit.addBagToPurchaser(id: id, weight: '10');
      final bagId =
          cubit.state.data.purchaserList.single.listOfRiceBagWeights!.single.id;
      await settle();

      final emitted = record();
      await cubit.removeBagFromPurchaser(purchaserId: id, bagId: bagId);
      await settle();

      expect(emitted, hasLength(1));
    });
  });

  group('bag totals', () {
    late String id;

    setUp(() async {
      await cubit.addNewPurchaser(name: 'Bob');
      id = cubit.state.data.purchaserList.single.id!;
    });

    test('accumulate across adds', () async {
      await cubit.addBagToPurchaser(id: id, weight: '10.5');
      await cubit.addBagToPurchaser(id: id, weight: '4.5');

      final purchaser = cubit.state.data.purchaserList.single;
      expect(purchaser.quantity, 2);
      expect(purchaser.totalWeight, 15.0);
    });

    test('back-to-back adds without awaiting do not lose one', () async {
      // The state is emitted before the write is awaited precisely so that a
      // second edit builds on the first rather than on a stale list.
      final first = cubit.addBagToPurchaser(id: id, weight: '1');
      final second = cubit.addBagToPurchaser(id: id, weight: '2');
      await Future.wait([first, second]);

      final purchaser = cubit.state.data.purchaserList.single;
      expect(purchaser.quantity, 2);
      expect(purchaser.totalWeight, 3.0);
    });

    test('recompute on remove, down to zero', () async {
      await cubit.addBagToPurchaser(id: id, weight: '10.5');
      await cubit.addBagToPurchaser(id: id, weight: '4.5');

      final firstBagId =
          cubit.state.data.purchaserList.single.listOfRiceBagWeights!.first.id;
      await cubit.removeBagFromPurchaser(purchaserId: id, bagId: firstBagId);

      var purchaser = cubit.state.data.purchaserList.single;
      expect(purchaser.quantity, 1);
      expect(purchaser.totalWeight, 4.5);

      await cubit.removeBagFromPurchaser(
        purchaserId: id,
        bagId: purchaser.listOfRiceBagWeights!.single.id,
      );

      purchaser = cubit.state.data.purchaserList.single;
      expect(purchaser.quantity, 0);
      expect(
        purchaser.totalWeight,
        0.0,
        reason: 'an emptied list must not keep a stale total',
      );
    });

    test('bags added in the same clock tick get distinct ids', () async {
      // DateTime.now() is coarser than a microsecond on some platforms, so a
      // timestamp alone is not a unique id. Colliding ids would make a single
      // delete remove every bag added in that tick.
      for (var i = 0; i < 20; i++) {
        await cubit.addBagToPurchaser(id: id, weight: '1');
      }

      final bags = cubit.state.data.purchaserList.single.listOfRiceBagWeights!;
      expect(bags.map((b) => b.id).toSet(), hasLength(bags.length));
    });

    test(
      'removing one of two identical-weight bags removes only one',
      () async {
        await cubit.addBagToPurchaser(id: id, weight: '5');
        await cubit.addBagToPurchaser(id: id, weight: '5');

        final firstBagId = cubit
            .state
            .data
            .purchaserList
            .single
            .listOfRiceBagWeights!
            .first
            .id;
        await cubit.removeBagFromPurchaser(purchaserId: id, bagId: firstBagId);

        final purchaser = cubit.state.data.purchaserList.single;
        expect(purchaser.quantity, 1);
        expect(purchaser.totalWeight, 5.0);
      },
    );

    test('a non-numeric weight is ignored', () async {
      await cubit.addBagToPurchaser(id: id, weight: 'abc');
      expect(
        cubit.state.data.purchaserList.single.listOfRiceBagWeights,
        isNull,
      );
    });
  });

  group('unknown ids are handled instead of throwing', () {
    setUp(() => cubit.addNewPurchaser(name: 'Carol'));

    test('addBagToPurchaser', () async {
      await expectLater(
        cubit.addBagToPurchaser(id: 'missing', weight: '1'),
        completes,
      );
    });

    test('removeBagFromPurchaser', () async {
      await expectLater(
        cubit.removeBagFromPurchaser(purchaserId: 'missing', bagId: 'x'),
        completes,
      );
    });

    test('updatePurchaserName', () async {
      await expectLater(
        cubit.updatePurchaserName(id: 'missing', newName: 'X'),
        completes,
      );
    });
  });

  group('duplicate ids already in storage are repaired on load', () {
    Map<String, dynamic> stored(
      String? id,
      String name, [
      List<Map<String, dynamic>> bags = const [],
    ]) => {
      'id': id,
      'name': name,
      'listOfRiceBagWeights': bags,
      'quantity': bags.length,
      'totalWeight': 0.0,
      'dateAdded': '30/08/2026 10:00',
    };

    Future<AppDataCubit> loadFrom(List<Map<String, dynamic>> purchasers) async {
      SharedPreferences.setMockInitialValues({
        PurchaserDataSourceImpl.purchaserListKey: json.encode(purchasers),
      });
      await getIt.reset();
      await initDependencies();
      return AppDataCubit();
    }

    test('two purchasers sharing an id are given distinct ones', () async {
      final loaded = await loadFrom([stored('dup', 'A'), stored('dup', 'B')]);
      addTearDown(loaded.close);

      final purchasers = loaded.state.data.purchaserList;
      expect(purchasers.map((e) => e.id).toSet(), hasLength(2));
      expect(purchasers.map((e) => e.name), [
        'A',
        'B',
      ], reason: 'the repair must not drop or reorder records');
    });

    test('bags sharing an id within a purchaser are re-ided', () async {
      final loaded = await loadFrom([
        stored('p1', 'A', [
          {'id': 'dup', 'weight': 1.0},
          {'id': 'dup', 'weight': 2.0},
        ]),
      ]);
      addTearDown(loaded.close);

      final bags = loaded.state.data.purchaserList.single.listOfRiceBagWeights!;
      expect(bags.map((b) => b.id).toSet(), hasLength(2));
      expect(bags.map((b) => b.weight), [1.0, 2.0]);
    });

    test('a missing id is filled in', () async {
      final loaded = await loadFrom([stored('p1', 'A'), stored(null, 'B')]);
      addTearDown(loaded.close);

      expect(
        loaded.state.data.purchaserList.every((e) => e.id != null),
        isTrue,
      );
      expect(
        loaded.state.data.purchaserList.map((e) => e.id).toSet(),
        hasLength(2),
      );
    });

    test('the repair is written back to storage', () async {
      final loaded = await loadFrom([stored('dup', 'A'), stored('dup', 'B')]);
      addTearDown(loaded.close);
      await settle();

      final persisted = getIt<PurchaserRepository>()
          .getPurchaserList()
          .getOrElse((_) => const StoredPurchaserList());
      expect(persisted.purchasers.map((e) => e.id).toSet(), hasLength(2));
    });

    test('data without collisions is left exactly as it was', () async {
      final loaded = await loadFrom([stored('p1', 'A'), stored('p2', 'B')]);
      addTearDown(loaded.close);

      expect(loaded.state.data.purchaserList.map((e) => e.id), ['p1', 'p2']);
    });
  });

  group('updateIfNewDay', () {
    Future<void> seedDate(DateTime date) =>
        getIt<ConfigRepository>().cacheDate(date: date.toIso8601String());

    test('emits when the cached date is from an earlier day', () async {
      await seedDate(DateTime.now().subtract(const Duration(days: 2)));
      await cubit.addNewPurchaser(name: 'Dave');
      await settle();

      final emitted = record();
      await cubit.updateIfNewDay();
      await settle();

      // Re-reading from storage is what makes this a distinct state; emitting
      // the existing state.data would be dropped as an equal state.
      expect(emitted, hasLength(1));
      expect(emitted.single, isA<UpdatePurchaserList>());
    });

    test('is a no-op on the same day', () async {
      await seedDate(DateTime.now());
      await cubit.addNewPurchaser(name: 'Erin');
      await settle();

      final emitted = record();
      await cubit.updateIfNewDay();
      await settle();

      expect(emitted, isEmpty);
    });

    test('a corrupt cached date is re-seeded rather than thrown', () async {
      await getIt<ConfigRepository>().cacheDate(date: 'not-a-date');

      await expectLater(cubit.updateIfNewDay(), completes);
      expect(
        DateTime.tryParse(
          getIt<ConfigRepository>().getDate().getOrElse((_) => ''),
        ),
        isNotNull,
      );
    });
  });
}
