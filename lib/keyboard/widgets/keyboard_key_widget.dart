import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../data/preferences_helper.dart';
import '../../languages/language_manager.dart';
import '../../services/ime_platform_bridge.dart';
import '../layouts/keyboard_layout.dart';
import '../engine/keyboard_engine.dart';
import '../engine/haptic_sound_service.dart';
import 'key_preview_popup.dart';
import 'long_press_dialog.dart';

class KeyboardKeyWidget extends StatefulWidget {
  final KeyboardKey keyboardKey;
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;
  final double animValue;
  final int colIndex;
  final int rowIndex;
  final ValueChanged<Offset>? onTapOrigin;

  const KeyboardKeyWidget({
    super.key,
    required this.keyboardKey,
    required this.theme,
    required this.engine,
    this.animValue = 0.0,
    this.colIndex = 0,
    this.rowIndex = 0,
    this.onTapOrigin,
  });

  @override
  State<KeyboardKeyWidget> createState() => _KeyboardKeyWidgetState();
}

class _KeyboardKeyWidgetState extends State<KeyboardKeyWidget> {
  bool _isPressed = false;
  OverlayEntry? _previewEntry;
  OverlayEntry? _alternatesEntry;
  Timer? _longPressTimer;
  Timer? _repeatTimer;
  Timer? _previewDismissTimer;
  Offset _pointerDownPosition = Offset.zero;
  bool _hasTriggeredLongPress = false;
  bool _hasDraggedSpace = false;
  double _screenWidth = 360.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.sizeOf(context).width;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
    _previewDismissTimer?.cancel();
    _removeOverlays();
    super.dispose();
  }

  void _removeOverlays() {
    _previewEntry?.remove();
    _previewEntry = null;
    _alternatesEntry?.remove();
    _alternatesEntry = null;
  }

  String _getEffectiveChar() {
    final k = widget.keyboardKey;
    if (k.action != KeyAction.character) return k.primary;
    final isShifted = widget.engine.isShifted || widget.engine.isCapsLock;
    return isShifted ? k.primary.toUpperCase() : k.primary;
  }

  void _showPreviewPopup() {
    if (!PreferencesHelper().popupOnKeypress) return;
    if (widget.keyboardKey.action != KeyAction.character) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final char = _getEffectiveChar();
    final popupWidth = size.width + 4;
    final clampedLeft = (offset.dx - 2).clamp(2.0, (_screenWidth - popupWidth - 2.0).clamp(2.0, _screenWidth));
    final clampedTop = (offset.dy - 44).clamp(2.0, double.infinity);

    _previewDismissTimer?.cancel();
    _previewEntry?.remove();
    _previewEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: clampedLeft,
          top: clampedTop,
          child: KeyPreviewPopup(
            label: char,
            theme: widget.theme,
            keyWidth: size.width,
            keyHeight: size.height,
          ),
        );
      },
    );

    Overlay.of(context).insert(_previewEntry!);
  }

  void _schedulePreviewDismiss() {
    _previewDismissTimer?.cancel();
    _previewDismissTimer = Timer(const Duration(milliseconds: 55), () {
      _previewEntry?.remove();
      _previewEntry = null;
    });
  }

  void _showAlternatesPopup() {
    final alternates = widget.keyboardKey.alternateChars;
    if (alternates.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _previewDismissTimer?.cancel();
    _previewEntry?.remove();
    _previewEntry = null;

    _alternatesEntry?.remove();
    _hasTriggeredLongPress = true;

    _alternatesEntry = OverlayEntry(
      builder: (context) {
        final popupWidth = alternates.length * 40.0 + 16.0;
        double left = offset.dx + (size.width - popupWidth) / 2;
        if (left < 10) left = 10;
        if (left + popupWidth > _screenWidth - 10) left = _screenWidth - popupWidth - 10;

        return Positioned(
          left: left,
          top: offset.dy - 56,
          child: LongPressAlternatesPopup(
            alternates: alternates,
            theme: widget.theme,
            onSelect: (selectedChar) {
              _removeOverlays();
              widget.engine.onKeyPress(
                widget.keyboardKey.copyWith(primary: selectedChar),
                bypassAutoKar: true,
              );
            },
          ),
        );
      },
    );

    Overlay.of(context).insert(_alternatesEntry!);
  }

  // --- Instant Pointer Event Handlers ---

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _hasTriggeredLongPress = false;
    _hasDraggedSpace = false;
    if (!_isPressed) setState(() => _isPressed = true);
    widget.onTapOrigin?.call(event.position);

    final k = widget.keyboardKey;
    final feedbackEffect = (k.action == KeyAction.space || k.action == KeyAction.backspace || k.action == KeyAction.enter) ? 1 : 0;
    // Instant 0ms haptic + sound on touch down before finger even lifts
    HapticSoundService().onKeyFeedback(feedbackEffect);

    if (k.action == KeyAction.character) {
      _showPreviewPopup();
      if (k.alternateChars.isNotEmpty) {
        _longPressTimer = Timer(const Duration(milliseconds: 340), () {
          _showAlternatesPopup();
        });
      }
    } else if (k.action == KeyAction.backspace) {
      widget.engine.onKeyPress(k, skipFeedback: true);
      _longPressTimer = Timer(const Duration(milliseconds: 360), () {
        _repeatTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
          widget.engine.onKeyPress(k);
        });
      });
    } else if (k.action == KeyAction.space) {
      // Long-press spacebar switches language; swipe glides cursor; tap commits space on up
      _longPressTimer = Timer(const Duration(milliseconds: 420), () {
        _hasTriggeredLongPress = true;
        ImePlatformBridge().performHaptic(20);
        LanguageManager().cycleNextLanguage();
      });
    } else {
      widget.engine.onKeyPress(k, skipFeedback: true);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final distance = (event.position - _pointerDownPosition).distance;

    if (distance > 16) {
      _longPressTimer?.cancel();
    }

    // Spacebar cursor glide
    if (widget.keyboardKey.action == KeyAction.space) {
      final delta = event.localDelta.dx;
      if (distance > 12) {
        _hasDraggedSpace = true;
      }
      if (delta.abs() > 4) {
        widget.engine.onSpaceDragUpdate(DragUpdateDetails(
          globalPosition: event.position,
          delta: Offset(delta, 0),
          primaryDelta: delta,
        ));
      }
    }

    // Backspace swipe delete
    if (widget.keyboardKey.action == KeyAction.backspace) {
      final diffX = event.position.dx - _pointerDownPosition.dx;
      if (diffX < -50) {
        _repeatTimer?.cancel();
        _longPressTimer?.cancel();
        widget.engine.handleSwipeDelete();
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
    _schedulePreviewDismiss();
    if (_isPressed) setState(() => _isPressed = false);

    final k = widget.keyboardKey;

    if (k.action == KeyAction.character) {
      if (!_hasTriggeredLongPress) {
        final charToCommit = _getEffectiveChar();
        widget.engine.onKeyPress(k.copyWith(primary: charToCommit), skipFeedback: true);
      }
    } else if (k.action == KeyAction.space) {
      if (!_hasDraggedSpace && !_hasTriggeredLongPress) {
        widget.engine.onKeyPress(k, skipFeedback: true);
      }
      widget.engine.onSpaceDragEnd(DragEndDetails());
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
    _schedulePreviewDismiss();
    if (_isPressed) setState(() => _isPressed = false);

    final k = widget.keyboardKey;
    if (k.action == KeyAction.character) {
      final distance = (event.position - _pointerDownPosition).distance;
      if (distance < 42 && !_hasTriggeredLongPress) {
        final charToCommit = _getEffectiveChar();
        widget.engine.onKeyPress(k.copyWith(primary: charToCommit), skipFeedback: true);
      }
    } else if (k.action == KeyAction.space) {
      if (!_hasDraggedSpace && !_hasTriggeredLongPress) {
        widget.engine.onKeyPress(k, skipFeedback: true);
      }
      widget.engine.onSpaceDragEnd(DragEndDetails());
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.keyboardKey;
    final isSpecial = k.action != KeyAction.character;
    final isShift = k.action == KeyAction.shift;
    final isEnter = k.action == KeyAction.enter;

    final isShiftActive = isShift && (widget.engine.isShifted || widget.engine.isCapsLock);
    final shape = widget.theme.keyShape;
    final animType = widget.theme.animationType;

    // Distinct key geometry per theme style
    double borderRadius;
    if (isSpecial && shape != 'cyber_sharp' && shape != 'mechanical_3d') {
      borderRadius = 22.0;
    } else {
      switch (shape) {
        case 'pill':
          borderRadius = 22.0;
          break;
        case 'soft_blob':
          borderRadius = 16.0;
          break;
        case 'cyber_sharp':
          borderRadius = 4.0;
          break;
        case 'mechanical_3d':
          borderRadius = 7.0;
          break;
        case 'glass_frost':
          borderRadius = 12.0;
          break;
        case 'neon_outline':
          borderRadius = 10.0;
          break;
        default:
          borderRadius = widget.theme.keyBorderRadius;
      }
    }

    // Dynamic animated accent color
    Color dynamicAccent = widget.theme.accentColor;
    if (animType == 'rgb_wave') {
      final hue = (widget.animValue * 360.0 + widget.colIndex * 24.0 + widget.rowIndex * 18.0) % 360.0;
      dynamicAccent = HSVColor.fromAHSV(1.0, hue, 0.88, 1.0).toColor();
    } else if (animType == 'cyber_scan') {
      final phase = (math.sin((widget.animValue * 2 * math.pi) - widget.colIndex * 0.45) + 1) * 0.5;
      dynamicAccent = Color.lerp(
            const Color(0xFFFF2A85),
            const Color(0xFF00E5FF),
            phase,
          ) ??
          widget.theme.accentColor;
    } else if (animType == 'aurora' && widget.theme.gradientColors.length >= 2) {
      final phase = (math.sin((widget.animValue * 2 * math.pi) + widget.colIndex * 0.35) + 1) * 0.5;
      dynamicAccent = Color.lerp(
            widget.theme.gradientColors[0],
            widget.theme.gradientColors[1],
            phase,
          ) ??
          widget.theme.accentColor;
    } else if (animType == 'shimmer') {
      final wavePos = widget.animValue * 14.0 - 2.0;
      final dist = (widget.colIndex + widget.rowIndex * 0.6 - wavePos).abs();
      final glow = (1.0 - (dist / 2.6)).clamp(0.0, 1.0);
      dynamicAccent = Color.lerp(widget.theme.accentColor, Colors.white, glow * 0.55) ?? widget.theme.accentColor;
    } else if (animType == 'pulse_glow') {
      final pulse = (math.sin(widget.animValue * 2 * math.pi) + 1) * 0.5;
      dynamicAccent = Color.lerp(
            widget.theme.accentColor.withOpacity(0.55),
            widget.theme.accentColor,
            pulse,
          ) ??
          widget.theme.accentColor;
    }

    Color bg;
    final bool isHeartKey = (shape == 'heart_center') && _isHeartCell(widget.rowIndex, widget.colIndex);

    if (isHeartKey) {
      final pulse = (math.sin(widget.animValue * 2 * math.pi) + 1) * 0.5;
      bg = Color.lerp(
            const Color(0xFF6B0B24),
            const Color(0xFFFF1744),
            _isPressed ? 0.95 : (0.52 + pulse * 0.28),
          ) ??
          const Color(0xFFD50032);
    } else if (isShiftActive) {
      bg = dynamicAccent.withOpacity(0.35);
    } else if (isEnter) {
      bg = _isPressed
          ? dynamicAccent.withOpacity(0.42)
          : dynamicAccent.withOpacity(0.24);
    } else if (shape == 'neon_outline') {
      bg = _isPressed
          ? dynamicAccent.withOpacity(0.25)
          : widget.theme.keyColor.withOpacity(0.35);
    } else if (shape == 'glass_frost') {
      bg = (_isPressed ? widget.theme.keyPressedColor : widget.theme.keyColor)
          .withOpacity(isSpecial ? 0.58 : 0.72);
    } else if (isSpecial) {
      bg = _isPressed ? widget.theme.actionKeyPressedColor : widget.theme.actionKeyColor;
    } else {
      bg = _isPressed ? widget.theme.keyPressedColor : widget.theme.keyColor;
    }

    Color borderCol;
    double borderWidth;
    if (isHeartKey) {
      borderCol = const Color(0xFFFF5277).withOpacity(_isPressed ? 1.0 : 0.85);
      borderWidth = 1.25;
    } else if (isEnter) {
      borderCol = dynamicAccent.withOpacity(0.8);
      borderWidth = 1.3;
    } else if (animType == 'rgb_wave' || animType == 'cyber_scan' || shape == 'neon_outline') {
      borderCol = dynamicAccent.withOpacity(_isPressed ? 0.95 : 0.62);
      borderWidth = widget.theme.keyBorderWidth > 0 ? widget.theme.keyBorderWidth : 1.1;
    } else if (animType == 'aurora' || animType == 'pulse_glow' || animType == 'shimmer') {
      borderCol = dynamicAccent.withOpacity(_isPressed ? 0.85 : 0.42);
      borderWidth = 1.0;
    } else if (widget.theme.keyBorderWidth > 0) {
      borderCol = widget.theme.keyBorderColor;
      borderWidth = widget.theme.keyBorderWidth;
    } else {
      borderCol = Colors.white.withOpacity(widget.theme.isDark ? 0.09 : 0.22);
      borderWidth = 0.8;
    }

    Widget content = _buildKeyContent(k, isShiftActive);

    final bool isMech3D = shape == 'mechanical_3d';
    final double pressDepthOffset = (isMech3D && _isPressed) ? 2.0 : 0.0;

    // Fast, zero-jank Transform.scale instead of 35 heavy AnimatedScale + BoxShadow blurs
    Widget keyContainer = Transform.scale(
      scale: _isPressed ? 0.92 : 1.0,
      child: Container(
        margin: EdgeInsets.only(
          left: widget.theme.keyMarginH,
          right: widget.theme.keyMarginH,
          top: widget.theme.keyMarginV + pressDepthOffset,
          bottom: (widget.theme.keyMarginV - pressDepthOffset).clamp(1.0, 12.0),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: (shape == 'neon_outline' || shape == 'spider_web')
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _isPressed
                        ? Colors.transparent
                        : Colors.white.withOpacity(
                            isHeartKey
                                ? 0.28
                                : (shape == 'glass_frost' ? 0.16 : (widget.theme.isDark ? 0.06 : 0.42)),
                          ),
                    Colors.transparent,
                  ],
                ),
          border: isMech3D
              ? Border(
                  top: BorderSide(color: Colors.white.withOpacity(widget.theme.isDark ? 0.14 : 0.65), width: 1.0),
                  left: BorderSide(color: borderCol, width: 0.9),
                  right: BorderSide(color: borderCol, width: 0.9),
                  bottom: BorderSide(
                    color: isEnter
                        ? dynamicAccent.withOpacity(0.85)
                        : Colors.black.withOpacity(widget.theme.isDark ? 0.55 : 0.25),
                    width: _isPressed ? 1.5 : 3.8,
                  ),
                )
              : Border.all(
                  color: borderCol,
                  width: borderWidth,
                ),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );

    return Expanded(
      flex: k.flex,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: keyContainer,
      ),
    );
  }

  bool _isHeartCell(int row, int col) {
    if (row == 0) return col == 3 || col == 4 || col == 6 || col == 7;
    if (row == 1) return col >= 2 && col <= 6;
    if (row == 2) return col >= 3 && col <= 5;
    return false;
  }

  Widget _buildKeyContent(KeyboardKey k, bool isShiftActive) {
    if (k.action == KeyAction.shift) {
      return Icon(
        widget.engine.isCapsLock
            ? CupertinoIcons.capslock_fill
            : (isShiftActive ? CupertinoIcons.arrow_up_circle_fill : CupertinoIcons.arrow_up),
        size: 20,
        color: isShiftActive ? widget.theme.accentColor : widget.theme.textColor,
      );
    }

    if (k.action == KeyAction.backspace) {
      return Icon(
        CupertinoIcons.delete_left,
        size: 22,
        color: widget.theme.textColor,
      );
    }

    if (k.action == KeyAction.enter) {
      IconData enterIcon;
      switch (widget.engine.actionLabel) {
        case 'SEARCH':
          enterIcon = CupertinoIcons.search;
          break;
        case 'SEND':
          enterIcon = CupertinoIcons.paperplane_fill;
          break;
        case 'GO':
        case 'NEXT':
          enterIcon = CupertinoIcons.arrow_right;
          break;
        case 'DONE':
          enterIcon = CupertinoIcons.check_mark;
          break;
        default:
          enterIcon = CupertinoIcons.return_icon;
      }
      return Icon(
        enterIcon,
        size: 20,
        color: widget.theme.accentColor,
      );
    }

    if (k.action == KeyAction.space) {
      final lang = LanguageManager().currentLanguage;
      final label = lang.nativeName;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.theme.secondaryTextColor.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: widget.theme.secondaryTextColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.theme.secondaryTextColor.withOpacity(0.4),
            ),
          ),
        ],
      );
    }

    if (k.action == KeyAction.switchLanguage) {
      return const Text(
        '🌐',
        style: TextStyle(fontSize: 17),
      );
    }

    if (k.action == KeyAction.emoji) {
      return Icon(
        CupertinoIcons.smiley,
        size: 20,
        color: widget.theme.textColor,
      );
    }

    if (k.action == KeyAction.switchSymbols ||
        k.action == KeyAction.switchMoreSymbols ||
        k.action == KeyAction.switchLetters) {
      return Text(
        k.primary,
        style: TextStyle(
          color: widget.theme.textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Standard character key with dynamic Shift Uppercase / Lowercase or Key Command Mode rendering
    final isKeyCmd = widget.engine.isKeyCommandMode && widget.engine.mode == KeyboardMode.letters;
    final cmdLabel = isKeyCmd ? widget.engine.getCommandLabelForKey(k.primary) : null;
    final hasSecondary = cmdLabel == null && k.secondary != null;
    final displayChar = cmdLabel != null ? k.primary.toUpperCase() : _getEffectiveChar();
    final isSixRow = widget.engine.activePage.rows.length >= 6;
    final charFontSize = isSixRow
        ? (widget.theme.fontSize - 1.5).clamp(15.0, 20.0)
        : widget.theme.fontSize;

    if (cmdLabel != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayChar,
            style: TextStyle(
              color: widget.theme.accentColor,
              fontSize: (charFontSize - 2.5).clamp(13.0, 17.0),
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1.5),
          Text(
            cmdLabel,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: widget.theme.textColor.withOpacity(0.82),
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Center(
          child: Text(
            displayChar,
            style: TextStyle(
              color: widget.theme.textColor,
              fontSize: charFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (hasSecondary)
          Positioned(
            top: 1.5,
            right: 3.5,
            child: Text(
              k.secondary!,
              style: TextStyle(
                color: widget.theme.secondaryTextColor.withOpacity(0.62),
                fontSize: isSixRow ? 9.0 : 10.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
