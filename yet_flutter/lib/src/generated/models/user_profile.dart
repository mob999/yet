// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  const UserProfile({
    required this.id,
    required this.userId,
    this.avatarUrl,
    this.gender,
    this.birthDate,
  });
  
  factory UserProfile.fromJson(Map<String, Object?> json) => _$UserProfileFromJson(json);
  
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? gender;
  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;

  Map<String, Object?> toJson() => _$UserProfileToJson(this);
}
