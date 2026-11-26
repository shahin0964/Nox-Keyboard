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
import 'spider_web_painter.dart';
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
    with TickerProviderStateMixin {
  final KeyboardEngine _engine = KeyboardEngine();
  final ThemeManager _themeManager = ThemeManager();
  final PreferencesHelper _prefs = PreferencesHelper();
  final ImePlatformBridge _bridge = ImePlatformBridge();
  final GlobalKey _gridBoxKey = GlobalKey();

  double _lastSyncedContentHeight = -1;
  late AnimationController _themeAnimController;
  late AnimationController _rippleAnimController;
  Offset? _lastRippleOrigin;

  double get _keyAreaHeight => (220.0 + (_prefs.keyboardHeight - 275.0)).clamp(175.0, 285.0);

  NoxKeyboardTheme get _activeTheme => widget.overrideTheme ?? _themeManager.currentTheme;

  @override
  void initState() {
    super.initState();
    _themeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _rippleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _updateAnimationPlayback();

    _engine.addListener(_onEngineUpdate);
    _themeManager.addListener(_onThemeUpdate);

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
    final type = _activeTheme.animationType;
    // spider_ripple runs ONLY on key taps for zero idle GPU overhead
    if (_activeTheme.isAnimated && type != 'spider_ripple') {
      if (!_themeAnimController.isAnimating) {
        _themeAnimController.repeat();
      }
    } else {
      _themeAnimController.stop();
    }
  }

  void _triggerSpiderRipple(Offset globalPos) {
    if (_activeTheme.animationType != 'spider_ripple') return;
    final box = _gridBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(globalPos);
    final nx = (local.dx / box.size.width).clamp(0.0, 1.0);
    final ny = (local.dy / box.size.height).clamp(0.0, 1.0);
    _lastRippleOrigin = Offset(nx, ny);
    _rippleAnimController.forward(from: 0.0);
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
    _rippleAnimController.dispose();
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
    final double navBarPadding = widget.isImeMode ? 60.0 : 0.0;
    final double keyAreaHeight = _keyAreaHeight;
    final double totalHeight = 40.0 + keyAreaHeight + navBarPadding;

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
        mainContent = _buildOptimizedKeyArea(theme);
    }

    Widget keyboardBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToolbarWidget(engine: _engine, theme: theme),
        SizedBox(
          height: keyAreaHeight,
          child: mainContent,
        ),
        if (navBarPadding > 0) SizedBox(height: navBarPadding),
      ],
    );

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

  Widget _buildOptimizedKeyArea(NoxKeyboardTheme theme) {
    final isSpider = theme.keyShape == 'spider_web';
    final isRipple = theme.animationType == 'spider_ripple';
    final needsContinuousAnim = theme.isAnimated && !isRipple;

    // Static or single-pass canvas themes do NOT rebuild all 35 keys on every animation tick
    Widget keyGridWidget;
    if (needsContinuousAnim && !isSpider) {
      keyGridWidget = AnimatedBuilder(
        animation: _themeAnimController,
        builder: (context, _) => _buildKeyGrid(theme, _themeAnimController.value),
      );
    } else {
      keyGridWidget = _buildKeyGrid(theme, 0.0);
    }

    if (!isSpider) {
      return RepaintBoundary(child: keyGridWidget);
    }

    // Spider Web RGB or Black Spider Ripple renders web veins in a single-pass CustomPainter layer
    return RepaintBoundary(
      key: _gridBoxKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          keyGridWidget,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: isRipple ? _rippleAnimController : _themeAnimController,
              builder: (context, _) {
                return CustomPaint(
                  painter: SpiderWebPainter(
                    isRippleMode: isRipple,
                    animValue: isRipple ? 0.0 : _themeAnimController.value,
                    rippleOrigin: _lastRippleOrigin,
                    rippleProgress: isRipple ? _rippleAnimController.value : 0.0,
                  ),
                );
              },
            ),
          ),
        ],
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
          InkWell(
            onTap: () => _engine.setOneHandedMode('none'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(theme.isDark ? 0.1 : 0.18)),
              ),
              child: Icon(CupertinoIcons.arrow_up_left_arrow_down_right, size: 17, color: theme.textColor),
            ),
          ),
          InkWell(
            onTap: () => _engine.setOneHandedMode(isLeft ? 'right' : 'left'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(theme.isDark ? 0.1 : 0.18)),
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
    final int rowOffset = numberRow != null ? 1 : 0;

    return Container(
      padding: const EdgeInsets.only(bottom: 2, left: 2, right: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
                    rowIndex: -1,
                    onTapOrigin: _triggerSpiderRipple,
                  ),
                ),
              ),
            ),

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
                    rowIndex: rowIdx,
                    onTapOrigin: _triggerSpiderRipple,
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
