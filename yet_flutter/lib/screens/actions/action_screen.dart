import 'package:flutter/material.dart';
import '../../src/generated/export.dart';
import '../../src/services/auth_service.dart';
import '../../src/services/action_service.dart';
import '../../src/services/group_service.dart';
import '../../src/utils/error_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../src/services/file_service.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  late final ActionService _actionService;
  late final GroupService _groupService;
  List<ActionDefinition>? _definitions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final dio = AuthService.instance.dio;
    _actionService = ActionService(dio);
    _groupService = GroupService(dio);
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

  Future<void> _handleActionTap(ActionDefinition def) async {
    // Validate target groups
    if (def.targetGroupIds == null || def.targetGroupIds!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('记录失败：该动作未关联任何目标小组'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (def.inputSchema == null || def.inputSchema!.isEmpty) {
      // Direct trigger
      await _triggerAction(def, {});
    } else {
      // Show input dialog
      await showDialog(
        context: context,
        builder: (context) => _ActionInputDialog(
          definition: def,
          onSubmit: (inputs) => _triggerAction(def, inputs),
        ),
      );
    }
  }

  Future<void> _triggerAction(
    ActionDefinition def,
    Map<String, dynamic> inputs,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('触发动作: ${def.name}...'),
          duration: const Duration(seconds: 1),
        ),
      );

      final record = ActionRecordCreate(
        definitionId: def.id,
        inputData: inputs,
        occurredAt: DateTime.now(),
      );

      await _actionService.createRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('动作 "${def.name}" 记录成功!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('行动'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showActionDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : _definitions == null || _definitions!.isEmpty
          ? Center(
              child: TextButton(
                onPressed: () => _showActionDialog(),
                child: Text(
                  '暂无动作，点击创建',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
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
                  onTap: () => _handleActionTap(def),
                  onLongPress: () => _showActionDialog(definition: def),
                );
              },
            ),
    );
  }

  Future<void> _showActionDialog({ActionDefinition? definition}) async {
    await showDialog(
      context: context,
      builder: (context) => ActionEditorDialog(
        definition: definition,
        groupService: _groupService,
        fileService: FileService(AuthService.instance.dio),
        onSave: (name, schema, targetGroups, iconUrl) =>
            _saveAction(name, schema, targetGroups, iconUrl, definition),
      ),
    );
  }

  Future<void> _saveAction(
    String name,
    List<ActionInputField> schema,
    List<int> targetGroups,
    String? iconUrl,
    ActionDefinition? existing,
  ) async {
    setState(() => _isLoading = true);
    try {
      if (existing != null) {
        // Update
        final updateBody = ActionDefinitionUpdate(
          name: name,
          inputSchema: schema,
          targetGroupIds: targetGroups,
          iconUrl: iconUrl,
        );
        await _actionService.updateDefinition(existing.id, updateBody);
      } else {
        // Create
        final createBody = ActionDefinitionCreate(
          name: name,
          inputSchema: schema,
          targetGroupIds: targetGroups,
          iconUrl: iconUrl,
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

class ActionEditorDialog extends StatefulWidget {
  final ActionDefinition? definition;
  final GroupService groupService;
  final FileService fileService;
  final Function(
    String name,
    List<ActionInputField> schema,
    List<int> targetGroups,
    String? iconUrl,
  )
  onSave;

  const ActionEditorDialog({
    super.key,
    this.definition,
    required this.groupService,
    required this.fileService,
    required this.onSave,
  });

  @override
  State<ActionEditorDialog> createState() => _ActionEditorDialogState();
}

class _ActionEditorDialogState extends State<ActionEditorDialog> {
  late TextEditingController _nameController;
  late List<_SchemaItem> _schemaItems;
  List<Group> _myGroups = [];
  List<int> _selectedGroupIds = [];
  bool _isLoadingGroups = true;
  
  // Icon State
  bool _isImageMode = false;
  final TextEditingController _emojiController = TextEditingController();
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.definition?.name);
    _schemaItems =
        widget.definition?.inputSchema
            ?.map((e) => _SchemaItem.fromField(e))
            .toList() ??
        [];
    _selectedGroupIds = List.from(widget.definition?.targetGroupIds ?? []);
    
    // Init Icon State
    final existingIcon = widget.definition?.iconUrl;
    if (existingIcon != null && (existingIcon.startsWith('http') || existingIcon.startsWith('/'))) {
      _isImageMode = true;
      _uploadedImageUrl = existingIcon;
    } else {
      _isImageMode = false;
      _emojiController.text = existingIcon ?? '';
    }

    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await widget.groupService.getMyGroups();
      if (mounted) {
        setState(() {
          _myGroups = groups;
          _isLoadingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    for (var item in _schemaItems) {
      item.keyController.dispose();
      item.labelController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.definition != null ? '编辑动作' : '创建新动作',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "基本信息",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      style: theme.textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: '给动作起个名字，如“打卡”',
                        labelText: '动作名称',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),
                    
                    // Icon Selection
                    Text(
                      "图标",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Toggle
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('Emoji')),
                            ButtonSegment(value: true, label: Text('图片')),
                          ],
                          selected: {_isImageMode},
                          onSelectionChanged: (s) {
                            setState(() => _isImageMode = s.first);
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Input Area
                        Expanded(
                          child: _isImageMode 
                              ? _buildImagePicker(theme) 
                              : TextField(
                                  controller: _emojiController,
                                  decoration: const InputDecoration(
                                    hintText: '输入Emoji (如 💊)',
                                    labelText: 'Emoji 图标',
                                    isDense: true,
                                  ),
                                  maxLength: 2, // Limit length
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "广播目标",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingGroups)
                      Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else if (_myGroups.isEmpty)
                      Text(
                        '您还没有加入任何小组',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _myGroups.map((group) {
                          final isSelected = _selectedGroupIds.contains(
                            group.id,
                          );
                          return FilterChip(
                            label: Text(group.name),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedGroupIds.add(group.id);
                                } else {
                                  _selectedGroupIds.remove(group.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "输入字段",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addInput,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("添加字段"),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_schemaItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.1),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Text(
                          '暂无输入字段。用户仅需点击即可触发动作。',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ..._schemaItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildSchemaItem(index, item, theme);
                    }),
                  ],
                ),
              ),
            ),

            // Footer Action
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text(
                    '保存动作',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemaItem(int index, _SchemaItem item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: item.keyController,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Key (ID)',
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    hintText: '例如: amount',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<ActionInputType>(
                  value: item.type,
                  dropdownColor: theme.colorScheme.surfaceContainerHighest,
                  decoration: const InputDecoration(
                    labelText: '类型',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: ActionInputType.$valuesDefined.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(
                        t.toString().split('.').last.toUpperCase(),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => item.type = v);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: theme.colorScheme.error,
                onPressed: () => _removeInput(index),
                tooltip: '删除',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: item.labelController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: '显示名称 (Label)',
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
              hintText: '例如: 金额',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
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

    String? finalIconUrl;
    if (_isImageMode) {
      finalIconUrl = _uploadedImageUrl;
    } else {
      finalIconUrl = _emojiController.text.trim();
    }

    widget.onSave(name, schema, _selectedGroupIds, finalIconUrl);
    Navigator.pop(context);
  }

  Widget _buildImagePicker(ThemeData theme) {
    return Row(
      children: [
        if (_uploadedImageUrl != null)
           Padding(
             padding: const EdgeInsets.only(right: 8.0),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(8),
               child: Image.network(
                  _uploadedImageUrl!.startsWith('/') ? "${AuthService.instance.dio.options.baseUrl.replaceAll(RegExp(r'/$'), '')}$_uploadedImageUrl" : _uploadedImageUrl!,
                  width: 40, 
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const Icon(Icons.error),
               ),
             ),
           ),
        ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickAndUploadImage,
            icon: _isUploading 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.upload, size: 16),
            label: Text(_uploadedImageUrl == null ? "上传图片" : "更换图片"),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512); 
    
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final file = File(image.path);
        final url = await widget.fileService.uploadFile(file);
        if (mounted) {
           setState(() {
             _uploadedImageUrl = url;
             _isUploading = false;
           });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
          setState(() => _isUploading = false);
        }
      }
    }
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
  final VoidCallback? onTap;

  const _ActionIconNode({
    required this.definition,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _buildIcon(definition, theme),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            definition.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
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

  Widget _buildIcon(ActionDefinition def, ThemeData theme) {
    if (def.iconUrl == null || def.iconUrl!.isEmpty) {
      return Icon(Icons.bolt, color: theme.colorScheme.primary, size: 32);
    }

    final url = def.iconUrl!;
    // Check if it looks like a URL
    if (url.startsWith('http') || url.startsWith('/')) {
        try {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url.startsWith('/') ? "${AuthService.instance.dio.options.baseUrl.replaceAll(RegExp(r'/$'), '')}$url" : url,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>  Text(
                url.characters.take(2).toString(), 
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        } catch (_) {
          return Icon(Icons.broken_image, size: 32, color: theme.colorScheme.error);
        }
    }

    // Otherwise treat as Emoji/Text
    return Text(
      url,
      style: const TextStyle(fontSize: 28),
    );
  }
}

class _ActionInputDialog extends StatefulWidget {
  final ActionDefinition definition;
  final Function(Map<String, dynamic>) onSubmit;

  const _ActionInputDialog({
    required this.definition,
    required this.onSubmit,
  });

  @override
  State<_ActionInputDialog> createState() => _ActionInputDialogState();
}

class _ActionInputDialogState extends State<_ActionInputDialog> {
  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.definition.inputSchema ?? []) {
      if (field.type != ActionInputType.image) {
        _controllers[field.key] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    // Collect values
    for (var field in widget.definition.inputSchema ?? []) {
      if (_controllers.containsKey(field.key)) {
        final text = _controllers[field.key]!.text;
        if (field.type == ActionInputType.number) {
          _values[field.key] = num.tryParse(text) ?? 0;
        } else {
          _values[field.key] = text;
        }
      }
    }
    widget.onSubmit(_values);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schema = widget.definition.inputSchema ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.definition.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: schema.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildInputField(field, theme),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '执行',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ActionInputField field, ThemeData theme) {
    if (field.type == ActionInputType.number) {
      return TextField(
        controller: _controllers[field.key],
        keyboardType: TextInputType.number,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
          hintText: '请输入数字',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      );
    } else if (field.type == ActionInputType.text) {
      return TextField(
        controller: _controllers[field.key],
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
          hintText: '请输入内容',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '${field.label} (暂不支持此类型)',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }
  }
}
