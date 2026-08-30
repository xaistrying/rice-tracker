// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:rice_tracker/domain/models/bag_model.dart';

class PurchaserModel {
  PurchaserModel({
    this.id,
    this.name,
    this.listOfRiceBagWeights,
    this.dateAdded,
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
  }) => PurchaserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    listOfRiceBagWeights: listOfRiceBagWeights ?? this.listOfRiceBagWeights,
    dateAdded: dateAdded ?? this.dateAdded,
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
  );

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
  };

  static List<PurchaserModel> fromList(List<dynamic> data) {
    return data
        .map((map) => PurchaserModel.fromJson(map as Map<String, dynamic>))
        .toList();
  }
}
