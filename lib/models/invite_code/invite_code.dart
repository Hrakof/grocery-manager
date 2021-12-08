// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_code.freezed.dart';
part 'invite_code.g.dart';

@freezed
class InviteCode with _$InviteCode {
  factory InviteCode({
    required String value,
    @JsonKey(name: 'household_id')
    required String householdId,
    @JsonKey(name: 'creation_date', toJson: InviteCode._dateTimeToTimestamp, fromJson: InviteCode._timestampToDateTime)
    required DateTime creationDate
  }) = _InviteCode;

  factory InviteCode.fromJson(Map<String, dynamic> json) => _$InviteCodeFromJson(json);

  static Timestamp _dateTimeToTimestamp(DateTime dateTime){
    return Timestamp.fromDate(dateTime);
  }

  static DateTime _timestampToDateTime(Timestamp timestamp){
    return timestamp.toDate();
  }
}