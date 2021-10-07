import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'household.g.dart';

@JsonSerializable()
class Household extends Equatable{

  final String id;
  final String name;

  const Household({
    required this.name,
    required this.id,
  });

  factory Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdToJson(this);

  @override
  List<Object?> get props => [id, name];

}