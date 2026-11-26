import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../data/preferences_helper.dart';

class DictionarySettingsScreen extends StatefulWidget {
  const DictionarySettingsScreen({super.key});

  @override
  State<DictionarySettingsScreen> createState() => _DictionarySettingsScreenState();
}

class _DictionarySettingsScreenState extends State<DictionarySettingsScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  List<String> _words = [];
  Map<String, String> _shortcuts = {};
  String _filter = '';
  int _tabIndex = 0; // 0 = Shortcuts, 1 = Custom Words

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    await _prefs.reload();
    if (!mounted) return;
    setState(() {
      _words = _prefs.userDictionary;
      _shortcuts = _prefs.customShortcuts;
    });
  }

  void _showAddModal() {
    final primaryController = TextEditingController();
    final secondaryController = TextEditingController();
    bool isShortcut = _tabIndex == 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              title: Text(
                isShortcut ? 'Add Text Shortcut' : 'Add Custom Word',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Shortcut')),
                      ButtonSegment(value: false, label: Text('Word')),
                    ],
                    selected: {isShortcut},
                    onSelectionChanged: (val) => setModalState(() => isShortcut = val.first),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: primaryController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isShortcut ? 'Shortcut (e.g. slm, brb)' : 'Custom Word',
                      hintText: isShortcut ? 'Type short trigger...' : 'Enter word...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (isShortcut) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: secondaryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Expanded Phrase',
                        hintText: 'e.g. আসসালামু আলাইকুম',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (isShortcut) {
                      await _prefs.addCustomShortcut(
                        primaryController.text,
                        secondaryController.text,
                      );
                    } else {
                      await _prefs.addUserWord(primaryController.text);
                    }
                    await _loadDictionary();
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = _filter.isEmpty
        ? _words
        : _words.where((w) => w.toLowerCase().contains(_filter.toLowerCase())).toList();

    final filteredShortcuts = _shortcuts.entries
        .where((e) =>
            _filter.isEmpty ||
            e.key.toLowerCase().contains(_filter.toLowerCase()) ||
            e.value.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    return ModernScaffold(
      title: 'Custom Dictionary',
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFF00E5FF)),
          tooltip: 'Add Word or Shortcut',
          onPressed: _showAddModal,
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
                  hintText: 'Search shortcuts & words...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                  prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: Color(0xFF00E5FF)),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _filter = v.trim()),
              ),
            ),
          ),

          // Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildTabPill(0, 'Shortcuts (${_shortcuts.length})')),
                const SizedBox(width: 10),
                Expanded(child: _buildTabPill(1, 'Custom Words (${_words.length})')),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _tabIndex == 0
                ? (filteredShortcuts.isEmpty
                    ? _buildEmptyState('No shortcuts yet', 'Tap + to add quick phrase shortcuts')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: filteredShortcuts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = filteredShortcuts[index];
                          return GlassCard(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Color(0xFFFBBF24),
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
                                    _loadDictionary();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ))
                : (filteredWords.isEmpty
                    ? _buildEmptyState('No custom words yet', 'Tap + to add your personal words')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: filteredWords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];
                          return GlassCard(
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            child: Row(
                              children: [
                                const ModernIconBadge(
                                  icon: CupertinoIcons.book_fill,
                                  color: Color(0xFFF59E0B),
                                  size: 16,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    word,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(CupertinoIcons.delete, size: 18, color: Colors.white.withOpacity(0.45)),
                                  onPressed: () async {
                                    await _prefs.removeUserWord(word);
                                    _loadDictionary();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(int idx, String title) {
    final active = _tabIndex == idx;
    return InkWell(
      onTap: () => setState(() => _tabIndex = idx),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00E5FF).withOpacity(0.18) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF00E5FF).withOpacity(0.65) : Colors.white.withOpacity(0.08),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: active ? const Color(0xFF00E5FF) : Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.book, size: 54, color: Colors.white.withOpacity(0.22)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15.5, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.45))),
        ],
      ),
    );
  }
}
