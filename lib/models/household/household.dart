import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'household.g.dart';

@JsonSerializable()
class Household extends Equatable{

  final String id;
  final String name;
  @JsonKey(name: 'owner_uid')
  final String ownerUid;
  @JsonKey(name: 'member_uids')
  final List<String> memberUids;

  const Household({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.memberUids,
  });

  factory Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdToJson(this);

  @override
  List<Object?> get props => [id, name, ownerUid, memberUids];

  Household copyWith({
    String? id,
    String? name,
    String? ownerUid,
    List<String>? memberUids,
  }){
    return Household(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerUid: ownerUid ?? this.ownerUid,
      memberUids: memberUids ?? this.memberUids
    );
  }

}