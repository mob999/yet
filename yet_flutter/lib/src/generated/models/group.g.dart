// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
  inviteCode: json['invite_code'] as String,
  creatorId: (json['creator_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'name': instance.name,
  'id': instance.id,
  'invite_code': instance.inviteCode,
  'creator_id': instance.creatorId,
  'created_at': instance.createdAt.toIso8601String(),
};
