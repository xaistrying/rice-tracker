// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/domain/models/purchaser_filter.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';

/// Records arrive in the order they were created, oldest first, which is how
/// the store holds them.
List<PurchaserModel> added(List<(String name, String at)> entries) => [
  for (final (name, at) in entries)
    PurchaserModel(id: name, name: name, dateAdded: at),
];

List<String> namesOn(Map<String, List<PurchaserModel>> groups, String day) =>
    groups[day]!.map((p) => p.name!).toList();

void main() {
  group('groupPurchasersByDay', () {
    test('puts the newest of a day at the top', () {
      final groups = groupPurchasersByDay(
        added([
          ('early', '02/09/2026 08:15'),
          ('midday', '02/09/2026 12:40'),
          ('late', '02/09/2026 17:05'),
        ]),
      );

      expect(namesOn(groups, '02/09/2026'), ['late', 'midday', 'early']);
    });

    test('orders by the clock, not by the digits of the time', () {
      // '9:05' beats '17:05' as a string. Parsing is what stops that.
      final groups = groupPurchasersByDay(
        added([
          ('evening', '02/09/2026 17:05'),
          ('morning', '02/09/2026 09:05'),
        ]),
      );

      expect(namesOn(groups, '02/09/2026'), ['evening', 'morning']);
    });

    test('crosses midnight without mixing the days', () {
      final groups = groupPurchasersByDay(
        added([
          ('yesterday late', '01/09/2026 23:50'),
          ('today early', '02/09/2026 00:10'),
          ('today later', '02/09/2026 06:00'),
        ]),
      );

      expect(groups.keys.toSet(), {'01/09/2026', '02/09/2026'});
      expect(namesOn(groups, '02/09/2026'), ['today later', 'today early']);
      expect(namesOn(groups, '01/09/2026'), ['yesterday late']);
    });

    test('breaks a tie by which was entered later', () {
      // dateAdded is only written to the minute, so a busy minute is not a
      // rare case: it is what happens weighing several people in a row.
      final groups = groupPurchasersByDay(
        added([
          ('first', '02/09/2026 08:15'),
          ('second', '02/09/2026 08:15'),
          ('third', '02/09/2026 08:15'),
        ]),
      );

      expect(namesOn(groups, '02/09/2026'), ['third', 'second', 'first']);
    });

    test('holds that order over repeated grouping', () {
      // List.sort is not stable, so equal times could otherwise come back in a
      // different order each rebuild and shuffle under the reader.
      final purchasers = added([
        for (var i = 0; i < 40; i++) ('p$i', '02/09/2026 08:15'),
      ]);

      final first = namesOn(groupPurchasersByDay(purchasers), '02/09/2026');

      for (var run = 0; run < 5; run++) {
        expect(namesOn(groupPurchasersByDay(purchasers), '02/09/2026'), first);
      }
    });

    test('sinks a time it cannot read to the bottom of its day', () {
      final groups = groupPurchasersByDay(
        added([
          ('broken', '02/09/2026 not-a-time'),
          ('good', '02/09/2026 08:15'),
        ]),
      );

      expect(namesOn(groups, '02/09/2026'), ['good', 'broken']);
    });

    test('keeps everyone, and no one twice', () {
      final purchasers = added([
        ('a', '02/09/2026 08:15'),
        ('b', '01/09/2026 09:00'),
        ('c', '02/09/2026 19:00'),
        ('d', ''),
      ]);

      final groups = groupPurchasersByDay(purchasers);
      final all = groups.values.expand((g) => g).map((p) => p.name).toList();

      expect(all, hasLength(purchasers.length));
      expect(all.toSet(), {'a', 'b', 'c', 'd'});
    });
  });

  group('purchaserAddedAt', () {
    test('reads the whole stamp, to the minute', () {
      final at = purchaserAddedAt(
        PurchaserModel(id: '1', dateAdded: '02/09/2026 17:05'),
      );

      expect(at, DateTime(2026, 9, 2, 17, 5));
    });

    test('is null for a stamp that is missing or malformed', () {
      expect(purchaserAddedAt(PurchaserModel(id: '1')), isNull);
      expect(
        purchaserAddedAt(PurchaserModel(id: '1', dateAdded: '02/09/2026')),
        isNull,
      );
    });
  });
}
