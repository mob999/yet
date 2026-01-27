// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'body_login_users_login_post.g.dart';

@JsonSerializable()
class BodyLoginUsersLoginPost {
  const BodyLoginUsersLoginPost({
    required this.username,
    required this.password,
    this.scope = '',
    this.grantType,
    this.clientId,
    this.clientSecret,
  });
  
  factory BodyLoginUsersLoginPost.fromJson(Map<String, Object?> json) => _$BodyLoginUsersLoginPostFromJson(json);
  
  @JsonKey(name: 'grant_type')
  final String? grantType;
  final String username;
  final String password;
  final String scope;
  @JsonKey(name: 'client_id')
  final String? clientId;
  @JsonKey(name: 'client_secret')
  final String? clientSecret;

  Map<String, Object?> toJson() => _$BodyLoginUsersLoginPostToJson(this);
}
