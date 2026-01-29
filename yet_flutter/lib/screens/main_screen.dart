import 'dart:ui';
import 'package:flutter/material.dart';
import '../src/services/config_service.dart';
import '../src/services/auth_service.dart';
import 'actions/action_screen.dart';
import 'groups/my_groups_screen.dart';

class MainScreen extends StatefulWidget {
  final AuthService authService;
  final ConfigService configService;

  const MainScreen({
    super.key,
    required this.authService,
    required this.configService,
  });

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
      _SettingsScreen(
        authService: widget.authService,
        configService: widget.configService,
      ),
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
  final ConfigService configService;

  const _SettingsScreen({
    required this.authService,
    required this.configService,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
            const SizedBox(height: 48),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text(
                'API Base URL',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                configService.baseUrl,
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: const Icon(Icons.edit, color: Colors.white70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white10),
              ),
              tileColor: Colors.white.withOpacity(0.05),
              onTap: () {
                _showBaseUrlDialog(context, configService);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('退出登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBaseUrlDialog(BuildContext context, ConfigService configService) {
    final controller = TextEditingController(text: configService.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set API Base URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'http://192.168.1.x:8000',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                await configService.setBaseUrl(newUrl);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Saved! Please restart app or re-login if needed.',
                      ),
                    ),
                  );
                  // Since we are in Settings, we might want to restart to apply globally or just update service
                  // Ideally, trigger a full app restart or navigate to Splash/Main
                  // For now, let's just leave it as saved.
                  // Updating the global instance:
                  AuthService.instance = AuthService(baseUrl: newUrl);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
