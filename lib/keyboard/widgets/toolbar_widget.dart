import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';

class ToolbarWidget extends StatelessWidget {
  final KeyboardEngine engine;
  final NoxKeyboardTheme theme;

  const ToolbarWidget({
    super.key,
    required this.engine,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(
          bottom: BorderSide(
            color: theme.textColor.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Expand/collapse chevron
          IconButton(
            icon: Icon(
              engine.isToolbarExpanded ? CupertinoIcons.chevron_left : CupertinoIcons.ellipsis,
              size: 18,
              color: theme.secondaryTextColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => engine.toggleToolbarExpanded(),
          ),

          // Tools list
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildToolItem(
                    icon: CupertinoIcons.smiley,
                    label: 'Emoji',
                    isActive: engine.activePanel == KeyboardPanel.emoji,
                    onTap: () => engine.openPanel(KeyboardPanel.emoji),
                  ),
                  _buildToolItem(
                    icon: CupertinoIcons.doc_on_clipboard,
                    label: 'Clipboard',
                    isActive: engine.activePanel == KeyboardPanel.clipboard,
                    onTap: () => engine.openPanel(KeyboardPanel.clipboard),
                  ),
                  _buildToolItem(
                    icon: CupertinoIcons.mic,
                    label: 'Voice',
                    isActive: engine.activePanel == KeyboardPanel.voice,
                    onTap: () => engine.openPanel(KeyboardPanel.voice),
                  ),
                  _buildToolItem(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    label: 'Edit',
                    isActive: engine.activePanel == KeyboardPanel.textEditing,
                    onTap: () => engine.openPanel(KeyboardPanel.textEditing),
                  ),
                  _buildToolItem(
                    icon: Icons.palette,
                    label: 'Themes',
                    isActive: engine.activePanel == KeyboardPanel.themes,
                    onTap: () => engine.openPanel(KeyboardPanel.themes),
                  ),
                  _buildToolItem(
                    icon: CupertinoIcons.hand_draw,
                    label: 'One-Hand',
                    isActive: engine.oneHandedMode != 'none',
                    onTap: () {
                      final next = engine.oneHandedMode == 'none'
                          ? 'right'
                          : (engine.oneHandedMode == 'right' ? 'left' : 'none');
                      engine.setOneHandedMode(next);
                    },
                  ),
                  _buildToolItem(
                    icon: CupertinoIcons.number,
                    label: 'Numbers',
                    isActive: engine.showNumberRow,
                    onTap: () => engine.toggleNumberRow(),
                  ),
                  _buildToolItem(
                    icon: CupertinoIcons.settings,
                    label: 'Settings',
                    isActive: false,
                    onTap: () => ImePlatformBridge().openSettings(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? theme.accentColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isActive ? theme.accentColor : theme.secondaryTextColor,
        ),
      ),
    );
  }
}
