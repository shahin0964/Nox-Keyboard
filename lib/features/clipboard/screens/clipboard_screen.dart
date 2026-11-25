import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/preferences_helper.dart';

class ClipboardScreen extends StatefulWidget {
  const ClipboardScreen({super.key});

  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends State<ClipboardScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  List<String> _pinned = [];
  List<String> _recents = [];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  void _loadClips() {
    setState(() {
      _pinned = _prefs.pinnedClipboard;
      _recents = _prefs.recentClipboard;
    });
  }

  void _showAddClipDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Clipboard'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Paste or type text to save...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final t = controller.text.trim();
                if (t.isNotEmpty) {
                  await _prefs.addClipboardItem(t);
                  _loadClips();
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle_fill),
            onPressed: _showAddClipDialog,
          ),
          if (_recents.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.trash),
              tooltip: 'Clear Unpinned',
              onPressed: () async {
                await _prefs.clearUnpinnedClipboard();
                _loadClips();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clipboard items...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v.trim().toLowerCase()),
            ),
          ),

          Expanded(
            child: (_pinned.isEmpty && _recents.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.doc_on_clipboard, size: 64, color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text('Clipboard history is empty', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 6),
                        const Text('Copied texts and pinned snippets will be stored here', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      if (_pinned.isNotEmpty) ...[
                        _buildSection('Pinned Items (${_pinned.length})'),
                        ..._pinned
                            .where((t) => _filter.isEmpty || t.toLowerCase().contains(_filter))
                            .map((t) => _buildItemTile(t, isPinned: true)),
                      ],
                      if (_recents.isNotEmpty) ...[
                        _buildSection('Recent Items (${_recents.length})'),
                        ..._recents
                            .where((t) => _filter.isEmpty || t.toLowerCase().contains(_filter))
                            .map((t) => _buildItemTile(t, isPinned: false)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildItemTile(String text, {required bool isPinned}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPinned ? Theme.of(context).colorScheme.primary.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        title: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                color: isPinned ? Theme.of(context).colorScheme.primary : Colors.grey,
                size: 20,
              ),
              onPressed: () async {
                await _prefs.togglePinClipboardItem(text);
                _loadClips();
              },
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.delete, color: Colors.grey, size: 20),
              onPressed: () async {
                await _prefs.deleteClipboardItem(text);
                _loadClips();
              },
            ),
          ],
        ),
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to system clipboard!'), duration: Duration(seconds: 1)),
          );
        },
      ),
    );
  }
}
