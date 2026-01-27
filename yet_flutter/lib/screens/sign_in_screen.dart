import 'package:flutter/material.dart';
// import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  const SignInScreen({super.key, required this.child});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    super.initState();
    // client.auth.authInfoListenable.addListener(_updateSignedInState);
    // _isSignedIn = client.auth.isAuthenticated;
  }

  @override
  void dispose() {
    // client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
    /*
    return _isSignedIn
        ? widget.child
        : Center(
            child: SignInWidget(
              client: client,
              onAuthenticated: () {},
            ),
          );
    */
  }
}
