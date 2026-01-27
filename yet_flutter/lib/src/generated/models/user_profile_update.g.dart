// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileUpdate _$UserProfileUpdateFromJson(Map<String, dynamic> json) =>
    UserProfileUpdate(
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] == null
          ? null
          : DateTime.parse(json['birth_date'] as String),
    );

Map<String, dynamic> _$UserProfileUpdateToJson(UserProfileUpdate instance) =>
    <String, dynamic>{
      'avatar_url': instance.avatarUrl,
      'gender': instance.gender,
      'birth_date': instance.birthDate?.toIso8601String(),
    };
