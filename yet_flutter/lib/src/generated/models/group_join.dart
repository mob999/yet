// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group_join.g.dart';

@JsonSerializable()
class GroupJoin {
  const GroupJoin({
    required this.inviteCode,
  });
  
  factory GroupJoin.fromJson(Map<String, Object?> json) => _$GroupJoinFromJson(json);
  
  @JsonKey(name: 'invite_code')
  final String inviteCode;

  Map<String, Object?> toJson() => _$GroupJoinToJson(this);
}
