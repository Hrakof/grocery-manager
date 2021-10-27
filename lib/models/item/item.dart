import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item extends Equatable{

  final String id;
  final String name;
  @JsonKey(name: 'icon_data', toJson: _iconDataToJson, fromJson: _iconDataFromJson)
  final IconData iconData;
  final double? amount;
  final String? unit;
  final String? description;

  const Item({
    required this.id,
    required this.name,
    required this.iconData,
    this.amount,
    this.unit,
    this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  List<Object?> get props => [id, name, amount, iconData, unit, description];

  static Map<String, dynamic>? _iconDataToJson(IconData iconData){
    return serializeIcon(iconData);
  }

  static IconData _iconDataFromJson(Map<String, dynamic> map){
    return deserializeIcon(map) ?? Icons.help;
  }
}