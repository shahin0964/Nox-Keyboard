import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../themes/theme_manager.dart';
import '../../data/preferences_helper.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';
import 'toolbar_widget.dart';
import 'suggestions_bar_widget.dart';
import 'keyboard_key_widget.dart';
import 'text_editing_pad.dart';
import '../../features/clipboard/widgets/clipboard_panel.dart';
import '../../features/emoji/widgets/emoji_palette.dart';
import '../../features/voice/widgets/voice_typing_dialog.dart';
import '../../features/customization/widgets/theme_quick_switcher.dart';

class NoxKeyboardView extends StatefulWidget {
  final bool isImeMode;

  const NoxKeyboardView({
    super.key,
    this.isImeMode = false,
  });

  @override
  State<NoxKeyboardView> createState() => _NoxFirebaseViewState();
}

class _NoxFirebaseViewState extends State<NoxKeyboardView> {
  final KeyboardEngine _engine = KeyboardEngine();
  final ThemeManager _themeManager = ThemeManager();
  final PreferencesHelper _prefs = PreferencesHelper();
  final ImePlatformBridge _bridge = ImePlatformBridge();

  @override
  void initState() {
    super.initState();
    _engine.addListener(_onEngineUpdate);
    _themeManager.addListener(_onThemeUpdate);

    // Sync Gboard-matching dimensions (260dp content + 36dp nav bar padding) with Android InputMethodService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bridge.updateKeyboardDimensions(
        contentHeight: 260.0,
        navBarHeight: _bridge.navBarHeightDp,
      );
    });
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _themeManager.removeListener(_onThemeUpdate);
    super.dispose();
  }

  void _onEngineUpdate() {
    if (mounted) setState(() {});
  }

  void _onThemeUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    // Bottom navigation inset to prevent Android gesture bar/pill from overlapping spacebar & keys
    final double navBarPadding = widget.isImeMode ? _bridge.navBarHeightDp : 0.0;

    Widget mainContent;
    switch (_engine.activePanel) {
      case KeyboardPanel.emoji:
        mainContent = EmojiPalette(theme: theme, engine: _engine);
        break;
      case KeyboardPanel.clipboard:
        mainContent = ClipboardPanel(theme: theme, engine: _engine);
        break;
      case KeyboardPanel.textEditing:
        mainContent = TextEditingPad(theme: theme, engine: _engine);
        break;
      case KeyboardPanel.voice:
        mainContent = VoiceTypingPanel(theme: theme, engine: _engine);
        break;
      case KeyboardPanel.themes:
        mainContent = ThemeQuickSwitcher(currentTheme: theme, engine: _engine);
        break;
      case KeyboardPanel.none:
      default:
        mainContent = _buildKeyGrid(theme);
    }

    Widget keyboardBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToolbarWidget(engine: _engine, theme: theme),
        SuggestionsBarWidget(engine: _engine, theme: theme),
        SizedBox(
          height: 184.0, // Exact Gboard-proportioned key area height
          child: mainContent,
        ),
        // Dedicated Android navigation bar padding zone (lifts spacebar & keys above gesture bar)
        if (navBarPadding > 0)
          SizedBox(height: navBarPadding),
      ],
    );

    // Apply One-Handed mode wrapping if active
    if (_engine.oneHandedMode != 'none') {
      keyboardBody = _buildOneHandedWrapper(keyboardBody, theme);
    }

    return Material(
      color: theme.backgroundColor,
      child: Container(
        color: theme.backgroundColor,
        child: keyboardBody,
      ),
    );
  }

  Widget _buildOneHandedWrapper(Widget child, NoxKeyboardTheme theme) {
    final isLeft = _engine.oneHandedMode == 'left';

    final sidebar = Container(
      width: 50,
      color: theme.toolbarColor.withOpacity(theme.isDark ? 0.8 : 0.95),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Expand to full pill button
          InkWell(
            onTap: () => _engine.setOneHandedMode('none'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(theme.isDark ? 0.06 : 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.16),
                ),
              ),
              child: Icon(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                size: 17,
                color: theme.secondaryTextColor,
              ),
            ),
          ),
          // Switch side pill button
          InkWell(
            onTap: () => _engine.setOneHandedMode(isLeft ? 'right' : 'left'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(theme.isDark ? 0.06 : 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.16),
                ),
              ),
              child: Icon(
                isLeft ? CupertinoIcons.arrow_right_circle : CupertinoIcons.arrow_left_circle,
                size: 19,
                color: theme.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );

    return Row(
      children: [
        if (!isLeft) sidebar,
        Expanded(child: child),
        if (isLeft) sidebar,
      ],
    );
  }

  Widget _buildKeyGrid(NoxKeyboardTheme theme) {
    final page = _engine.activePage;
    final numberRow = _engine.numberRow;

    return Container(
      padding: const EdgeInsets.only(bottom: 2, left: 2, right: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Optional dedicated number row
          if (numberRow != null)
            Expanded(
              child: Row(
                children: numberRow.keys
                    .map((k) => KeyboardKeyWidget(keyboardKey: k, theme: theme, engine: _engine))
                    .toList(),
              ),
            ),

          // Standard layout rows
          ...page.rows.map((row) {
            return Expanded(
              child: Row(
                children: row.keys
                    .map((k) => KeyboardKeyWidget(keyboardKey: k, theme: theme, engine: _engine))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
