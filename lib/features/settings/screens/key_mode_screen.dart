import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../data/preferences_helper.dart';

class KeyModeScreen extends StatefulWidget {
  const KeyModeScreen({super.key});

  @override
  State<KeyModeScreen> createState() => _KeyModeScreenState();
}

class _KeyModeScreenState extends State<KeyModeScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  Map<String, String> _commands = {};
  bool _stayActive = true;

  static const Map<String, Map<String, dynamic>> _builtInActions = {
    'action:copy': {'title': 'Copy', 'desc': 'Copy selected text (Ctrl+C)', 'icon': CupertinoIcons.doc_on_doc},
    'action:paste': {'title': 'Paste', 'desc': 'Paste from clipboard (Ctrl+V)', 'icon': CupertinoIcons.doc_on_clipboard},
    'action:cut': {'title': 'Cut', 'desc': 'Cut selected text (Ctrl+X)', 'icon': CupertinoIcons.scissors},
    'action:selectAll': {'title': 'Select All', 'desc': 'Select all text in box (Ctrl+A)', 'icon': CupertinoIcons.selection_pin_in_out},
    'action:copyAll': {'title': 'Copy All', 'desc': 'Select all & copy instantly', 'icon': CupertinoIcons.doc_on_doc_fill},
    'action:undo': {'title': 'Undo', 'desc': 'Undo last change (Ctrl+Z)', 'icon': CupertinoIcons.arrow_uturn_left},
    'action:redo': {'title': 'Redo', 'desc': 'Redo change (Ctrl+Y)', 'icon': CupertinoIcons.arrow_uturn_right},
    'action:deleteForward': {'title': 'Delete Forward', 'desc': 'Delete character after cursor (Del)', 'icon': CupertinoIcons.delete_right},
    'action:deleteWord': {'title': 'Delete Word', 'desc': 'Delete word before cursor', 'icon': CupertinoIcons.delete_left_fill},
    'action:clearAll': {'title': 'Clear Box', 'desc': 'Select all & delete box text', 'icon': CupertinoIcons.trash},
    'action:home': {'title': 'Move Home', 'desc': 'Jump cursor to start (Home)', 'icon': CupertinoIcons.arrow_up_left},
    'action:end': {'title': 'Move End', 'desc': 'Jump cursor to end (End)', 'icon': CupertinoIcons.arrow_down_right},
    'action:left': {'title': 'Cursor Left', 'desc': 'Move cursor 1 char left (←)', 'icon': CupertinoIcons.arrow_left},
    'action:right': {'title': 'Cursor Right', 'desc': 'Move cursor 1 char right (→)', 'icon': CupertinoIcons.arrow_right},
    'action:up': {'title': 'Cursor Up', 'desc': 'Move cursor 1 line up (↑)', 'icon': CupertinoIcons.arrow_up},
    'action:down': {'title': 'Cursor Down', 'desc': 'Move cursor 1 line down (↓)', 'icon': CupertinoIcons.arrow_down},
    'action:selectLeft': {'title': 'Select Left', 'desc': 'Extend selection left (Shift+←)', 'icon': CupertinoIcons.arrow_left_square},
    'action:selectRight': {'title': 'Select Right', 'desc': 'Extend selection right (Shift+→)', 'icon': CupertinoIcons.arrow_right_square},
    'action:tab': {'title': 'Insert Tab', 'desc': 'Send Tab key', 'icon': CupertinoIcons.arrow_right_to_line},
    'action:escape': {'title': 'Escape', 'desc': 'Send Esc key', 'icon': CupertinoIcons.escape},
  };

  static const List<String> _alphabet = [
    'c', 'v', 'x', 'a', 'z', 'y', 's', 'd', 'b', 'k',
    'h', 'e', 't', 'q', 'l', 'r', 'u', 'n', 'w', 'p',
    'f', 'g', 'i', 'j', 'm', 'o',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _prefs.reload();
    if (!mounted) return;
    setState(() {
      _commands = Map<String, String>.from(_prefs.keyCommandsMap);
      _stayActive = _prefs.keyModeStayActive;
    });
  }

  String _describeValue(String? val) {
    if (val == null || val.isEmpty) return 'Not assigned';
    final info = _builtInActions[val];
    if (info != null) return '${info['title']} — ${info['desc']}';
    if (val.startsWith('text:')) return 'Insert text: "${val.substring(5)}"';
    return val;
  }

  Future<void> _editKeyMapping(String keyChar) async {
    final currentVal = _commands[keyChar] ?? '';
    final customTextController = TextEditingController(
      text: currentVal.startsWith('text:') ? currentVal.substring(5) : '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          maxChildSize: 0.9,
          minChildSize: 0.45,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assign Command to "${keyChar.toUpperCase()}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentVal.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await _prefs.setKeyCommand(keyChar, '');
                            if (ctx.mounted) Navigator.pop(ctx);
                            _load();
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customTextController,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(
                              hintText: 'Or type custom snippet to insert...',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            final txt = customTextController.text;
                            if (txt.isNotEmpty) {
                              await _prefs.setKeyCommand(keyChar, 'text:$txt');
                              if (ctx.mounted) Navigator.pop(ctx);
                              _load();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'BUILT-IN PC COMMANDS',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._builtInActions.entries.map((entry) {
                    final selected = currentVal == entry.key;
                    final info = entry.value;
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: selected
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.14)
                          : Colors.transparent,
                      leading: Icon(
                        info['icon'] as IconData,
                        color: selected ? const Color(0xFF00E5FF) : Colors.white70,
                        size: 20,
                      ),
                      title: Text(
                        info['title'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        info['desc'] as String,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                      ),
                      trailing: selected
                          ? const Icon(CupertinoIcons.check_mark, color: Color(0xFF00E5FF), size: 18)
                          : null,
                      onTap: () async {
                        await _prefs.setKeyCommand(keyChar, entry.key);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: 'Key • Shortcut Keys',
      actions: [
        IconButton(
          tooltip: 'Reset defaults',
          icon: const Icon(CupertinoIcons.arrow_counterclockwise, color: Colors.white),
          onPressed: () async {
            await _prefs.resetKeyCommands();
            await _load();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Default Key commands restored!')),
              );
            }
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModernIconBadge(
                  icon: CupertinoIcons.command,
                  color: Color(0xFF00E5FF),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Built-In Hold-Key Shortcuts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Press and hold directly on your normal keyboard: Hold C to Copy, V to Paste, X to Cut, A to Select All, Z to Undo — no extra mode button needed!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const ModernSectionHeader(title: 'HOLD-KEY COMMANDS (TAP TO CUSTOMIZE)'),

          ..._alphabet.map((ch) {
            final val = _commands[ch];
            final isSet = val != null && val.isNotEmpty;
            final actionMeta = isSet ? _builtInActions[val] : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                onTap: () => _editKeyMapping(ch),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                borderColor: isSet
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSet
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isSet
                              ? const Color(0xFF00E5FF).withValues(alpha: 0.45)
                              : Colors.white12,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ch.toUpperCase(),
                        style: TextStyle(
                          color: isSet ? const Color(0xFF00E5FF) : Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actionMeta != null
                                ? (actionMeta['title'] as String)
                                : (isSet ? 'Custom Snippet' : 'Unassigned'),
                            style: TextStyle(
                              color: isSet ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _describeValue(val),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
