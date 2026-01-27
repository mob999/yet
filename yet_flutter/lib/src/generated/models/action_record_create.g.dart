// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_record_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionRecordCreate _$ActionRecordCreateFromJson(Map<String, dynamic> json) =>
    ActionRecordCreate(
      definitionId: (json['definition_id'] as num).toInt(),
      groupId: (json['group_id'] as num).toInt(),
      inputData: json['input_data'],
      occurredAt: json['occurred_at'] == null
          ? null
          : DateTime.parse(json['occurred_at'] as String),
    );

Map<String, dynamic> _$ActionRecordCreateToJson(ActionRecordCreate instance) =>
    <String, dynamic>{
      'input_data': instance.inputData,
      'occurred_at': instance.occurredAt?.toIso8601String(),
      'definition_id': instance.definitionId,
      'group_id': instance.groupId,
    };
