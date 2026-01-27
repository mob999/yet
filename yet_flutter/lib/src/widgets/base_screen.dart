import 'package:flutter/material.dart';
import '../../screens/groups/my_groups_screen.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? floatingActionButton;

  const BaseScreen({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Yet App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('My Groups'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to My Groups if not already there
                // For simplified navigation, we can just pushReplacement
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyGroupsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Implement logout logic here if needed, or just clear token
                // For now just pop
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
