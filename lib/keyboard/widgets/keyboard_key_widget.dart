import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../data/preferences_helper.dart';
import '../layouts/keyboard_layout.dart';
import '../engine/keyboard_engine.dart';
import 'key_preview_popup.dart';
import 'long_press_dialog.dart';

class KeyboardKeyWidget extends StatefulWidget {
  final KeyboardKey keyboardKey;
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const KeyboardKeyWidget({
    super.key,
    required this.keyboardKey,
    required this.theme,
    required this.engine,
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
  Offset _pointerDownPosition = Offset.zero;
  bool _hasTriggeredLongPress = false;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
    _removeOverlays();
    super.dispose();
  }

  void _removeOverlays() {
    _previewEntry?.remove();
    _previewEntry = null;
    _alternatesEntry?.remove();
    _alternatesEntry = null;
  }

  void _showPreviewPopup() {
    if (!PreferencesHelper().popupOnKeypress) return;
    if (widget.keyboardKey.action != KeyAction.character) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _previewEntry?.remove();
    _previewEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx - 4,
          top: offset.dy - 26,
          child: KeyPreviewPopup(
            label: widget.keyboardKey.primary,
            theme: widget.theme,
            keyWidth: size.width,
            keyHeight: size.height,
          ),
        );
      },
    );

    Overlay.of(context).insert(_previewEntry!);
  }

  void _hidePreviewPopup() {
    _previewEntry?.remove();
    _previewEntry = null;
  }

  void _showAlternatesPopup() {
    final alternates = widget.keyboardKey.alternateChars;
    if (alternates.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _hidePreviewPopup();
    _alternatesEntry?.remove();
    _hasTriggeredLongPress = true;

    _alternatesEntry = OverlayEntry(
      builder: (context) {
        final popupWidth = alternates.length * 40.0 + 16.0;
        final screenWidth = MediaQuery.of(context).size.width;
        double left = offset.dx + (size.width - popupWidth) / 2;
        if (left < 10) left = 10;
        if (left + popupWidth > screenWidth - 10) left = screenWidth - popupWidth - 10;

        return Positioned(
          left: left,
          top: offset.dy - 56,
          child: LongPressAlternatesPopup(
            alternates: alternates,
            theme: widget.theme,
            onSelect: (selectedChar) {
              _removeOverlays();
              widget.engine.onKeyPress(widget.keyboardKey.copyWith(primary: selectedChar));
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
    setState(() => _isPressed = true);

    final k = widget.keyboardKey;

    if (k.action == KeyAction.character) {
      _showPreviewPopup();
      if (k.alternateChars.isNotEmpty) {
        _longPressTimer = Timer(const Duration(milliseconds: 350), () {
          _showAlternatesPopup();
        });
      }
    } else if (k.action == KeyAction.backspace) {
      widget.engine.onKeyPress(k);
      _longPressTimer = Timer(const Duration(milliseconds: 380), () {
        _repeatTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
          widget.engine.onKeyPress(k);
        });
      });
    } else if (k.action == KeyAction.space) {
      widget.engine.onKeyPress(k);
    } else {
      widget.engine.onKeyPress(k);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final distance = (event.position - _pointerDownPosition).distance;

    if (distance > 24) {
      _longPressTimer?.cancel();
    }

    // Spacebar cursor glide
    if (widget.keyboardKey.action == KeyAction.space) {
      final delta = event.localDelta.dx;
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
    _hidePreviewPopup();
    setState(() => _isPressed = false);

    final k = widget.keyboardKey;

    if (k.action == KeyAction.character) {
      if (!_hasTriggeredLongPress) {
        widget.engine.onKeyPress(k);
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
    _hidePreviewPopup();
    setState(() => _isPressed = false);

    final k = widget.keyboardKey;
    if (k.action == KeyAction.character) {
      final distance = (event.position - _pointerDownPosition).distance;
      if (distance < 20 && !_hasTriggeredLongPress) {
        widget.engine.onKeyPress(k);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.keyboardKey;
    final isSpecial = k.action != KeyAction.character;
    final isShift = k.action == KeyAction.shift;
    final isEnter = k.action == KeyAction.enter;

    final isShiftActive = isShift && (widget.engine.isShifted || widget.engine.isCapsLock);

    // Pill styling for action keys
    final double borderRadius = isSpecial
        ? 20.0
        : widget.theme.keyBorderRadius;

    Color bg;
    if (isShiftActive) {
      bg = widget.theme.accentColor.withOpacity(0.35);
    } else if (isEnter) {
      bg = _isPressed
          ? widget.theme.accentColor.withOpacity(0.4)
          : widget.theme.accentColor.withOpacity(0.22);
    } else if (isSpecial) {
      bg = _isPressed ? widget.theme.actionKeyPressedColor : widget.theme.actionKeyColor;
    } else {
      bg = _isPressed ? widget.theme.keyPressedColor : widget.theme.keyColor;
    }

    Widget content = _buildKeyContent(k, isShiftActive);

    Widget keyContainer = Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.theme.keyMarginH,
        vertical: widget.theme.keyMarginV,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _isPressed
                ? Colors.transparent
                : Colors.white.withOpacity(widget.theme.isDark ? 0.06 : 0.4),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: isEnter
              ? widget.theme.accentColor.withOpacity(0.6)
              : (widget.theme.keyBorderWidth > 0
                  ? widget.theme.keyBorderColor
                  : Colors.white.withOpacity(widget.theme.isDark ? 0.08 : 0.18)),
          width: isEnter ? 1.2 : (widget.theme.keyBorderWidth > 0 ? widget.theme.keyBorderWidth : 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.theme.isDark ? 0.3 : 0.08),
            offset: const Offset(0, 1.5),
            blurRadius: 1.5,
          ),
          if (isEnter)
            BoxShadow(
              color: widget.theme.accentColor.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: content,
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
            'English / বাংলা',
            style: TextStyle(
              color: widget.theme.secondaryTextColor.withOpacity(0.75),
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

    // Standard character key
    final hasSecondary = k.secondary != null;

    return Stack(
      children: [
        Center(
          child: Text(
            k.primary,
            style: TextStyle(
              color: widget.theme.textColor,
              fontSize: widget.theme.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (hasSecondary)
          Positioned(
            top: 2,
            right: 4,
            child: Text(
              k.secondary!,
              style: TextStyle(
                color: widget.theme.secondaryTextColor.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
