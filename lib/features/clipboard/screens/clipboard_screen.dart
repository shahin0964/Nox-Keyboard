import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/widgets/modern_ui.dart';
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
  List<Map<String, dynamic>> _images = [];
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  Future<void> _loadClips() async {
    await _prefs.reload();
    if (!mounted) return;
    setState(() {
      _pinned = _prefs.pinnedClipboard;
      _recents = _prefs.recentClipboard;
      _images = _prefs.imageClips.where((e) {
        final p = e['path'] as String? ?? '';
        return p.isNotEmpty && File(p).existsSync();
      }).toList();
    });
  }

  void _showAddClipDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          title: const Text('Save Snippet to Clipboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Paste or type text to save...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final t = controller.text.trim();
                if (t.isNotEmpty) {
                  await _prefs.addClipboardItem(t);
                  await _loadClips();
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: 'Clipboard Manager',
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFF00E5FF)),
          onPressed: _showAddClipDialog,
        ),
        if (_recents.isNotEmpty)
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.white70),
            tooltip: 'Clear Unpinned',
            onPressed: () async {
              await _prefs.clearUnpinnedClipboard();
              _loadClips();
            },
          ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: GlassCard(
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search clipboard snippets...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                  prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: Color(0xFF06B6D4)),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _filter = v.trim().toLowerCase()),
              ),
            ),
          ),
          Expanded(
            child: (_pinned.isEmpty && _recents.isEmpty && _images.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.doc_on_clipboard, size: 56, color: Colors.white.withOpacity(0.22)),
                        const SizedBox(height: 12),
                        const Text('Clipboard history is empty', style: TextStyle(fontSize: 15.5, color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(
                          'Copied text, screenshots & pinned snippets appear here',
                          style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.45)),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (_images.isNotEmpty) ...[
                        ModernSectionHeader(
                          title: 'Images & Screenshots (${_images.length})',
                          accentColor: const Color(0xFF00E5FF),
                        ),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final img = _images[i];
                              final path = img['path'] as String;
                              final isPinned = img['pinned'] as bool? ?? false;
                              return Container(
                                width: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isPinned ? const Color(0xFF00E5FF) : Colors.white24,
                                    width: isPinned ? 1.8 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(File(path), fit: BoxFit.cover),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _prefs.togglePinImageClip(path);
                                            _loadClips();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                                              size: 13,
                                              color: isPinned ? const Color(0xFF00E5FF) : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_pinned.isNotEmpty) ...[
                        ModernSectionHeader(title: 'Pinned (${_pinned.length})', accentColor: const Color(0xFF06B6D4)),
                        ..._pinned
                            .where((t) => _filter.isEmpty || t.toLowerCase().contains(_filter))
                            .map((t) => _buildItemTile(t, isPinned: true)),
                        const SizedBox(height: 12),
                      ],
                      if (_recents.isNotEmpty) ...[
                        ModernSectionHeader(title: 'Recent (${_recents.length})', accentColor: const Color(0xFF94A3B8)),
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

  Widget _buildItemTile(String text, {required bool isPinned}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: 16,
        borderColor: isPinned ? const Color(0xFF06B6D4).withOpacity(0.45) : Colors.white.withOpacity(0.08),
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to system clipboard!'), duration: Duration(seconds: 1)),
          );
        },
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            IconButton(
              icon: Icon(
                isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                color: isPinned ? const Color(0xFF06B6D4) : Colors.white54,
                size: 19,
              ),
              onPressed: () async {
                await _prefs.togglePinClipboardItem(text);
                _loadClips();
              },
            ),
            IconButton(
              icon: Icon(CupertinoIcons.delete, color: Colors.white.withOpacity(0.45), size: 19),
              onPressed: () async {
                await _prefs.deleteClipboardItem(text);
                _loadClips();
              },
            ),
          ],
        ),
      ),
    );
  }
}
