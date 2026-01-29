import 'package:flutter/material.dart';
import 'src/services/config_service.dart';
import 'src/services/auth_service.dart';
import 'screens/sign_in_screen.dart';
import 'screens/main_screen.dart';
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
        child: MainScreen(
          authService: authService,
          configService: configService,
        ),
      ),
    );
  }
}
