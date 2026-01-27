// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionRecord _$ActionRecordFromJson(Map<String, dynamic> json) => ActionRecord(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  groupId: (json['group_id'] as num).toInt(),
  definitionId: (json['definition_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  inputData: json['input_data'],
  occurredAt: json['occurred_at'] == null
      ? null
      : DateTime.parse(json['occurred_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$ActionRecordToJson(ActionRecord instance) =>
    <String, dynamic>{
      'input_data': instance.inputData,
      'occurred_at': instance.occurredAt?.toIso8601String(),
      'id': instance.id,
      'user_id': instance.userId,
      'group_id': instance.groupId,
      'definition_id': instance.definitionId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
