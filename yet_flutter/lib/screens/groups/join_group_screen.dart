import 'package:flutter/material.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/group_service.dart';
import '../../src/utils/error_handler.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  late final GroupService _groupService;

  @override
  void initState() {
    super.initState();
    _groupService = GroupService(AuthService.instance.dio);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final group = await _groupService.joinGroup(_codeController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined group "${group.name}"!')),
        );
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Invite Code',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the 8-character code',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _joinGroup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Join'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
