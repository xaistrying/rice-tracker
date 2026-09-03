// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:rice_tracker/domain/models/bag_model.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';

class PurchaserModel {
  PurchaserModel({
    this.id,
    this.name,
    this.listOfRiceBagWeights,
    this.dateAdded,
    this.tareRate,
  });

  /// Final, so that an edit has to go through [copyWith].
  ///
  /// The state compares its purchaser list with a [DeepCollectionEquality],
  /// which falls back to identity for this class, so mutating an instance in
  /// place also changes the previous state's copy of it. The two then compare
  /// equal and the emit is dropped, leaving the screen showing stale data.
  /// That has happened once already; it is a compile error now.
  final String? id;
  final String? name;
  final List<BagModel>? listOfRiceBagWeights;
  final String? dateAdded;

  /// What this purchaser's sacks weigh, if they differ from everyone else's.
  ///
  /// Null means nothing was chosen for them, and the app's default rate is
  /// used instead — see `TarePolicy.rateFor`. Kept nullable rather than
  /// defaulted here so that a record written before the deduction existed and
  /// one deliberately left on the default are the same thing, and both follow
  /// the default when it changes.
  final TareRate? tareRate;

  /// How many bags this purchaser has.
  ///
  /// Derived rather than stored. A persisted copy of a fact that already lives
  /// in [listOfRiceBagWeights] can drift from it, and nothing reconciled the
  /// two on load: the home list and the details header both read the stored
  /// field, so they agreed with each other while both were wrong.
  int get quantity => listOfRiceBagWeights?.length ?? 0;

  /// The combined weight of every bag, in kg.
  double get totalWeight =>
      listOfRiceBagWeights?.fold<double>(
        0.0,
        (sum, bag) => sum + (bag.weight ?? 0),
      ) ??
      0.0;

  PurchaserModel copyWith({
    String? id,
    String? name,
    List<BagModel>? listOfRiceBagWeights,
    String? dateAdded,
    TareRate? tareRate,
  }) => PurchaserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    listOfRiceBagWeights: listOfRiceBagWeights ?? this.listOfRiceBagWeights,
    dateAdded: dateAdded ?? this.dateAdded,
    tareRate: tareRate ?? this.tareRate,
  );

  factory PurchaserModel.fromRawJson(String str) =>
      PurchaserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  /// Stored "quantity" and "totalWeight" are deliberately not read back.
  ///
  /// They are recomputed from the bags instead, so a stored value written by
  /// an older build that disagrees with them is corrected on the next write
  /// rather than trusted forever.
  factory PurchaserModel.fromJson(Map<String, dynamic> json) => PurchaserModel(
    id: json["id"],
    name: json["name"],
    listOfRiceBagWeights: json["listOfRiceBagWeights"] == null
        ? []
        : List<BagModel>.from(
            (json["listOfRiceBagWeights"] as List).map(
              (x) => BagModel.fromJson(x as Map<String, dynamic>),
            ),
          ),
    dateAdded: json["dateAdded"],
    tareRate: _tareRateFromJson(json),
  );

  /// The stored rate, or null unless both halves are there and usable.
  ///
  /// A half-written or zeroed pair falls back to the app default rather than
  /// being trusted: the bags half is a divisor, so a stored 0 would take every
  /// total on the screen to infinity.
  static TareRate? _tareRateFromJson(Map<String, dynamic> json) {
    final bags = json["tareBags"];
    final kgTenths = json["tareKgTenths"];

    if (bags is! int || kgTenths is! int) return null;

    final rate = TareRate(bags: bags, kgTenths: kgTenths);

    return rate.isValid ? rate : null;
  }

  /// Both derived values are still written, so the stored shape is unchanged.
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "listOfRiceBagWeights": listOfRiceBagWeights == null
        ? []
        : List<dynamic>.from(listOfRiceBagWeights!.map((x) => x.toJson())),
    "quantity": quantity,
    "totalWeight": totalWeight,
    "dateAdded": dateAdded,
    "tareBags": tareRate?.bags,
    "tareKgTenths": tareRate?.kgTenths,
  };

  static List<PurchaserModel> fromList(List<dynamic> data) {
    return data
        .map((map) => PurchaserModel.fromJson(map as Map<String, dynamic>))
        .toList();
  }
}
