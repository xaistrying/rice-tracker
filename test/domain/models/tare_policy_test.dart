// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/domain/models/bag_model.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/tare_policy.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';

PurchaserModel purchaser({
  required List<double> weights,
  TareRate? rate,
  String id = '1',
}) => PurchaserModel(
  id: id,
  name: 'A',
  tareRate: rate,
  listOfRiceBagWeights: [
    for (var i = 0; i < weights.length; i++)
      BagModel(id: 'b$i', weight: weights[i]),
  ],
);

const on = TarePolicy(enabled: true, defaultRate: TareRate.standard);

void main() {
  group('rateFor', () {
    test('uses the purchaser own rate over the default', () {
      final p = purchaser(
        weights: [10, 10, 10, 10],
        rate: const TareRate(bags: 2, kgTenths: 10),
      );

      expect(on.rateFor(p).bags, 2);
      expect(on.deductionFor(p), 2.0);
    });

    test('falls back to the default when none was ever chosen', () {
      // What every record written before this feature existed looks like.
      final p = purchaser(weights: [10, 10, 10, 10]);

      expect(on.rateFor(p), TareRate.standard);
      expect(on.deductionFor(p), 1.4);
    });

    test('a record with no rate follows the default when it changes', () {
      final p = purchaser(weights: [10, 10, 10, 10]);
      const custom = TarePolicy(
        enabled: true,
        defaultRate: TareRate(bags: 4, kgTenths: 10),
      );

      expect(custom.deductionFor(p), 1.0);
    });
  });

  group('while the switch is off', () {
    test('nothing is deducted, whatever rate is on the record', () {
      final p = purchaser(
        weights: [10, 10, 10, 10],
        rate: const TareRate(bags: 2, kgTenths: 10),
      );

      expect(TarePolicy.off.deductionFor(p), 0);
      expect(TarePolicy.off.netWeightOf(p), 40.0);
    });

    test('the rate on the record survives to be used again', () {
      // Switching off must cost a tap, not the setup: a purchaser set to two
      // to the kilo is still set to it when it goes back on.
      const rate = TareRate(bags: 2, kgTenths: 10);
      final p = purchaser(weights: [10, 10, 10, 10], rate: rate);

      expect(TarePolicy.off.rateFor(p), rate);
      expect(on.rateFor(p), rate);
    });
  });

  group('netWeightOf', () {
    test('takes the sacks off what was weighed', () {
      final p = purchaser(weights: [46.2, 45.5, 45.2, 45.3]);

      expect(p.totalWeight, closeTo(182.2, 0.001));
      expect(on.netWeightOf(p), closeTo(180.8, 0.001));
    });

    test('never goes negative', () {
      // A bag may be entered as light as 0.1 kg, so three of them really can
      // weigh less than the sacks holding them. A negative total on screen
      // reads as a bug rather than as an edge case.
      final p = purchaser(weights: [0.1, 0.1, 0.1]);

      expect(on.deductionFor(p), 1.0);
      expect(on.netWeightOf(p), 0.0);
    });

    test('an empty purchaser is untouched', () {
      final p = PurchaserModel(id: '1');

      expect(on.deductionFor(p), 0);
      expect(on.netWeightOf(p), 0);
    });
  });

  group('totalNetWeightOf', () {
    test('rounds each load on its own, because each is settled on its own', () {
      // Two loads of four bags deduct 1.4 twice. Rounding their eight bags
      // together would give 2.7, and neither purchaser was settled that way.
      final people = [
        purchaser(weights: [10, 10, 10, 10], id: '1'),
        purchaser(weights: [10, 10, 10, 10], id: '2'),
      ];

      expect(on.deductionFor(people.first), 1.4);
      expect(on.totalNetWeightOf(people), closeTo(77.2, 0.001));
      expect(TareRate.standard.deductionFor(8), 2.7);
    });

    test('adds up each purchaser at their own rate', () {
      final people = [
        purchaser(weights: [10, 10, 10, 10], id: '1'),
        purchaser(
          weights: [10, 10, 10, 10],
          id: '2',
          rate: const TareRate(bags: 2, kgTenths: 10),
        ),
      ];

      expect(on.totalNetWeightOf(people), closeTo(76.6, 0.001));
    });

    test('is the plain sum while the switch is off', () {
      final people = [
        purchaser(weights: [10, 10, 10, 10], id: '1'),
        purchaser(weights: [10, 10, 10, 10], id: '2'),
      ];

      expect(TarePolicy.off.totalNetWeightOf(people), 80.0);
    });
  });
}
