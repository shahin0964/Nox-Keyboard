import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../data/preferences_helper.dart';

class ShortcutsScreen extends StatefulWidget {
  const ShortcutsScreen({super.key});

  @override
  State<ShortcutsScreen> createState() => _ShortcutsScreenState();
}

class _ShortcutsScreenState extends State<ShortcutsScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  Map<String, String> _shortcuts = {};
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _loadShortcuts();
  }

  Future<void> _loadShortcuts() async {
    await _prefs.reload();
    if (!mounted) return;
    setState(() {
      _shortcuts = _prefs.customShortcuts;
    });
  }

  void _showAddShortcutDialog({String? existingKey, String? existingValue}) {
    final keyController = TextEditingController(text: existingKey ?? '');
    final valueController = TextEditingController(text: existingValue ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          title: Text(
            existingKey != null ? 'Edit Shortcut' : 'New Keyboard Shortcut',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                autofocus: existingKey == null,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Shortcut Key (e.g. slm, eml, addr)',
                  hintText: 'Short trigger word...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Expanded Text / Phrase',
                  hintText: 'Full text inserted when tapped...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (existingKey != null && existingKey != keyController.text.trim().toLowerCase()) {
                  await _prefs.removeCustomShortcut(existingKey);
                }
                await _prefs.addCustomShortcut(keyController.text, valueController.text);
                await _loadShortcuts();
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
    final entries = _shortcuts.entries
        .where((e) =>
            _filter.isEmpty ||
            e.key.toLowerCase().contains(_filter.toLowerCase()) ||
            e.value.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    return ModernScaffold(
      title: 'Keyboard Shortcuts',
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFF00E5FF)),
          onPressed: () => _showAddShortcutDialog(),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              borderColor: const Color(0xFF38BDF8).withOpacity(0.32),
              fillColor: const Color(0xFF38BDF8).withOpacity(0.08),
              child: Row(
                children: [
                  const ModernIconBadge(icon: CupertinoIcons.bolt_fill, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Type any shortcut key (e.g. "slm" or "brb") on the keyboard and its full phrase appears right in the top bar for instant 1-tap expand!',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: GlassCard(
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search shortcuts...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                  prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: Color(0xFF00E5FF)),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _filter = v.trim()),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.bolt, size: 52, color: Colors.white.withOpacity(0.22)),
                        const SizedBox(height: 12),
                        const Text('No shortcuts found', style: TextStyle(color: Colors.white70, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Tap + to create a keyboard shortcut', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final entry = entries[idx];
                      return GlassCard(
                        borderRadius: 16,
                        onTap: () => _showAddShortcutDialog(
                          existingKey: entry.key,
                          existingValue: entry.value,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.42)),
                              ),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(CupertinoIcons.arrow_right, size: 15, color: Colors.white54),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: Icon(CupertinoIcons.delete, size: 18, color: Colors.white.withOpacity(0.45)),
                              onPressed: () async {
                                await _prefs.removeCustomShortcut(entry.key);
                                _loadShortcuts();
                              },
                            ),
                          ],
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
