// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      displayName: json['display_name'] as String,
      id: json['id'] as String,
      email: json['email'] as String,
      householdIds: (json['householdIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'display_name': instance.displayName,
      'id': instance.id,
      'email': instance.email,
      'householdIds': instance.householdIds,
    };
