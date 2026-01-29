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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showActionDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _definitions == null || _definitions!.isEmpty
          ? Center(
              child: TextButton(
                onPressed: () => _showActionDialog(),
                child: Text(
                  '暂无动作，点击创建',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
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
                return _ActionIconNode(
                  definition: def,
                  onLongPress: () => _showActionDialog(definition: def),
                );
              },
            ),
    );
  }

  Future<void> _showActionDialog({ActionDefinition? definition}) async {
    await showDialog(
      context: context,
      builder: (context) => _ActionEditorDialog(
        definition: definition,
        onSave: (name, schema) => _saveAction(name, schema, definition),
      ),
    );
  }

  Future<void> _saveAction(
    String name,
    List<ActionInputField> schema,
    ActionDefinition? existing,
  ) async {
    setState(() => _isLoading = true);
    try {
      if (existing != null) {
        // Update
        final updateBody = ActionDefinitionUpdate(
          name: name,
          inputSchema: schema,
        );
        await _actionService.updateDefinition(existing.id, updateBody);
      } else {
        // Create
        final createBody = ActionDefinitionCreate(
          name: name,
          inputSchema: schema,
          targetGroupIds: [],
        );
        await _actionService.createDefinition(createBody);
      }
      await _loadDefinitions(); // Refresh
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
        setState(() => _isLoading = false);
      }
    }
  }
}

class _ActionEditorDialog extends StatefulWidget {
  final ActionDefinition? definition;
  final Function(String name, List<ActionInputField> schema) onSave;

  const _ActionEditorDialog({this.definition, required this.onSave});

  @override
  State<_ActionEditorDialog> createState() => _ActionEditorDialogState();
}

class _ActionEditorDialogState extends State<_ActionEditorDialog> {
  late TextEditingController _nameController;
  late List<_SchemaItem> _schemaItems;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.definition?.name);
    _schemaItems =
        widget.definition?.inputSchema
            ?.map((e) => _SchemaItem.fromField(e))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var item in _schemaItems) {
      item.keyController.dispose();
      item.labelController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.all(24),
      title: Text(
        widget.definition != null ? '编辑动作' : '创建动作',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                hint: '动作名称',
                autoFocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '输入列表',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.blueAccent,
                    ),
                    onPressed: _addInput,
                    tooltip: '添加输入',
                  ),
                ],
              ),
              if (_schemaItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '暂无输入项',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ..._schemaItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildSchemaItem(index, item);
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: _handleSave,
          child: const Text(
            '保存',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSchemaItem(int index, _SchemaItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: item.keyController,
                  hint: '输入名称 (Key)',
                  isDense: true,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => _removeInput(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ActionInputType>(
            value: item.type,
            dropdownColor: const Color(0xFF2C2C2C),
            decoration: _inputDecoration(hint: '类型'),
            hint: const Text('类型', style: TextStyle(color: Colors.white54)),
            style: const TextStyle(color: Colors.white),
            items: ActionInputType.$valuesDefined.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(t.toString().split('.').last.toUpperCase()),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => item.type = v);
            },
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: item.labelController,
            hint: '备注 (Label) - 选填',
            isDense: true,
          ),
        ],
      ),
    );
  }

  void _addInput() {
    setState(() {
      _schemaItems.add(_SchemaItem());
    });
  }

  void _removeInput(int index) {
    setState(() {
      _schemaItems.removeAt(index);
    });
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final schema = _schemaItems
        .map((e) {
          final key = e.keyController.text.trim();
          if (key.isEmpty) return null; // Skip empty keys
          return ActionInputField(
            key: key,
            type: e.type ?? ActionInputType.text,
            label: e.labelController.text.trim().isEmpty
                ? key
                : e.labelController.text.trim(),
          );
        })
        .whereType<ActionInputField>()
        .toList();

    widget.onSave(name, schema);
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool autoFocus = false,
    bool isDense = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.blueAccent,
      autofocus: autoFocus,
      decoration: _inputDecoration(hint: hint, isDense: isDense),
    );
  }

  InputDecoration _inputDecoration({String? hint, bool isDense = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      isDense: isDense,
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: isDense
          ? const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}

class _SchemaItem {
  final TextEditingController keyController;
  final TextEditingController labelController;
  ActionInputType? type;

  _SchemaItem({
    String key = '',
    String label = '',
    this.type,
  }) : keyController = TextEditingController(text: key),
       labelController = TextEditingController(text: label);

  factory _SchemaItem.fromField(ActionInputField field) {
    return _SchemaItem(
      key: field.key,
      label: field.label,
      type: field.type,
    );
  }
}

class _ActionIconNode extends StatelessWidget {
  final ActionDefinition definition;
  final VoidCallback? onLongPress;

  const _ActionIconNode({required this.definition, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Handle action logging
      },
      onLongPress: onLongPress,
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
