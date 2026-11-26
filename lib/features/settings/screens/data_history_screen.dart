import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../data/preferences_helper.dart';

class DataHistoryScreen extends StatefulWidget {
  const DataHistoryScreen({super.key});

  @override
  State<DataHistoryScreen> createState() => _DataHistoryScreenState();
}

class _DataHistoryScreenState extends State<DataHistoryScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  Map<String, List<Map<String, String>>> _byDate = {};
  bool _enabled = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _prefs.reload();
    if (!mounted) return;
    setState(() {
      _enabled = _prefs.isTypingHistoryEnabled;
      _byDate = _prefs.typingHistoryByDate;
    });
  }

  String _formatDateLabel(String dateKey) {
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final y = now.subtract(const Duration(days: 1));
    final yesterday =
        '${y.year.toString().padLeft(4, '0')}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    if (dateKey == today) return 'Today • $dateKey';
    if (dateKey == yesterday) return 'Yesterday • $dateKey';
    return dateKey;
  }

  String _formatAppName(String pkg) {
    if (pkg.isEmpty) return '';
    final parts = pkg.split('.');
    return parts.isNotEmpty ? parts.last : pkg;
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Clear Typing Data?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete all locally saved date-by-date typing history.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _prefs.clearTypingHistory();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _byDate.keys.toList()..sort((a, b) => b.compareTo(a));
    final total = _prefs.typingHistoryTotalCount;

    return ModernScaffold(
      title: 'Data • Typing History',
      actions: [
        if (total > 0)
          IconButton(
            tooltip: 'Clear all data',
            icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
            onPressed: _confirmClearAll,
          ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ModernSwitchTile(
              icon: CupertinoIcons.tray_full_fill,
              iconColor: const Color(0xFF38BDF8),
              title: 'Save Regular Typing by Date',
              subtitle:
                  'Stores normal typed text offline on your device ($total entries). Password, PIN, OTP & Card fields are excluded.',
              value: _enabled,
              onChanged: (val) async {
                setState(() => _enabled = val);
                await _prefs.setTypingHistoryEnabled(val);
              },
            ),
          ),

          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(CupertinoIcons.search, color: Colors.white54, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search typed text or date...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13.5),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (sortedDates.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.doc_text_search,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Saved Typing Data Yet',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Normal messages typed using Nox Keyboard will appear here organized date-by-date.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5),
                  ),
                ],
              ),
            )
          else
            ...sortedDates.map((dateKey) {
              final allItems = _byDate[dateKey] ?? [];
              final items = _query.isEmpty
                  ? allItems
                  : allItems.where((e) {
                      final txt = (e['text'] ?? '').toLowerCase();
                      return txt.contains(_query) || dateKey.contains(_query);
                    }).toList();

              if (items.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ModernSectionHeader(
                        title: '${_formatDateLabel(dateKey)} (${items.length})',
                      ),
                      TextButton(
                        onPressed: () async {
                          await _prefs.deleteTypingHistoryDate(dateKey);
                          await _load();
                        },
                        child: const Text(
                          'Delete Day',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  ...List.generate(items.length, (idx) {
                    final item = items[idx];
                    final origIdx = allItems.indexOf(item);
                    final text = item['text'] ?? '';
                    final time = item['time'] ?? '';
                    final lang = item['lang'] ?? '';
                    final app = _formatAppName(item['app'] ?? '');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (time.isNotEmpty)
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      if (lang.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          lang,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.55),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                      if (app.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '• $app',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.45),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  SelectableText(
                                    text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy',
                              icon: const Icon(CupertinoIcons.doc_on_doc, size: 17, color: Color(0xFF38BDF8)),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete entry',
                              icon: const Icon(CupertinoIcons.xmark_circle, size: 17, color: Colors.white38),
                              onPressed: () async {
                                if (origIdx >= 0) {
                                  await _prefs.deleteTypingHistoryEntry(dateKey, origIdx);
                                  await _load();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
        ],
      ),
    );
  }
}
