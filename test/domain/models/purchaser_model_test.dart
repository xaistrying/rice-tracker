// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/domain/models/bag_model.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';

PurchaserModel withBags(List<double> weights) => PurchaserModel(
  id: '1',
  name: 'Alice',
  listOfRiceBagWeights: [
    for (var i = 0; i < weights.length; i++)
      BagModel(id: 'b$i', weight: weights[i]),
  ],
  dateAdded: '29/08/2026 09:00',
);

void main() {
  group('derived values', () {
    test('are computed from the bags', () {
      final purchaser = withBags([10.0, 4.5, 0.5]);

      expect(purchaser.quantity, 3);
      expect(purchaser.totalWeight, 15.0);
    });

    test('are zero for an empty bag list', () {
      expect(withBags([]).quantity, 0);
      expect(withBags([]).totalWeight, 0.0);
    });

    test('are zero when there is no bag list at all', () {
      final noBags = PurchaserModel(id: '1', name: 'Alice');

      expect(noBags.quantity, 0);
      expect(noBags.totalWeight, 0.0);
    });

    test('ignore a bag with no weight rather than failing', () {
      final purchaser = PurchaserModel(
        id: '1',
        listOfRiceBagWeights: [
          BagModel(id: 'b0'),
          BagModel(id: 'b1', weight: 5),
        ],
      );

      expect(purchaser.quantity, 2);
      expect(purchaser.totalWeight, 5.0);
    });
  });

  group('a stored value that disagrees with the bags', () {
    /// What an older build could have left behind: two bags totalling 15kg,
    /// alongside a stored count and total that match neither.
    final drifted = PurchaserModel.fromJson({
      'id': '1',
      'name': 'Alice',
      'listOfRiceBagWeights': [
        {'id': 'b1', 'weight': 10.0},
        {'id': 'b2', 'weight': 5.0},
      ],
      'quantity': 99,
      'totalWeight': 1234.5,
      'dateAdded': '29/08/2026 09:00',
    });

    test('is not trusted on load', () {
      // Storing these meant nothing reconciled them: the home list and the
      // details header both read the stored field, so they agreed with each
      // other while both were wrong.
      expect(drifted.quantity, 2);
      expect(drifted.totalWeight, 15.0);
    });

    test('is corrected by the next write', () {
      expect(drifted.toJson()['quantity'], 2);
      expect(drifted.toJson()['totalWeight'], 15.0);
    });
  });

  group('the stored shape', () {
    test('still carries both derived values', () {
      final json = withBags([10.0, 5.0]).toJson();

      // Written, but never read back. Keeping them means an older build can
      // still open the store.
      expect(json.keys, containsAll(['quantity', 'totalWeight']));
      expect(json['quantity'], 2);
      expect(json['totalWeight'], 15.0);
    });

    test('round-trips', () {
      final original = withBags([10.0, 5.0]);
      final restored = PurchaserModel.fromRawJson(original.toRawJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.dateAdded, original.dateAdded);
      expect(restored.quantity, original.quantity);
      expect(restored.totalWeight, original.totalWeight);
    });
  });

  group('copyWith', () {
    test('leaves the receiver untouched', () {
      // The fields are final, so an in-place edit is a compile error now. This
      // covers the behaviour that depends on it: the state compares its list
      // by identity, so an edit that changed the original in place would make
      // the new state equal the old one and the emit would be dropped.
      final original = withBags([10.0]);
      final edited = original.copyWith(name: 'Renamed');

      expect(original.name, 'Alice');
      expect(edited.name, 'Renamed');
      expect(identical(original, edited), isFalse);
    });

    test('carries the bags over, and with them the derived values', () {
      final edited = withBags([10.0, 5.0]).copyWith(name: 'Renamed');

      expect(edited.quantity, 2);
      expect(edited.totalWeight, 15.0);
    });
  });
}
