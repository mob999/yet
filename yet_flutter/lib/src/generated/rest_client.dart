// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'users/users_client.dart';
import 'groups/groups_client.dart';
import 'actions/actions_client.dart';
import 'fallback/fallback_client.dart';

/// Yet API `v0.1.0`
class RestClient {
  RestClient(
    Dio dio, {
    String? baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  UsersClient? _users;
  GroupsClient? _groups;
  ActionsClient? _actions;
  FallbackClient? _fallback;

  UsersClient get users => _users ??= UsersClient(_dio, baseUrl: _baseUrl);

  GroupsClient get groups => _groups ??= GroupsClient(_dio, baseUrl: _baseUrl);

  ActionsClient get actions => _actions ??= ActionsClient(_dio, baseUrl: _baseUrl);

  FallbackClient get fallback => _fallback ??= FallbackClient(_dio, baseUrl: _baseUrl);
}
