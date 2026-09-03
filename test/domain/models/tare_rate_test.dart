// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/domain/models/tare_rate.dart';

void main() {
  group('deductionFor', () {
    test('rounds up to a tenth, as the rate was quoted', () {
      // The worked example the rule was given with: four bags at three to the
      // kilo is 1.333…, and it is settled as 1.4.
      expect(TareRate.standard.deductionFor(4), 1.4);
    });

    test('an exact multiple is not nudged up a tenth', () {
      // Three bags is one kilogram on the nose. Rounding this to 1.1 would
      // take a tenth nobody agreed to, on the most common load there is.
      expect(TareRate.standard.deductionFor(3), 1.0);
      expect(TareRate.standard.deductionFor(6), 2.0);
      expect(TareRate.standard.deductionFor(30), 10.0);
    });

    test('runs up through a load the way the seller would count it', () {
      final deductions = [
        for (var bags = 0; bags <= 7; bags++)
          TareRate.standard.deductionFor(bags),
      ];

      expect(deductions, [0.0, 0.4, 0.7, 1.0, 1.4, 1.7, 2.0, 2.4]);
    });

    test('stays exact over a big load', () {
      // The reason the rate is two integers rather than 0.333 kg a bag: a
      // double would have drifted off the true 33.4 by now.
      expect(TareRate.standard.deductionFor(100), 33.4);
      expect(TareRate.standard.deductionFor(1000), 333.4);
      expect(TareRate.standard.deductionFor(999), 333.0);
    });

    test('honours a rate other than the usual one', () {
      // Purchasers bring their own sacks: heavier ones go two to the kilo,
      // lighter ones four.
      expect(const TareRate(bags: 2, kgTenths: 10).deductionFor(4), 2.0);
      expect(const TareRate(bags: 4, kgTenths: 10).deductionFor(4), 1.0);
      expect(const TareRate(bags: 4, kgTenths: 10).deductionFor(5), 1.3);
    });

    test('honours a fractional kilogram', () {
      // '3 bags = 0.5 kg' is the second box doing its job.
      expect(const TareRate(bags: 3, kgTenths: 5).deductionFor(3), 0.5);
      expect(const TareRate(bags: 3, kgTenths: 5).deductionFor(4), 0.7);
    });

    test('an empty purchaser is deducted nothing', () {
      expect(TareRate.standard.deductionFor(0), 0);
      expect(TareRate.standard.deductionFor(-1), 0);
    });

    test('an unusable rate deducts nothing rather than dividing by zero', () {
      // Reachable from a store written by another build, or a prefs file
      // edited by hand. Returning zero keeps the totals readable; throwing
      // here would take out every screen at once.
      expect(const TareRate(bags: 0, kgTenths: 10).deductionFor(4), 0);
      expect(const TareRate(bags: -3, kgTenths: 10).deductionFor(4), 0);
      expect(const TareRate(bags: 3, kgTenths: 0).deductionFor(4), 0);
    });
  });

  group('isValid', () {
    test('rejects what cannot be divided by or would run away', () {
      expect(TareRate.standard.isValid, isTrue);
      expect(const TareRate(bags: 1, kgTenths: 1).isValid, isTrue);
      expect(const TareRate(bags: 0, kgTenths: 10).isValid, isFalse);
      expect(const TareRate(bags: 3, kgTenths: 0).isValid, isFalse);
      expect(
        const TareRate(bags: TareRate.maxBags + 1, kgTenths: 10).isValid,
        isFalse,
      );
    });
  });

  group('kgLabel', () {
    test('writes the kilograms the way they are typed', () {
      expect(TareRate.standard.kgLabel, '1');
      expect(const TareRate(bags: 3, kgTenths: 5).kgLabel, '0.5');
      expect(const TareRate(bags: 3, kgTenths: 15).kgLabel, '1.5');
      expect(const TareRate(bags: 3, kgTenths: 20).kgLabel, '2');
    });
  });

  test('two rates with the same numbers are the same rate', () {
    // The state compares on this: a rate that failed to equal itself would
    // make every emit look like a change and rebuild the world.
    expect(const TareRate(bags: 3, kgTenths: 10), TareRate.standard);
    expect(
      const TareRate(bags: 3, kgTenths: 10).hashCode,
      TareRate.standard.hashCode,
    );
    expect(const TareRate(bags: 4, kgTenths: 10), isNot(TareRate.standard));
  });
}
