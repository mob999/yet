import 'package:dio/dio.dart';
import '../generated/export.dart';

class GroupService {
  final GroupsClient _client;

  GroupService(Dio dio) : _client = GroupsClient(dio);

  Future<Group> createGroup(String name) async {
    return _client.createGroupGroupsPost(
      body: GroupCreate(name: name),
    );
  }

  Future<Group> joinGroup(String inviteCode) async {
    return _client.joinGroupGroupsJoinPost(
      body: GroupJoin(
        inviteCode: inviteCode,
      ),
    );
  }

  Future<List<Group>> getMyGroups() async {
    return _client.getMyGroupsGroupsMeGet();
  }
}
