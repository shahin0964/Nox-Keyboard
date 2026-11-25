import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../data/preferences_helper.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../keyboard/engine/keyboard_engine.dart';

class ClipboardPanel extends StatefulWidget {
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const ClipboardPanel({
    super.key,
    required this.theme,
    required this.engine,
  });

  @override
  State<ClipboardPanel> createState() => _ClipboardPanelState();
}

class _ClipboardPanelState extends State<ClipboardPanel> {
  final PreferencesHelper _prefs = PreferencesHelper();
  List<String> _pinned = [];
  List<String> _recents = [];

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  Future<void> _loadClips() async {
    // Also check current system clipboard
    final currentClip = await ImePlatformBridge().getClipboardText();
    if (currentClip.trim().isNotEmpty) {
      await _prefs.addClipboardItem(currentClip.trim());
    }

    setState(() {
      _pinned = _prefs.pinnedClipboard;
      _recents = _prefs.recentClipboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.doc_on_clipboard, size: 16, color: theme.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    'Clipboard History',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    icon: Icon(CupertinoIcons.trash, size: 14, color: theme.secondaryTextColor),
                    label: Text('Clear', style: TextStyle(color: theme.secondaryTextColor, fontSize: 12)),
                    onPressed: () async {
                      await _prefs.clearUnpinnedClipboard();
                      _loadClips();
                    },
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.clear_circled_solid, color: theme.secondaryTextColor, size: 20),
                    onPressed: () => widget.engine.closePanel(),
                  ),
                ],
              ),
            ],
          ),

          // Chips / Items
          Expanded(
            child: (_pinned.isEmpty && _recents.isEmpty)
                ? Center(
                    child: Text(
                      'No clipboard items yet.\nCopied text will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (_pinned.isNotEmpty) ...[
                        _buildSectionHeader('Pinned'),
                        ..._pinned.map((item) => _buildClipCard(item, isPinned: true)),
                      ],
                      if (_recents.isNotEmpty) ...[
                        _buildSectionHeader('Recent'),
                        ..._recents.map((item) => _buildClipCard(item, isPinned: false)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: widget.theme.secondaryTextColor.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildClipCard(String text, {required bool isPinned}) {
    final theme = widget.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: theme.keyColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPinned ? theme.accentColor.withOpacity(0.5) : theme.textColor.withOpacity(0.08),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        title: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.textColor, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                size: 16,
                color: isPinned ? theme.accentColor : theme.secondaryTextColor,
              ),
              onPressed: () async {
                await _prefs.togglePinClipboardItem(text);
                _loadClips();
              },
            ),
            IconButton(
              icon: Icon(CupertinoIcons.delete, size: 16, color: theme.secondaryTextColor),
              onPressed: () async {
                await _prefs.deleteClipboardItem(text);
                _loadClips();
              },
            ),
          ],
        ),
        onTap: () {
          ImePlatformBridge().commitText(text);
          widget.engine.closePanel();
        },
      ),
    );
  }
}
