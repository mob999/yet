// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'action_definition_create.g.dart';

@JsonSerializable()
class ActionDefinitionCreate {
  const ActionDefinitionCreate({
    required this.name,
    this.iconUrl,
    this.inputSchema,
  });
  
  factory ActionDefinitionCreate.fromJson(Map<String, Object?> json) => _$ActionDefinitionCreateFromJson(json);
  
  final String name;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'input_schema')
  final List<dynamic>? inputSchema;

  Map<String, Object?> toJson() => _$ActionDefinitionCreateToJson(this);
}
