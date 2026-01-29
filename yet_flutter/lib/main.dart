import 'package:flutter/material.dart';
import 'src/services/config_service.dart';
import 'src/services/auth_service.dart';
import 'screens/sign_in_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use 10.0.2.2 for Android emulator to access localhost,
  // or use your local IP if testing on physical device.
  final configService = await ConfigService.init();
  final baseUrl = configService.baseUrl;

  final authService = AuthService(baseUrl: baseUrl);
  AuthService.instance = authService;

  runApp(MyApp(authService: authService, configService: configService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ConfigService configService;

  const MyApp({
    super.key,
    required this.authService,
    required this.configService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yet?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: SignInScreen(
        authService: authService,
        configService: configService, // Pass config service
        child: HelloWorldScreen(
          authService: authService,
          configService: configService,
        ),
      ),
    );
  }
}

class HelloWorldScreen extends StatelessWidget {
  final AuthService authService;
  final ConfigService configService;

  const HelloWorldScreen({
    super.key,
    required this.authService,
    required this.configService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yet?'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              // In a real app, use a proper Navigator for state management
              // For now, simple restart app feel:
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MyApp(
                      authService: authService,
                      configService: configService,
                    ),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_iphone_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Authenticated!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You are now logged in via FastAPI.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('API Base URL'),
                  subtitle: Text(configService.baseUrl),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    _showBaseUrlDialog(context, configService);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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
                // Restart app to apply changes
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => MyApp(
                        authService: AuthService(
                          baseUrl: newUrl,
                        ), // Re-init auth service
                        configService: configService,
                      ),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text('Save & Restart'),
          ),
        ],
      ),
    );
  }
}
