// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  const Token({
    required this.accessToken,
    required this.tokenType,
  });
  
  factory Token.fromJson(Map<String, Object?> json) => _$TokenFromJson(json);
  
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  Map<String, Object?> toJson() => _$TokenToJson(this);
}
