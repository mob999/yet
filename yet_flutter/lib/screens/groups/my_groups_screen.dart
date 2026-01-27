import 'package:flutter/material.dart';
import '../../src/generated/export.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/group_service.dart';
import '../../src/utils/error_handler.dart';
import '../../src/widgets/base_screen.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  late final GroupService _groupService;
  List<Group>? _groups;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Assuming AuthService provides the authenticated Dio instance
    _groupService = GroupService(AuthService.instance.dio);
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _groupService.getMyGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddGroupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create New Group'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                ).then((_) => _loadGroups());
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Join Existing Group'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinGroupScreen(),
                  ),
                ).then((_) => _loadGroups());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'My Groups',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroupOptions(context),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups == null || _groups!.isEmpty
          ? const Center(child: Text('No groups found. Create or join one!'))
          : ListView.builder(
              itemCount: _groups!.length,
              itemBuilder: (context, index) {
                final group = _groups![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(group.name[0].toUpperCase()),
                    ),
                    title: Text(group.name),
                    subtitle: Text('Invite Code: ${group.inviteCode}'),
                    // onTap: () {
                    //   // Navigate to group detail/actions
                    // },
                  ),
                );
              },
            ),
    );
  }
}
