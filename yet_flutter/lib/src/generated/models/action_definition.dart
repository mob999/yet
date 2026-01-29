// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action_input_field.dart';

part 'action_definition.g.dart';

@JsonSerializable()
class ActionDefinition {
  const ActionDefinition({
    required this.name,
    required this.id,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    this.iconUrl,
    this.inputSchema,
    this.deletedAt,
  });
  
  factory ActionDefinition.fromJson(Map<String, Object?> json) => _$ActionDefinitionFromJson(json);
  
  final String name;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'input_schema')
  final List<ActionInputField>? inputSchema;
  final int id;
  @JsonKey(name: 'creator_id')
  final int creatorId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  Map<String, Object?> toJson() => _$ActionDefinitionToJson(this);
}
