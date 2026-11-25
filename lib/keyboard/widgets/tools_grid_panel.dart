import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';

class ToolsGridPanel extends StatelessWidget {
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const ToolsGridPanel({
    super.key,
    required this.theme,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolItem(
        icon: Icons.palette_outlined,
        label: 'Themes',
        onTap: () => engine.openPanel(KeyboardPanel.themes),
      ),
      _ToolItem(
        icon: CupertinoIcons.hand_draw,
        label: 'One-handed',
        onTap: () {
          final next = engine.oneHandedMode == 'none'
              ? 'right'
              : (engine.oneHandedMode == 'right' ? 'left' : 'none');
          engine.setOneHandedMode(next);
          engine.closePanel();
        },
      ),
      _ToolItem(
        icon: CupertinoIcons.arrow_right_arrow_left,
        label: 'Text editing',
        onTap: () => engine.openPanel(KeyboardPanel.textEditing),
      ),
      _ToolItem(
        icon: CupertinoIcons.doc_on_clipboard,
        label: 'Clipboard',
        onTap: () => engine.openPanel(KeyboardPanel.clipboard),
      ),
      _ToolItem(
        icon: CupertinoIcons.smiley,
        label: 'Emoji',
        onTap: () => engine.openPanel(KeyboardPanel.emoji),
      ),
      _ToolItem(
        icon: CupertinoIcons.number,
        label: 'Number row',
        isActive: engine.showNumberRow,
        onTap: () {
          engine.toggleNumberRow();
          engine.closePanel();
        },
      ),
      _ToolItem(
        icon: CupertinoIcons.mic,
        label: 'Voice',
        onTap: () => engine.openPanel(KeyboardPanel.voice),
      ),
      _ToolItem(
        icon: CupertinoIcons.settings,
        label: 'Settings',
        onTap: () {
          engine.closePanel();
          ImePlatformBridge().openSettings();
        },
      ),
    ];

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          // Header with back to keys button
          Row(
            children: [
              InkWell(
                onTap: () => engine.closePanel(),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.clear, size: 14, color: theme.textColor),
                      const SizedBox(width: 4),
                      Text(
                        'Close',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'More features',
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 4-column Grid of Gboard-style tool tiles
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.25,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return InkWell(
                  onTap: tool.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tool.isActive
                          ? theme.accentColor.withOpacity(0.25)
                          : Colors.white.withOpacity(theme.isDark ? 0.05 : 0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tool.isActive
                            ? theme.accentColor.withOpacity(0.7)
                            : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.18),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tool.icon,
                          size: 22,
                          color: tool.isActive ? theme.accentColor : theme.textColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tool.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tool.isActive ? theme.accentColor : theme.secondaryTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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

class _ToolItem {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });
}
