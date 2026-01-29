import 'package:dio/dio.dart';
import '../generated/export.dart';

class ActionService {
  final ActionsClient _client;

  ActionService(Dio dio) : _client = ActionsClient(dio);

  Future<List<ActionDefinition>> getDefinitions() async {
    return _client.getDefinitionsActionsDefinitionsGet();
  }

  Future<ActionDefinition> createDefinition(ActionDefinitionCreate body) async {
    return _client.createDefinitionActionsDefinitionsPost(body: body);
  }

  Future<List<ActionRecord>> getRecords() async {
    return _client.getMyRecordsActionsRecordsGet();
  }

  Future<ActionRecord> createRecord(ActionRecordCreate body) async {
    return _client.createRecordActionsRecordsPost(body: body);
  }
}
