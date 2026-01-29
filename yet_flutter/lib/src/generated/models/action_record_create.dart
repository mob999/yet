// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'action_record_create.g.dart';

@JsonSerializable()
class ActionRecordCreate {
  const ActionRecordCreate({
    required this.definitionId,
    this.inputData,
    this.occurredAt,
  });
  
  factory ActionRecordCreate.fromJson(Map<String, Object?> json) => _$ActionRecordCreateFromJson(json);
  
  @JsonKey(name: 'input_data')
  final dynamic inputData;
  @JsonKey(name: 'occurred_at')
  final DateTime? occurredAt;
  @JsonKey(name: 'definition_id')
  final int definitionId;

  Map<String, Object?> toJson() => _$ActionRecordCreateToJson(this);
}
