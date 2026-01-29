// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_definition_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionDefinitionUpdate _$ActionDefinitionUpdateFromJson(
  Map<String, dynamic> json,
) => ActionDefinitionUpdate(
  name: json['name'] as String?,
  iconUrl: json['icon_url'] as String?,
  inputSchema: json['input_schema'] as List<dynamic>?,
  targetGroupIds: (json['target_group_ids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$ActionDefinitionUpdateToJson(
  ActionDefinitionUpdate instance,
) => <String, dynamic>{
  'name': instance.name,
  'icon_url': instance.iconUrl,
  'input_schema': instance.inputSchema,
  'target_group_ids': instance.targetGroupIds,
};
