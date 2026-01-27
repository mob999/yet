// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  avatarUrl: json['avatar_url'] as String?,
  gender: json['gender'] as String?,
  birthDate: json['birth_date'] == null
      ? null
      : DateTime.parse(json['birth_date'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'avatar_url': instance.avatarUrl,
      'gender': instance.gender,
      'birth_date': instance.birthDate?.toIso8601String(),
      'id': instance.id,
      'user_id': instance.userId,
    };
