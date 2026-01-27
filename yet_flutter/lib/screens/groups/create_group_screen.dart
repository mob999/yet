import 'package:flutter/material.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/group_service.dart';
import '../../src/utils/error_handler.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  late final GroupService _groupService;

  @override
  void initState() {
    super.initState();
    _groupService = GroupService(AuthService.instance.dio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final group = await _groupService.createGroup(_nameController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "${group.name}" created!')),
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
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createGroup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
