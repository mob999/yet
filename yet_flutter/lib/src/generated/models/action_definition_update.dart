// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action_input_field.dart';

part 'action_definition_update.g.dart';

@JsonSerializable()
class ActionDefinitionUpdate {
  const ActionDefinitionUpdate({
    this.name,
    this.iconUrl,
    this.inputSchema,
    this.targetGroupIds,
  });
  
  factory ActionDefinitionUpdate.fromJson(Map<String, Object?> json) => _$ActionDefinitionUpdateFromJson(json);
  
  final String? name;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @JsonKey(name: 'input_schema')
  final List<ActionInputField>? inputSchema;
  @JsonKey(name: 'target_group_ids')
  final List<int>? targetGroupIds;

  Map<String, Object?> toJson() => _$ActionDefinitionUpdateToJson(this);
}
