import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';
import '../suggestions/suggestion_engine.dart';

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
    final hasSuggestions = engine.candidates.isNotEmpty && !engine.forceShowToolbar;
    final isToolsOpen = engine.activePanel == KeyboardPanel.toolsGrid;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: theme.toolbarColor.withOpacity(theme.isDark ? 0.90 : 0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(theme.isDark ? 0.06 : 0.15),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Gboard-style 4-squares grid icon (or close/back)
          InkWell(
            onTap: () {
              if (isToolsOpen) {
                engine.closePanel();
              } else if (hasSuggestions) {
                engine.toggleForceShowToolbar();
              } else {
                engine.openPanel(KeyboardPanel.toolsGrid);
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isToolsOpen
                    ? theme.accentColor.withOpacity(0.25)
                    : Colors.white.withOpacity(theme.isDark ? 0.05 : 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isToolsOpen
                      ? theme.accentColor.withOpacity(0.7)
                      : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.16),
                  width: 0.8,
                ),
              ),
              child: Icon(
                isToolsOpen
                    ? CupertinoIcons.clear
                    : (hasSuggestions ? CupertinoIcons.chevron_right : Icons.grid_view_rounded),
                size: 16,
                color: isToolsOpen ? theme.accentColor : theme.secondaryTextColor,
              ),
            ),
          ),

          // Center: Either typing word suggestions OR toolbar pills
          Expanded(
            child: hasSuggestions
                ? _buildSuggestionsRow(context)
                : _buildToolsRow(context),
          ),

          // Right: Permanent Voice (Microphone) button (Gboard style)
          InkWell(
            onTap: () {
              if (engine.activePanel == KeyboardPanel.voice) {
                engine.closePanel();
              } else {
                engine.openPanel(KeyboardPanel.voice);
              }
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: engine.activePanel == KeyboardPanel.voice
                    ? theme.accentColor.withOpacity(0.28)
                    : Colors.white.withOpacity(theme.isDark ? 0.05 : 0.22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: engine.activePanel == KeyboardPanel.voice
                      ? theme.accentColor.withOpacity(0.8)
                      : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.18),
                  width: engine.activePanel == KeyboardPanel.voice ? 1.2 : 0.8,
                ),
                boxShadow: engine.activePanel == KeyboardPanel.voice
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
                CupertinoIcons.mic,
                size: 17,
                color: engine.activePanel == KeyboardPanel.voice
                    ? theme.accentColor
                    : theme.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Word Suggestions when user is typing
  Widget _buildSuggestionsRow(BuildContext context) {
    final candidates = engine.candidates;
    return Row(
      children: List.generate(candidates.length.clamp(0, 3), (index) {
        final c = candidates[index];
        final isAutocorrect = c.isAutocorrect;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: InkWell(
              onTap: () => engine.selectSuggestion(c),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: isAutocorrect
                      ? theme.accentColor.withOpacity(0.18)
                      : theme.keyColor.withOpacity(theme.isDark ? 0.65 : 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isAutocorrect
                        ? theme.accentColor.withOpacity(0.65)
                        : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.2),
                    width: isAutocorrect ? 1.2 : 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    c.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isAutocorrect ? theme.accentColor : theme.textColor,
                      fontSize: 14.5,
                      fontWeight: isAutocorrect ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Toolbar icons when not typing
  Widget _buildToolsRow(BuildContext context) {
    return SingleChildScrollView(
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
