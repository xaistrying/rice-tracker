// Dart imports:
import 'dart:convert';

class BagModel {
  BagModel({this.id, this.weight});

  /// Final, so that an edit has to go through [copyWith]. See the note on
  /// PurchaserModel's fields for why mutating one in place breaks the state.
  final String? id;
  final double? weight;

  BagModel copyWith({String? id, double? weight}) =>
      BagModel(id: id ?? this.id, weight: weight ?? this.weight);

  factory BagModel.fromRawJson(String str) =>
      BagModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BagModel.fromJson(Map<String, dynamic> json) =>
      BagModel(id: json["id"], weight: json["weight"]?.toDouble());

  Map<String, dynamic> toJson() => {"id": id, "weight": weight};
}
