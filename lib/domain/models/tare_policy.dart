// Project imports:
import 'purchaser_model.dart';
import 'tare_rate.dart';

/// Whether the sacks are deducted at all, and at what rate for anyone who has
/// not been given one of their own.
///
/// The rate belongs to the purchaser — one brings sacks that go four to the
/// kilo, another two — so it is stored on their record and only the switch and
/// the starting rate live here.
///
/// This is also the one place a net weight is worked out. The home list, the
/// details screen and the shared report all ask it the same question, so they
/// cannot drift apart on what someone is owed for.
class TarePolicy {
  const TarePolicy({required this.enabled, required this.defaultRate});

  /// No deduction: what the app does until the switch is turned on.
  static const off = TarePolicy(enabled: false, defaultRate: TareRate.standard);

  final bool enabled;

  /// What a purchaser starts at when nobody has said otherwise.
  final TareRate defaultRate;

  /// The rate in force for [purchaser].
  ///
  /// Records written before this feature existed carry no rate of their own and
  /// fall back to the default, so setting the default to what the business
  /// actually uses settles those too rather than stranding them on a rate
  /// nobody chose.
  TareRate rateFor(PurchaserModel purchaser) =>
      purchaser.tareRate ?? defaultRate;

  /// The kilograms of sack in a purchaser's load, or zero while the switch is
  /// off.
  double deductionFor(PurchaserModel purchaser) =>
      enabled ? rateFor(purchaser).deductionFor(purchaser.quantity) : 0;

  /// What the purchaser is settled on: what was weighed, less the sacks.
  ///
  /// Floored at zero. A bag can be entered as light as 0.1 kg, so a handful of
  /// near-empty ones really can weigh less than the sacks holding them, and a
  /// negative total on screen reads as a bug rather than as an edge case.
  double netWeightOf(PurchaserModel purchaser) {
    final net = purchaser.totalWeight - deductionFor(purchaser);

    return net < 0 ? 0 : net;
  }

  /// The combined net weight of [purchasers].
  ///
  /// Each load is rounded on its own before being added up, because each one is
  /// settled on its own. Two purchasers of four bags deduct 1.4 twice, not the
  /// 2.7 that rounding their eight bags together would give.
  double totalNetWeightOf(Iterable<PurchaserModel> purchasers) =>
      purchasers.fold<double>(0, (sum, p) => sum + netWeightOf(p));

  TarePolicy copyWith({bool? enabled, TareRate? defaultRate}) => TarePolicy(
    enabled: enabled ?? this.enabled,
    defaultRate: defaultRate ?? this.defaultRate,
  );

  @override
  bool operator ==(Object other) =>
      other is TarePolicy &&
      other.enabled == enabled &&
      other.defaultRate == defaultRate;

  @override
  int get hashCode => Object.hash(enabled, defaultRate);

  @override
  String toString() => 'TarePolicy(enabled: $enabled, default: $defaultRate)';
}
