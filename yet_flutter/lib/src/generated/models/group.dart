// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  const Group({
    required this.name,
    required this.id,
    required this.inviteCode,
    required this.creatorId,
    required this.createdAt,
  });
  
  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
  
  final String name;
  final int id;
  @JsonKey(name: 'invite_code')
  final String inviteCode;
  @JsonKey(name: 'creator_id')
  final int creatorId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$GroupToJson(this);
}
