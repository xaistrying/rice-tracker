// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:rice_tracker/domain/models/bag_model.dart';

class PurchaserModel {
  String? id;
  String? name;
  List<BagModel>? listOfRiceBagWeights;
  int? quantity;
  double? totalWeight;
  String? dateAdded;

  PurchaserModel({
    this.id,
    this.name,
    this.listOfRiceBagWeights,
    this.quantity,
    this.totalWeight,
    this.dateAdded,
  });

  PurchaserModel copyWith({
    String? id,
    String? name,
    List<BagModel>? listOfRiceBagWeights,
    int? quantity,
    double? totalWeight,
    String? dateAdded,
  }) => PurchaserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    listOfRiceBagWeights: listOfRiceBagWeights ?? this.listOfRiceBagWeights,
    quantity: quantity ?? this.quantity,
    totalWeight: totalWeight ?? this.totalWeight,
    dateAdded: dateAdded ?? this.dateAdded,
  );

  factory PurchaserModel.fromRawJson(String str) =>
      PurchaserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

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
    quantity: json["quantity"],
    totalWeight: json["totalWeight"]?.toDouble(),
    dateAdded: json["dateAdded"],
  );

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
