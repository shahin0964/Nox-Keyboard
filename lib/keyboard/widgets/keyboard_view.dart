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
  final NoxKeyboardTheme? overrideTheme;

  const NoxKeyboardView({
    super.key,
    this.isImeMode = false,
    this.overrideTheme,
  });

  @override
  State<NoxKeyboardView> createState() => _NoxFirebaseViewState();
}

class _NoxFirebaseViewState extends State<NoxKeyboardView>
    with SingleTickerProviderStateMixin {
  final KeyboardEngine _engine = KeyboardEngine();
  final ThemeManager _themeManager = ThemeManager();
  final PreferencesHelper _prefs = PreferencesHelper();
  final ImePlatformBridge _bridge = ImePlatformBridge();
  double _lastSyncedContentHeight = -1;
  late AnimationController _themeAnimController;

  double get _keyAreaHeight => (220.0 + (_prefs.keyboardHeight - 275.0)).clamp(185.0, 275.0);

  NoxKeyboardTheme get _activeTheme => widget.overrideTheme ?? _themeManager.currentTheme;

  @override
  void initState() {
    super.initState();
    _themeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _updateAnimationPlayback();

    _engine.addListener(_onEngineUpdate);
    _themeManager.addListener(_onThemeUpdate);

    // Sync key area + 40dp toolbar + generous 60dp navigation bar clearance with native Android
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNativeDimensions();
    });
  }

  @override
  void didUpdateWidget(covariant NoxKeyboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overrideTheme?.id != widget.overrideTheme?.id) {
      _updateAnimationPlayback();
    }
  }

  void _updateAnimationPlayback() {
    if (_activeTheme.isAnimated) {
      if (!_themeAnimController.isAnimating) {
        _themeAnimController.repeat();
      }
    } else {
      _themeAnimController.stop();
    }
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
    _themeAnimController.dispose();
    _engine.removeListener(_onEngineUpdate);
    _themeManager.removeListener(_onThemeUpdate);
    super.dispose();
  }

  void _onEngineUpdate() {
    _syncNativeDimensions();
    if (mounted) setState(() {});
  }

  void _onThemeUpdate() {
    _updateAnimationPlayback();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = _activeTheme;
    // Generous 60dp bottom navigation clearance so no keys touch the Android gesture bar or switcher
    final double navBarPadding = widget.isImeMode ? 60.0 : 0.0;

    return AnimatedBuilder(
      animation: _themeAnimController,
      builder: (context, _) {
        final double animValue = theme.isAnimated ? _themeAnimController.value : 0.0;

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
            mainContent = _buildKeyGrid(theme, animValue);
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
            if (navBarPadding > 0) SizedBox(height: navBarPadding),
          ],
        );

        // Apply One-Handed mode wrapping if active
        if (_engine.oneHandedMode != 'none') {
          keyboardBody = _buildOneHandedWrapper(keyboardBody, theme, totalHeight, navBarPadding);
        }

        return Material(
          color: theme.backgroundColor,
          child: Container(
            decoration: _buildKeyboardBackgroundDecoration(theme, animValue),
            child: keyboardBody,
          ),
        );
      },
    );
  }

  BoxDecoration _buildKeyboardBackgroundDecoration(NoxKeyboardTheme theme, double animValue) {
    if (theme.animationType == 'aurora' && theme.gradientColors.length >= 2) {
      final beginAlign = Alignment(-1.0 + animValue * 2.0, -1.0);
      final endAlign = Alignment(1.0 - animValue * 2.0, 1.0);
      return BoxDecoration(
        color: theme.backgroundColor,
        gradient: LinearGradient(
          begin: beginAlign,
          end: endAlign,
          colors: [
            theme.backgroundColor,
            theme.gradientColors[0].withOpacity(0.14),
            theme.gradientColors[1].withOpacity(0.12),
            theme.backgroundColor,
          ],
        ),
      );
    }
    if (theme.animationType == 'rgb_wave') {
      final hue = (animValue * 360.0) % 360.0;
      final c1 = HSVColor.fromAHSV(0.10, hue, 0.85, 1.0).toColor();
      final c2 = HSVColor.fromAHSV(0.08, (hue + 120) % 360, 0.85, 1.0).toColor();
      return BoxDecoration(
        color: theme.backgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, theme.backgroundColor, c2],
        ),
      );
    }
    if (theme.animationType == 'cyber_scan' && theme.gradientColors.length >= 2) {
      return BoxDecoration(
        color: theme.backgroundColor,
        gradient: LinearGradient(
          begin: Alignment(-1.2 + animValue * 2.4, -0.5),
          end: Alignment(-0.2 + animValue * 2.4, 0.5),
          colors: [
            theme.backgroundColor,
            theme.gradientColors[0].withOpacity(0.12),
            theme.gradientColors[1].withOpacity(0.10),
            theme.backgroundColor,
          ],
        ),
      );
    }
    return BoxDecoration(color: theme.backgroundColor);
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

  Widget _buildKeyGrid(NoxKeyboardTheme theme, double animValue) {
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
                children: List.generate(
                  numberRow.keys.length,
                  (col) => KeyboardKeyWidget(
                    keyboardKey: numberRow.keys[col],
                    theme: theme,
                    engine: _engine,
                    animValue: animValue,
                    colIndex: col,
                    rowIndex: 0,
                  ),
                ),
              ),
            ),

          // Standard layout rows
          ...List.generate(page.rows.length, (rowIdx) {
            final row = page.rows[rowIdx];
            return Expanded(
              child: Row(
                children: List.generate(
                  row.keys.length,
                  (col) => KeyboardKeyWidget(
                    keyboardKey: row.keys[col],
                    theme: theme,
                    engine: _engine,
                    animValue: animValue,
                    colIndex: col,
                    rowIndex: rowIdx + (numberRow != null ? 1 : 0),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
