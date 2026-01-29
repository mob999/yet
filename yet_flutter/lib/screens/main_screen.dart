import 'dart:ui';
import 'package:flutter/material.dart';
import '../src/services/auth_service.dart';
import 'actions/action_screen.dart';
import 'groups/my_groups_screen.dart';

class MainScreen extends StatefulWidget {
  final AuthService authService;

  const MainScreen({super.key, required this.authService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to 'Action' (index 1)

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MyGroupsScreen(), // Re-using existing screen for Groups
      const ActionScreen(), // Using the new ActionScreen
      _SettingsScreen(authService: widget.authService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_outlined),
                  activeIcon: Icon(Icons.group),
                  label: '小组',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_outlined),
                  activeIcon: Icon(Icons.play_circle_filled),
                  label: '行动',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: '设置',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  final AuthService authService;

  const _SettingsScreen({required this.authService});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '设置',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await authService.logout();
              // Navigate back to login screen properly
              // Note: In a real app, use GoRouter or similar for auth state listening
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
                // Or if '/' is not set up contextually:
                // Navigator.of(context).pushAndRemoveUntil(...)
                // But since we are inside MainScreen which is pushed from SignInScreen...
                // Actually easier to just pop or restart.
                // For now, let's use the same logic as before:
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                inherit: false,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}
