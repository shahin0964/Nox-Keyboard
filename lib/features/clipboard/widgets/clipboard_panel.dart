import 'dart:io';
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
  final ImePlatformBridge _bridge = ImePlatformBridge();

  List<String> _pinned = [];
  List<String> _recents = [];
  List<Map<String, dynamic>> _images = [];
  bool _hasMediaPermission = true;
  String? _statusMsg;

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  Future<void> _loadClips() async {
    await _prefs.reload();
    final currentClip = await _bridge.getClipboardText();
    if (currentClip.trim().isNotEmpty) {
      await _prefs.addClipboardItem(currentClip.trim());
    }

    final mediaState = await _bridge.getMediaClipboardState();
    final hasPerm = mediaState['hasPermission'] as bool? ?? true;
    final clipImg = mediaState['clipboardImagePath'] as String? ?? '';
    final ssImg = mediaState['screenshotPath'] as String? ?? '';

    if (clipImg.isNotEmpty) {
      await _prefs.addImageClip(clipImg);
    }
    if (ssImg.isNotEmpty) {
      await _prefs.addImageClip(ssImg);
    }

    if (!mounted) return;
    setState(() {
      _hasMediaPermission = hasPerm;
      _pinned = _prefs.pinnedClipboard;
      _recents = _prefs.recentClipboard;
      _images = _prefs.imageClips.where((e) {
        final p = e['path'] as String? ?? '';
        return p.isNotEmpty && File(p).existsSync();
      }).toList();
    });
  }

  Future<void> _handleImageTap(String path) async {
    final res = await _bridge.commitImage(path);
    if (!mounted) return;
    if (res == 'COMMITTED') {
      widget.engine.closePanel();
    } else if (res == 'COPIED_ONLY') {
      setState(() => _statusMsg = 'App doesn\'t allow direct image paste; copied to clipboard!');
    } else {
      setState(() => _statusMsg = 'Could not send image here.');
    }
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
                    'Clipboard',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_hasMediaPermission) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _bridge.requestMediaPermissionFromSettings(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.accentColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          '+ Screenshots',
                          style: TextStyle(color: theme.accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      await _prefs.clearUnpinnedClipboard();
                      await _prefs.clearUnpinnedImageClips();
                      _loadClips();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.trash, size: 14, color: theme.secondaryTextColor),
                          const SizedBox(width: 3),
                          Text('Clear', style: TextStyle(color: theme.secondaryTextColor, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => widget.engine.closePanel(),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(CupertinoIcons.clear_circled_solid, color: theme.secondaryTextColor, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_statusMsg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _statusMsg!,
                style: TextStyle(color: theme.accentColor, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          Expanded(
            child: (_pinned.isEmpty && _recents.isEmpty && _images.isEmpty)
                ? Center(
                    child: Text(
                      'Copy text or take a screenshot —\nit appears here temporarily so you can pin or send it!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.secondaryTextColor, fontSize: 12.5),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (_images.isNotEmpty) ...[
                        _buildSectionHeader('Images & Screenshots (30m Temp / Pinned)'),
                        SizedBox(
                          height: 76,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (ctx, idx) => _buildImageCard(_images[idx]),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_pinned.isNotEmpty) ...[
                        _buildSectionHeader('Pinned Text'),
                        ..._pinned.map((item) => _buildClipCard(item, isPinned: true)),
                      ],
                      if (_recents.isNotEmpty) ...[
                        _buildSectionHeader('Recent Text'),
                        ..._recents.map((item) => _buildClipCard(item, isPinned: false)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(Map<String, dynamic> item) {
    final theme = widget.theme;
    final path = item['path'] as String;
    final isPinned = item['pinned'] as bool? ?? false;

    return GestureDetector(
      onTap: () => _handleImageTap(path),
      child: Container(
        width: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPinned ? theme.accentColor : theme.textColor.withOpacity(0.18),
            width: isPinned ? 1.6 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(path), fit: BoxFit.cover),
              Positioned(
                top: 3,
                right: 3,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _prefs.togglePinImageClip(path);
                        _loadClips();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                          size: 12,
                          color: isPinned ? theme.accentColor : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: () async {
                        await _prefs.deleteImageClip(path);
                        _loadClips();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.xmark, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: widget.theme.secondaryTextColor.withOpacity(0.75),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildClipCard(String text, {required bool isPinned}) {
    final theme = widget.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: theme.keyColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPinned ? theme.accentColor.withOpacity(0.55) : theme.textColor.withOpacity(0.08),
        ),
      ),
      child: InkWell(
        onTap: () {
          _bridge.commitText(text);
          widget.engine.closePanel();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.textColor, fontSize: 13),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
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
                visualDensity: VisualDensity.compact,
                icon: Icon(CupertinoIcons.delete, size: 16, color: theme.secondaryTextColor),
                onPressed: () async {
                  await _prefs.deleteClipboardItem(text);
                  _loadClips();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
