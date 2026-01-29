// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action_input_type.dart';

part 'action_input_field.g.dart';

@JsonSerializable()
class ActionInputField {
  const ActionInputField({
    required this.key,
    required this.label,
    required this.type,
  });
  
  factory ActionInputField.fromJson(Map<String, Object?> json) => _$ActionInputFieldFromJson(json);
  
  final String key;
  final String label;
  final ActionInputType type;

  Map<String, Object?> toJson() => _$ActionInputFieldToJson(this);
}
