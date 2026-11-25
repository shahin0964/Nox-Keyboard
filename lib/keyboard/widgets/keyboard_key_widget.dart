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

  @override
  void dispose() {
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
          left: offset.dx + (size.width - 52) / 2,
          top: offset.dy - 60,
          child: KeyPreviewPopup(
            label: widget.keyboardKey.primary,
            theme: widget.theme,
          ),
        );
      },
    );

    Overlay.of(context).insert(_previewEntry!);
  }

  void _showAlternatesPopup() {
    final alternates = widget.keyboardKey.alternateChars;
    if (alternates.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _previewEntry?.remove();
    _previewEntry = null;

    _alternatesEntry?.remove();
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

  @override
  Widget build(BuildContext context) {
    final k = widget.keyboardKey;
    final isSpecial = k.action != KeyAction.character;
    final isShift = k.action == KeyAction.shift;
    final isSpace = k.action == KeyAction.space;
    final isBackspace = k.action == KeyAction.backspace;

    // Shift highlighting
    final isShiftActive = isShift && (widget.engine.isShifted || widget.engine.isCapsLock);

    Color bg;
    if (isShiftActive) {
      bg = widget.theme.accentColor.withOpacity(0.3);
    } else if (isSpecial) {
      bg = _isPressed ? widget.theme.actionKeyPressedColor : widget.theme.actionKeyColor;
    } else {
      bg = _isPressed ? widget.theme.keyPressedColor : widget.theme.keyColor;
    }

    Widget content = _buildKeyContent(k, isShiftActive);

    Widget keyContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      margin: EdgeInsets.symmetric(
        horizontal: widget.theme.keyMarginH,
        vertical: widget.theme.keyMarginV,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.theme.keyBorderRadius),
        border: widget.theme.keyBorderWidth > 0
            ? Border.all(
                color: widget.theme.keyBorderColor,
                width: widget.theme.keyBorderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.theme.isDark ? 0.25 : 0.08),
            offset: const Offset(0, 1.5),
            blurRadius: 1.0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: content,
    );

    // Gestures
    if (isSpace) {
      return Expanded(
        flex: k.flex,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            widget.engine.onKeyPress(k);
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onHorizontalDragUpdate: (details) => widget.engine.onSpaceDragUpdate(details),
          onHorizontalDragEnd: (details) => widget.engine.onSpaceDragEnd(details),
          child: keyContainer,
        ),
      );
    }

    if (isBackspace) {
      return Expanded(
        flex: k.flex,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            widget.engine.onKeyPress(k);
          },
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
              widget.engine.handleSwipeDelete();
            }
          },
          child: keyContainer,
        ),
      );
    }

    return Expanded(
      flex: k.flex,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _showPreviewPopup();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _removeOverlays();
          widget.engine.onKeyPress(k);
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _removeOverlays();
        },
        onLongPress: () {
          _showAlternatesPopup();
        },
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
      return Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          enterIcon,
          size: 20,
          color: widget.theme.accentColor,
        ),
      );
    }

    if (k.action == KeyAction.space) {
      return Text(
        'English / বাংলা',
        style: TextStyle(
          color: widget.theme.secondaryTextColor.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (k.action == KeyAction.switchLanguage) {
      return Text(
        '🌐',
        style: TextStyle(fontSize: 16),
      );
    }

    if (k.action == KeyAction.emoji) {
      return Icon(
        CupertinoIcons.smiley,
        size: 20,
        color: widget.theme.textColor,
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
