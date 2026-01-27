// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/action_definition.dart';
import '../models/action_definition_create.dart';
import '../models/action_record.dart';
import '../models/action_record_create.dart';

part 'actions_client.g.dart';

@RestApi()
abstract class ActionsClient {
  factory ActionsClient(Dio dio, {String? baseUrl}) = _ActionsClient;

  /// Get Definitions
  @GET('/actions/definitions')
  Future<List<ActionDefinition>> getDefinitionsActionsDefinitionsGet();

  /// Create Definition
  @POST('/actions/definitions')
  Future<ActionDefinition> createDefinitionActionsDefinitionsPost({
    @Body() required ActionDefinitionCreate body,
  });

  /// Get My Records
  @GET('/actions/records')
  Future<List<ActionRecord>> getMyRecordsActionsRecordsGet();

  /// Create Record
  @POST('/actions/records')
  Future<ActionRecord> createRecordActionsRecordsPost({
    @Body() required ActionRecordCreate body,
  });
}
