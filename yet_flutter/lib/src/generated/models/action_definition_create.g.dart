// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_definition_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionDefinitionCreate _$ActionDefinitionCreateFromJson(
  Map<String, dynamic> json,
) => ActionDefinitionCreate(
  name: json['name'] as String,
  iconUrl: json['icon_url'] as String?,
  inputSchema: json['input_schema'] as List<dynamic>?,
);

Map<String, dynamic> _$ActionDefinitionCreateToJson(
  ActionDefinitionCreate instance,
) => <String, dynamic>{
  'name': instance.name,
  'icon_url': instance.iconUrl,
  'input_schema': instance.inputSchema,
};
