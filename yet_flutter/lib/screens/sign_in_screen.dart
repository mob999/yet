import 'package:flutter/material.dart';
import '../src/services/auth_service.dart';
import 'groups/my_groups_screen.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  final AuthService authService;

  const SignInScreen({
    super.key,
    required this.child,
    required this.authService,
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyGroupsScreen()),
        );
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Yet?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLoginMode ? '登录' : '注册'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() => _isLoginMode = !_isLoginMode);
                },
                child: Text(
                  _isLoginMode ? "没有账号？去注册" : "已有账号？去登录",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
