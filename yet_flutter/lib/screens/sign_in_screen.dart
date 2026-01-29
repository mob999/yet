import 'dart:ui';
import 'package:flutter/material.dart';
import '../src/services/config_service.dart';
import '../src/services/auth_service.dart';
import 'main_screen.dart';
import '../main.dart'; // For MyApp restart logic

class SignInScreen extends StatefulWidget {
  final Widget child;
  final AuthService authService;
  final ConfigService configService;

  const SignInScreen({
    super.key,
    required this.child,
    required this.authService,
    required this.configService,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;
  bool _isLoginMode = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authenticated = await widget.authService.isAuthenticated();
    setState(() {
      _isSignedIn = authenticated;
    });
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        await widget.authService.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await widget.authService.register(
          _emailController.text,
          _passwordController.text,
        );
        // Switch to login mode or auto-login
        _isLoginMode = true;
        await widget.authService.login(
          _emailController.text,
          _passwordController.text,
        );
      }
      setState(() => _isSignedIn = true);
      // Navigate to MyGroupsScreen after successful authentication
      if (mounted) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                authService: widget.authService,
                configService: widget.configService,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yet?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),
              // Base URL Config Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    _showBaseUrlDialog(context, widget.configService);
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 16,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'Config Server',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Email Field
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      10,
                      0,
                      0,
                    ), // Prevent label clipping
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '邮箱',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      10,
                      0,
                      0,
                    ), // Prevent label clipping
                    child: TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '密码',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          _isLoginMode ? '登录' : '注册',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle Mode Button
              TextButton(
                onPressed: () {
                  setState(() => _isLoginMode = !_isLoginMode);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLoginMode ? "没有账号？去注册" : "已有账号？去登录",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
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
                // Restart app to apply changes
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  // Trigger cleanup? For now just dialog confirmation.
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Configuration Saved. Please restart the app if issues persist.',
                        ),
                      ),
                    );
                    // Force update auth service for current screen usage if needed
                    // Although a full restart is best, we can just update the instance for the next login attempt
                    AuthService.instance = AuthService(baseUrl: newUrl);
                    // Since we are at SignInScreen, we don't need a heavy restart, just updating the service instance used by future calls is okay.
                    // But widget.authService is final, so this screen holds old reference.
                    // We must restart the app to propagate the new AuthService.
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => MyApp(
                          authService: AuthService(baseUrl: newUrl),
                          configService: configService,
                        ),
                      ),
                      (route) => false,
                    );
                  }
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
