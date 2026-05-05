// Dart imports:
import 'dart:convert';

class BagModel {
  String? id;
  double? weight;

  BagModel({this.id, this.weight});

  BagModel copyWith({String? id, double? weight}) =>
      BagModel(id: id ?? this.id, weight: weight ?? this.weight);

  factory BagModel.fromRawJson(String str) =>
      BagModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BagModel.fromJson(Map<String, dynamic> json) =>
      BagModel(id: json["id"], weight: json["weight"]?.toDouble());

  Map<String, dynamic> toJson() => {"id": id, "weight": weight};
}
