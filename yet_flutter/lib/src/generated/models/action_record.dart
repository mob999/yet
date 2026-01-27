// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'action_record.g.dart';

@JsonSerializable()
class ActionRecord {
  const ActionRecord({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.definitionId,
    required this.createdAt,
    required this.updatedAt,
    this.inputData,
    this.occurredAt,
    this.deletedAt,
  });
  
  factory ActionRecord.fromJson(Map<String, Object?> json) => _$ActionRecordFromJson(json);
  
  @JsonKey(name: 'input_data')
  final dynamic inputData;
  @JsonKey(name: 'occurred_at')
  final DateTime? occurredAt;
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'group_id')
  final int groupId;
  @JsonKey(name: 'definition_id')
  final int definitionId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  Map<String, Object?> toJson() => _$ActionRecordToJson(this);
}
