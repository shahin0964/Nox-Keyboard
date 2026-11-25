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
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: theme.toolbarColor.withOpacity(theme.isDark ? 0.88 : 0.94),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(theme.isDark ? 0.06 : 0.15),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Expand/collapse pill button
          InkWell(
            onTap: () => engine.toggleToolbarExpanded(),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(theme.isDark ? 0.05 : 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.16),
                  width: 0.8,
                ),
              ),
              child: Icon(
                engine.isToolbarExpanded ? CupertinoIcons.chevron_left : CupertinoIcons.ellipsis,
                size: 15,
                color: theme.secondaryTextColor,
              ),
            ),
          ),

          // Tools list in modern pill capsules
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildPillToolItem(
                    icon: CupertinoIcons.smiley,
                    label: 'Emoji',
                    isActive: engine.activePanel == KeyboardPanel.emoji,
                    onTap: () => engine.openPanel(KeyboardPanel.emoji),
                  ),
                  _buildPillToolItem(
                    icon: CupertinoIcons.doc_on_clipboard,
                    label: 'Clipboard',
                    isActive: engine.activePanel == KeyboardPanel.clipboard,
                    onTap: () => engine.openPanel(KeyboardPanel.clipboard),
                  ),
                  _buildPillToolItem(
                    icon: CupertinoIcons.mic,
                    label: 'Voice',
                    isActive: engine.activePanel == KeyboardPanel.voice,
                    onTap: () => engine.openPanel(KeyboardPanel.voice),
                  ),
                  _buildPillToolItem(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    label: 'Edit',
                    isActive: engine.activePanel == KeyboardPanel.textEditing,
                    onTap: () => engine.openPanel(KeyboardPanel.textEditing),
                  ),
                  _buildPillToolItem(
                    icon: Icons.palette_outlined,
                    label: 'Themes',
                    isActive: engine.activePanel == KeyboardPanel.themes,
                    onTap: () => engine.openPanel(KeyboardPanel.themes),
                  ),
                  _buildPillToolItem(
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
                  _buildPillToolItem(
                    icon: CupertinoIcons.number,
                    label: 'Numbers',
                    isActive: engine.showNumberRow,
                    onTap: () => engine.toggleNumberRow(),
                  ),
                  _buildPillToolItem(
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

  Widget _buildPillToolItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        decoration: BoxDecoration(
          color: isActive
              ? theme.accentColor.withOpacity(0.24)
              : Colors.white.withOpacity(theme.isDark ? 0.05 : 0.22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? theme.accentColor.withOpacity(0.8)
                : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.18),
            width: isActive ? 1.2 : 0.8,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.accentColor.withOpacity(0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 17,
          color: isActive ? theme.accentColor : theme.secondaryTextColor,
        ),
      ),
    );
  }
}
