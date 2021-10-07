import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item extends Equatable{

  final String id;
  final String name;
  final double amount;
  final String? unit;
  final String? description;

  const Item({
    required this.id,
    required this.name,
    required this.amount,
    this.unit,
    this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  List<Object?> get props => [id, name, amount, unit, description];

}