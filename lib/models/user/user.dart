import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable{

  @JsonKey(name: 'display_name')
  final String displayName;
  final String id;
  final String email;
  final List<String> householdIds;

  const User({
    required this.displayName,
    required this.id,
    required this.email,
    required this.householdIds,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, displayName, email, householdIds];

}