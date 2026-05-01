import 'dart:convert';

class PurchaserModel {
  String? name;
  List<double>? listOfRiceBagWeights;
  int? quantity;
  double? totalWeight;

  PurchaserModel({
    this.name,
    this.listOfRiceBagWeights,
    this.quantity,
    this.totalWeight,
  });

  PurchaserModel copyWith({
    String? name,
    List<double>? listOfRiceBagWeights,
    int? quantity,
    double? totalWeight,
  }) => PurchaserModel(
    name: name ?? this.name,
    listOfRiceBagWeights: listOfRiceBagWeights ?? this.listOfRiceBagWeights,
    quantity: quantity ?? this.quantity,
    totalWeight: totalWeight ?? this.totalWeight,
  );

  factory PurchaserModel.fromRawJson(String str) =>
      PurchaserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PurchaserModel.fromJson(Map<String, dynamic> json) => PurchaserModel(
    name: json["name"],
    listOfRiceBagWeights: json["listOfRiceBagWeights"] == null
        ? []
        : List<double>.from(
            json["listOfRiceBagWeights"]!.map((x) => x?.toDouble()),
          ),
    quantity: json["quantity"],
    totalWeight: json["totalWeight"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "listOfRiceBagWeights": listOfRiceBagWeights == null
        ? []
        : List<dynamic>.from(listOfRiceBagWeights!.map((x) => x)),
    "quantity": quantity,
    "totalWeight": totalWeight,
  };
}
