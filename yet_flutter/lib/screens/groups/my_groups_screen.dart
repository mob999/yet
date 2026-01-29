import 'package:flutter/material.dart';
import '../../src/generated/export.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/group_service.dart';
import '../../src/utils/error_handler.dart';
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
    return Scaffold(
      backgroundColor: Colors
          .transparent, // Transparent to show MainScreen bg or own dark bg
      appBar: AppBar(
        title: const Text('我的小组', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddGroupOptions(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _groups == null || _groups!.isEmpty
          ? Center(
              child: Text(
                '暂无小组，创建一个吧！',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // Space for BottomNavBar
              itemCount: _groups!.length,
              itemBuilder: (context, index) {
                final group = _groups![index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '邀请码: ${group.inviteCode}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
