// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_profile_update.g.dart';

@JsonSerializable()
class UserProfileUpdate {
  const UserProfileUpdate({
    this.avatarUrl,
    this.gender,
    this.birthDate,
  });
  
  factory UserProfileUpdate.fromJson(Map<String, Object?> json) => _$UserProfileUpdateFromJson(json);
  
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? gender;
  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;

  Map<String, Object?> toJson() => _$UserProfileUpdateToJson(this);
}
