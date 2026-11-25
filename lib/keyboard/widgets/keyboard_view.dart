import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../themes/theme_manager.dart';
import '../../data/preferences_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _engine.addListener(_onEngineUpdate);
    _themeManager.addListener(_onThemeUpdate);
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
    final double keyboardHeight = _prefs.keyboardHeight;

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
          height: keyboardHeight - 82, // Total height minus toolbar (40) and suggestions (42)
          child: mainContent,
        ),
      ],
    );

    // Apply One-Handed mode wrapping if active
    if (_engine.oneHandedMode != 'none') {
      keyboardBody = _buildOneHandedWrapper(keyboardBody, theme);
    }

    return Material(
      color: theme.backgroundColor,
      child: SafeArea(
        top: false,
        child: Container(
          color: theme.backgroundColor,
          child: keyboardBody,
        ),
      ),
    );
  }

  Widget _buildOneHandedWrapper(Widget child, NoxKeyboardTheme theme) {
    final isLeft = _engine.oneHandedMode == 'left';

    final sidebar = Container(
      width: 50,
      color: theme.toolbarColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Expand to full button
          IconButton(
            icon: Icon(CupertinoIcons.arrow_up_left_arrow_down_right, size: 18, color: theme.secondaryTextColor),
            onPressed: () => _engine.setOneHandedMode('none'),
          ),
          // Switch side button
          IconButton(
            icon: Icon(isLeft ? CupertinoIcons.arrow_right_circle : CupertinoIcons.arrow_left_circle, size: 20, color: theme.secondaryTextColor),
            onPressed: () => _engine.setOneHandedMode(isLeft ? 'right' : 'left'),
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
      padding: const EdgeInsets.only(bottom: 4, left: 2, right: 2),
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
