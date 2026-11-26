import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../themes/theme_manager.dart';
import '../../data/preferences_helper.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';
import 'toolbar_widget.dart';
import 'tools_grid_panel.dart';
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
  double _lastSyncedContentHeight = -1;

  double get _keyAreaHeight => (220.0 + (_prefs.keyboardHeight - 275.0)).clamp(185.0, 275.0);

  @override
  void initState() {
    super.initState();
    _engine.addListener(_onEngineUpdate);
    _themeManager.addListener(_onThemeUpdate);

    // Sync key area + 40dp toolbar + generous 60dp navigation bar clearance with native Android
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNativeDimensions();
    });
  }

  void _syncNativeDimensions() {
    if (!widget.isImeMode) return;
    final contentHeight = _keyAreaHeight + 40.0;
    if ((_lastSyncedContentHeight - contentHeight).abs() > 0.5) {
      _lastSyncedContentHeight = contentHeight;
      _bridge.updateKeyboardDimensions(
        contentHeight: contentHeight,
        navBarHeight: 60.0,
      );
    }
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _themeManager.removeListener(_onThemeUpdate);
    super.dispose();
  }

  void _onEngineUpdate() {
    _syncNativeDimensions();
    if (mounted) setState(() {});
  }

  void _onThemeUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    // Generous 60dp bottom navigation clearance so no keys touch the Android gesture bar or switcher
    final double navBarPadding = widget.isImeMode ? 60.0 : 0.0;

    Widget mainContent;
    switch (_engine.activePanel) {
      case KeyboardPanel.toolsGrid:
        mainContent = ToolsGridPanel(theme: theme, engine: _engine);
        break;
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

    final double keyAreaHeight = _keyAreaHeight;
    final double totalHeight = 40.0 + keyAreaHeight + navBarPadding;

    Widget keyboardBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Single unified Gboard header bar (suggestions or toolbar + mic on right)
        ToolbarWidget(engine: _engine, theme: theme),
        SizedBox(
          height: keyAreaHeight,
          child: mainContent,
        ),
        // Dedicated 60dp navigation bar padding zone (lifts spacebar & keys completely above navigation bar)
        if (navBarPadding > 0)
          SizedBox(height: navBarPadding),
      ],
    );

    // Apply One-Handed mode wrapping if active
    if (_engine.oneHandedMode != 'none') {
      keyboardBody = _buildOneHandedWrapper(keyboardBody, theme, totalHeight, navBarPadding);
    }

    return Material(
      color: theme.backgroundColor,
      child: Container(
        color: theme.backgroundColor,
        child: keyboardBody,
      ),
    );
  }

  Widget _buildOneHandedWrapper(
    Widget child,
    NoxKeyboardTheme theme,
    double totalHeight,
    double navBarPadding,
  ) {
    final isLeft = _engine.oneHandedMode == 'left';

    final sidebar = Container(
      width: 48,
      height: totalHeight,
      padding: EdgeInsets.only(bottom: navBarPadding),
      color: theme.toolbarColor.withOpacity(theme.isDark ? 0.85 : 0.95),
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
                color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(theme.isDark ? 0.1 : 0.18),
                ),
              ),
              child: Icon(
                CupertinoIcons.arrow_up_left_arrow_down_right,
                size: 17,
                color: theme.textColor,
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
                color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(theme.isDark ? 0.1 : 0.18),
                ),
              ),
              child: Icon(
                isLeft ? CupertinoIcons.arrow_right_circle : CupertinoIcons.arrow_left_circle,
                size: 19,
                color: theme.accentColor,
              ),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLeft) sidebar,
          Expanded(child: child),
          if (isLeft) sidebar,
        ],
      ),
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
