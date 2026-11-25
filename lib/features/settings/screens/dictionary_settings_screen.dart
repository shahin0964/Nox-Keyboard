import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/preferences_helper.dart';

class DictionarySettingsScreen extends StatefulWidget {
  const DictionarySettingsScreen({super.key});

  @override
  State<DictionarySettingsScreen> createState() => _DictionarySettingsScreenState();
}

class _DictionarySettingsScreenState extends State<DictionarySettingsScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  List<String> _words = [];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  void _loadDictionary() {
    setState(() {
      _words = _prefs.userDictionary;
    });
  }

  void _showAddWordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Word to Dictionary'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter custom word...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final w = controller.text.trim();
                if (w.isNotEmpty) {
                  await _prefs.addUserWord(w);
                  _loadDictionary();
                }
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter.isEmpty
        ? _words
        : _words.where((w) => w.toLowerCase().contains(_filter.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Dictionary', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle_fill),
            tooltip: 'Add Word',
            onPressed: _showAddWordDialog,
          ),
          if (_words.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.trash),
              tooltip: 'Clear Dictionary',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Dictionary?'),
                    content: const Text('This will delete all your learned and custom added words.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear All')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _prefs.clearUserDictionary();
                  _loadDictionary();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search custom words...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v.trim()),
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.book, size: 64, color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'No custom words yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap + to add custom words or shortcuts',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final word = filtered[index];
                      return ListTile(
                        title: Text(word, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: const Icon(CupertinoIcons.delete, size: 18, color: Colors.grey),
                          onPressed: () async {
                            await _prefs.removeUserWord(word);
                            _loadDictionary();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
