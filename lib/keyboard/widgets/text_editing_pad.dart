import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';

class TextEditingPad extends StatelessWidget {
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const TextEditingPad({
    super.key,
    required this.theme,
    required this.engine,
  });

  // Standard Android android.R.id.* constants for InputConnection.performContextMenuAction
  static const int _idSelectAll = 0x0102001f;
  static const int _idCut = 0x01020020;
  static const int _idCopy = 0x01020021;
  static const int _idPaste = 0x01020022;

  @override
  Widget build(BuildContext context) {
    final bridge = ImePlatformBridge();

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          // Top action bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Editing',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () => engine.closePanel(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(CupertinoIcons.clear_circled_solid, color: theme.secondaryTextColor, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Action buttons: Select All, Cut, Copy, Paste
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBtn('Select All', CupertinoIcons.selection_pin_in_out, () {
                bridge.performContextMenuAction(_idSelectAll);
              }),
              _buildBtn('Cut', CupertinoIcons.scissors, () {
                bridge.performContextMenuAction(_idCut);
              }),
              _buildBtn('Copy', CupertinoIcons.doc_on_doc, () {
                bridge.performContextMenuAction(_idCopy);
              }),
              _buildBtn('Paste', CupertinoIcons.doc_on_clipboard, () {
                bridge.performContextMenuAction(_idPaste);
              }),
            ],
          ),

          const SizedBox(height: 10),

          // D-Pad navigation
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left
                _buildNavBtn(CupertinoIcons.arrow_left, () => bridge.moveCursor(-1)),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Up
                    _buildNavBtn(CupertinoIcons.arrow_up, () => bridge.sendKeyEvent(19)), // KEYCODE_DPAD_UP
                    const SizedBox(height: 6),
                    // Down
                    _buildNavBtn(CupertinoIcons.arrow_down, () => bridge.sendKeyEvent(20)), // KEYCODE_DPAD_DOWN
                  ],
                ),
                const SizedBox(width: 8),
                // Right
                _buildNavBtn(CupertinoIcons.arrow_right, () => bridge.moveCursor(1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: theme.keyColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.textColor.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.accentColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: theme.textColor, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 54,
        height: 40,
        decoration: BoxDecoration(
          color: theme.keyColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.textColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: theme.textColor, size: 22),
      ),
    );
  }
}
