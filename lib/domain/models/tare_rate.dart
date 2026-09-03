/// What the empty sacks weigh, as the rate is quoted: [bags] of them together
/// weigh [kgTenths] tenths of a kilogram.
///
/// Held as two integers rather than one kilograms-per-bag double on purpose.
/// The usual rate, three to the kilo, is 0.333… kg a bag; carried as a double
/// and multiplied back out it drifts, and on a small load the drift is the
/// same size as the deduction itself.
class TareRate {
  const TareRate({required this.bags, required this.kgTenths});

  /// Three bags to the kilogram — what the rate usually is.
  static const standard = TareRate(bags: 3, kgTenths: 10);

  static const maxBags = 999;
  static const maxKgTenths = 9999;

  /// How many sacks are weighed together.
  final int bags;

  /// What those sacks weigh, in tenths of a kilogram.
  ///
  /// Tenths rather than a double so half a kilo is 5, not 0.5, and the
  /// division below stays in integers from end to end.
  final int kgTenths;

  /// False for anything that would divide by zero or run away with the total.
  bool get isValid =>
      bags >= 1 && bags <= maxBags && kgTenths >= 1 && kgTenths <= maxKgTenths;

  /// The kilograms half, written the way it is typed: '1', or '0.5'.
  String get kgLabel {
    final whole = kgTenths ~/ 10;
    final frac = kgTenths % 10;

    return frac == 0 ? '$whole' : '$whole.$frac';
  }

  /// What to take off a load of [bagCount] bags, in kilograms.
  ///
  /// Rounded up to a tenth, so four bags at three to the kilo deducts 1.4 and
  /// not 1.33: everything else on screen is quoted to one decimal, and
  /// rounding down would leave a sliver of sack weight in the total.
  double deductionFor(int bagCount) {
    if (bagCount <= 0 || !isValid) return 0;

    // Ceiling division kept in integers: (a + b - 1) ~/ b rounds up without
    // ever touching a double, so no bag count can round the wrong way.
    final tenths = (bagCount * kgTenths + bags - 1) ~/ bags;

    return tenths / 10;
  }

  TareRate copyWith({int? bags, int? kgTenths}) =>
      TareRate(bags: bags ?? this.bags, kgTenths: kgTenths ?? this.kgTenths);

  @override
  bool operator ==(Object other) =>
      other is TareRate && other.bags == bags && other.kgTenths == kgTenths;

  @override
  int get hashCode => Object.hash(bags, kgTenths);

  @override
  String toString() => 'TareRate($bags bags = $kgLabel kg)';
}
