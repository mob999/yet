import 'package:flutter/material.dart';
import '../../src/services/config_service.dart';

class ServerConfigScreen extends StatefulWidget {
  final ConfigService configService;

  const ServerConfigScreen({super.key, required this.configService});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  late List<ApiEnvironment> _environments;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _environments = widget.configService.environments;
    });
  }

  Future<void> _selectEnvironment(int index) async {
    await widget.configService.selectEnvironment(index);
    _loadData();
    if (mounted) {
      final env = _environments[index];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已切换至: ${env.name}')),
      );
    }
  }

  Future<void> _deleteEnvironment(int index) async {
    final env = _environments[index];
    if (env.isSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法删除当前选中的环境')),
      );
      return;
    }

    await widget.configService.deleteEnvironment(index);
    _loadData();
  }

  Future<void> _showAddEditDialog([int? index]) async {
    ApiEnvironment? env;
    if (index != null) {
      env = _environments[index];
    }

    final nameCtrl = TextEditingController(text: env?.name);
    final urlCtrl = TextEditingController(text: env?.baseUrl);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(env == null ? '添加环境' : '编辑环境'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: '环境名称',
                hintText: 'Example: Local Dev',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'API 地址',
                hintText: 'http://192.168.1.5:8000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final url = urlCtrl.text.trim();

              if (name.isEmpty || url.isEmpty) return;

              if (index == null) {
                // Create
                await widget.configService.addEnvironment(name, url);
              } else {
                // Update
                await widget.configService.updateEnvironment(index, name, url);
              }

              if (context.mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _environments.length,
        itemBuilder: (context, index) {
          final env = _environments[index];
          return Dismissible(
            key: Key('${env.name}_${env.baseUrl}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (env.isSelected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('无法删除当前选中的环境')),
                );
                return false;
              }
              return true;
            },
            onDismissed: (direction) => _deleteEnvironment(index),
            child: ListTile(
              leading: env.isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              title: Text(
                env.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(env.baseUrl),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showAddEditDialog(index),
              ),
              onTap: () => _selectEnvironment(index),
            ),
          );
        },
      ),
    );
  }
}
