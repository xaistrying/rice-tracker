// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/domain/models/bag_model.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/stored_purchaser_list.dart';
import 'package:rice_tracker/domain/models/tare_policy.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';
import '../../../domain/repositories/config_repository.dart';
import '../../../domain/repositories/purchaser_repository.dart';
import '../../extension/date_time_extension.dart';

part 'app_data_state.dart';
part 'app_data_cubit.freezed.dart';

class AppDataCubit extends Cubit<AppDataState> {
  /// Both repositories default to the container so that a BlocProvider does
  /// not have to resolve them, while a test can still pass a fake.
  AppDataCubit({
    PurchaserRepository? purchaserRepo,
    ConfigRepository? configRepo,
  }) : _purchaserRepo = purchaserRepo ?? getIt<PurchaserRepository>(),
       _configRepo = configRepo ?? getIt<ConfigRepository>(),
       super(const _InitialState(AppDataStateData())) {
    _init();
  }

  final PurchaserRepository _purchaserRepo;

  /// Only for the last-opened date, which is app state rather than purchaser
  /// data and so does not belong on [PurchaserRepository].
  final ConfigRepository _configRepo;

  Future<void> _init() async {
    updatePurchaserList();
    await _repairDuplicateIds();
  }

  /// Gives a fresh id to any record that shares one with an earlier record,
  /// or has none at all.
  ///
  /// Ids were once a bare timestamp, which repeats for records created within
  /// the same clock tick. Records are looked up by id, so a duplicate makes a
  /// single delete remove every record that shares it. Data written before
  /// that was fixed can still hold collisions, so the invariant is re-checked
  /// on load; it only writes when it actually finds one.
  Future<void> _repairDuplicateIds() async {
    final purchaserList = [...state.data.purchaserList];
    final seenPurchaserIds = <String>{};
    var changed = false;

    for (var i = 0; i < purchaserList.length; i++) {
      var purchaser = purchaserList[i];

      final id = purchaser.id;
      if (id == null || !seenPurchaserIds.add(id)) {
        purchaser = purchaser.copyWith(id: DateTime.now().uniqueId);
        seenPurchaserIds.add(purchaser.id!);
        changed = true;
      }

      final bags = purchaser.listOfRiceBagWeights;
      if (bags != null) {
        final seenBagIds = <String>{};
        final repairedBags = <BagModel>[];
        var bagsChanged = false;

        for (final bag in bags) {
          final bagId = bag.id;
          if (bagId == null || !seenBagIds.add(bagId)) {
            final repaired = bag.copyWith(id: DateTime.now().uniqueId);
            seenBagIds.add(repaired.id!);
            repairedBags.add(repaired);
            bagsChanged = true;
          } else {
            repairedBags.add(bag);
          }
        }

        if (bagsChanged) {
          purchaser = purchaser.copyWith(listOfRiceBagWeights: repairedBags);
          changed = true;
        }
      }

      purchaserList[i] = purchaser;
    }

    if (!changed) return;

    final previous = state.data;
    final applied = previous.copyWith(purchaserList: purchaserList);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  /// Writes [applied] to storage, rolling back to [previous] if it fails.
  ///
  /// Callers emit [applied] before awaiting this, so that edits made in quick
  /// succession each build on the latest list instead of on a stale one. The
  /// rollback is therefore skipped when something else has already moved the
  /// state on, so a failed write cannot discard a later change.
  Future<void> _persist(
    AppDataStateData applied,
    AppDataStateData previous,
  ) async {
    final result = await _purchaserRepo.cachePurchaserList(
      purchaserList: applied.purchaserList,
    );

    if (result.isLeft() && !isClosed && state.data == applied) {
      emit(UpdatePurchaserList(previous));
    }
  }

  void updatePurchaserList() {
    final result = _purchaserRepo.getPurchaserList();
    final stored = result.getOrElse((_) => const StoredPurchaserList());

    // A store that could not be read in full is the one case where carrying on
    // normally is destructive: writing replaces the whole list, so the next
    // ordinary edit would overwrite records the app never managed to load.
    // Copying the raw value aside first keeps them recoverable.
    //
    // Deliberately not awaited. Loading has to stay synchronous so that the
    // list is in place the moment the cubit is constructed; an edit cannot
    // arrive before the next frame, and the backup is only best effort.
    final readIssue = result.isLeft()
        ? StoreReadIssue.unreadable
        : (stored.isComplete ? null : StoreReadIssue.partial);

    if (readIssue != null) {
      unawaited(_purchaserRepo.backupPurchaserList());
    }

    // Carried in the state so the screen can say so. Keeping the data safe is
    // not much use on its own: an unreadable store shows the same empty list a
    // fresh install does, so without this the user's only reasonable reading
    // is that the app lost everything, and they start typing it back in.
    emit(
      UpdatePurchaserList(
        state.data.copyWith(
          purchaserList: stored.purchasers,
          readIssue: readIssue,
          unreadableRecords: stored.skipped,
        ),
      ),
    );
  }

  Future<void> addNewPurchaser({required String name}) async {
    final now = DateTime.now();
    final previous = state.data;

    final applied = previous.copyWith(
      purchaserList: [
        ...previous.purchaserList,
        PurchaserModel(
          id: now.uniqueId,
          name: name,
          dateAdded: now.toTimeString(),
          tareRate: _startingTareRate(),
        ),
      ],
    );

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  Future<void> removePurchaser({required String? id}) async {
    if (id == null) return;

    final previous = state.data;
    final purchaserList = [...previous.purchaserList];
    final index = purchaserList.indexWhere((e) => e.id == id);

    if (index == -1) return;

    purchaserList.removeAt(index);

    final applied = previous.copyWith(purchaserList: purchaserList);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  Future<void> updatePurchaserName({
    required String? id,
    required String? newName,
  }) async {
    if (id == null || newName == null) return;

    final previous = state.data;
    final purchaserList = [...previous.purchaserList];
    final index = purchaserList.indexWhere((e) => e.id == id);

    if (index == -1) return;

    // Replace the element rather than mutating it: the list is a shallow copy,
    // so mutating in place would also change the previous state's model and
    // make the new state compare equal to the old one, dropping the emit.
    purchaserList[index] = purchaserList[index].copyWith(name: newName);

    final applied = previous.copyWith(purchaserList: purchaserList);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  /// The rate to stamp on a purchaser being created, or null to leave them
  /// following whatever the default is at the time.
  ///
  /// Stamped rather than left to follow, so that changing the default later —
  /// new sacks, a different supplier — does not restate loads that were
  /// already weighed and settled at the old rate. Nothing is stamped while the
  /// switch is off: there is no rate in force to record.
  TareRate? _startingTareRate() {
    final policy = _configRepo.getTarePolicy().getOrElse((_) => TarePolicy.off);

    return policy.enabled ? policy.defaultRate : null;
  }

  /// Gives one purchaser a sack rate of their own.
  ///
  /// Stored on the record rather than in settings because it genuinely differs
  /// between people: one brings sacks that go four to the kilo, another two.
  Future<void> updatePurchaserTareRate({
    required String? id,
    required TareRate rate,
  }) async {
    // The rate is a divisor, and it arrives from two text boxes.
    if (id == null || !rate.isValid) return;

    final previous = state.data;
    final purchaserList = [...previous.purchaserList];
    final index = purchaserList.indexWhere((e) => e.id == id);

    if (index == -1) return;

    if (purchaserList[index].tareRate == rate) return;

    // Replaced rather than mutated, for the reason given in
    // [updatePurchaserName].
    purchaserList[index] = purchaserList[index].copyWith(tareRate: rate);

    final applied = previous.copyWith(purchaserList: purchaserList);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  Future<void> addBagToPurchaser({
    required String? id,
    required String? weight,
  }) async {
    if (id == null) return;

    final parsedWeight = double.tryParse(weight ?? '');

    if (parsedWeight == null) return;

    final previous = state.data;
    final purchaserList = [...previous.purchaserList];
    final index = purchaserList.indexWhere((e) => e.id == id);

    if (index == -1) return;

    final bags = [
      ...?purchaserList[index].listOfRiceBagWeights,
      BagModel(id: DateTime.now().uniqueId, weight: parsedWeight),
    ];

    // The count and the total follow from the bags, so there is nothing else
    // to set here.
    purchaserList[index] = purchaserList[index].copyWith(
      listOfRiceBagWeights: bags,
    );

    final applied = previous.copyWith(purchaserList: purchaserList);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  Future<void> removeBagFromPurchaser({
    required String? purchaserId,
    required String? bagId,
  }) async {
    if (purchaserId == null || bagId == null) return;

    final previous = state.data;
    final purchaserList = [...previous.purchaserList];
    final index = purchaserList.indexWhere((e) => e.id == purchaserId);

    if (index == -1) return;

    final bags = [...?purchaserList[index].listOfRiceBagWeights]
      ..removeWhere((item) => item.id == bagId);

    purchaserList[index] = purchaserList[index].copyWith(
      listOfRiceBagWeights: bags,
    );

    final applied = previous.copyWith(purchaserList: purchaserList);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  Future<void> deleteAllPurchaser() async {
    final previous = state.data;
    final applied = previous.copyWith(purchaserList: []);

    emit(UpdatePurchaserList(applied));

    await _persist(applied, previous);
  }

  Future<void> updateIfNewDay() async {
    final date = _configRepo.getDate().getOrElse((_) => '');
    final now = DateTime.now();

    if (date == '') {
      await _configRepo.cacheDate(date: now.toIso8601String());
      return;
    }

    // A corrupt cached value would throw from DateTime.parse; re-seed it
    // instead, the same way an absent value is handled above.
    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      await _configRepo.cacheDate(date: now.toIso8601String());
      return;
    }

    final isNewDay =
        parsedDate.year != now.year ||
        parsedDate.month != now.month ||
        parsedDate.day != now.day;

    if (isNewDay) {
      // Re-read rather than re-emitting state.data: an identical state is
      // dropped by emit, so the date headers would never refresh.
      updatePurchaserList();
      await _configRepo.cacheDate(date: now.toIso8601String());
    }
  }
}
