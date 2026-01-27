// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group_create.g.dart';

@JsonSerializable()
class GroupCreate {
  const GroupCreate({
    required this.name,
  });
  
  factory GroupCreate.fromJson(Map<String, Object?> json) => _$GroupCreateFromJson(json);
  
  final String name;

  Map<String, Object?> toJson() => _$GroupCreateToJson(this);
}
