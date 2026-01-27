// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionDefinition _$ActionDefinitionFromJson(Map<String, dynamic> json) =>
    ActionDefinition(
      name: json['name'] as String,
      id: (json['id'] as num).toInt(),
      creatorId: (json['creator_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      iconUrl: json['icon_url'] as String?,
      inputSchema: json['input_schema'] as List<dynamic>?,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$ActionDefinitionToJson(ActionDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon_url': instance.iconUrl,
      'input_schema': instance.inputSchema,
      'id': instance.id,
      'creator_id': instance.creatorId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
