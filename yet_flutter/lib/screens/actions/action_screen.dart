import 'dart:ui';
import 'package:flutter/material.dart';
import '../../src/generated/export.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/action_service.dart';
import '../../src/utils/error_handler.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  late final ActionService _actionService;
  List<ActionDefinition>? _definitions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _actionService = ActionService(AuthService.instance.dio);
    _loadDefinitions();
  }

  Future<void> _loadDefinitions() async {
    try {
      final defs = await _actionService.getDefinitions();
      setState(() {
        _definitions = defs;
        _isLoading = false;
      });
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          '行动',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _definitions == null || _definitions!.isEmpty
          ? Center(
              child: Text(
                '暂无动作，去创建一个？',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemCount: _definitions!.length,
              itemBuilder: (context, index) {
                final def = _definitions![index];
                return _ActionIconNode(definition: def);
              },
            ),
    );
  }
}

class _ActionIconNode extends StatelessWidget {
  final ActionDefinition definition;

  const _ActionIconNode({required this.definition});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Handle action logging
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Center(
                    child:
                        definition.iconUrl != null &&
                            definition.iconUrl!.isNotEmpty
                        ? Image.network(
                            definition.iconUrl!,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.bolt,
                                  color: Colors.white,
                                  size: 32,
                                ),
                          )
                        : const Icon(Icons.bolt, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            definition.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
