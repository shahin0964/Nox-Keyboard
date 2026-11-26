import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';

class KeyPreviewPopup extends StatelessWidget {
  final String label;
  final NoxKeyboardTheme theme;
  final double keyWidth;
  final double keyHeight;

  const KeyPreviewPopup({
    super.key,
    required this.label,
    required this.theme,
    this.keyWidth = 36,
    this.keyHeight = 46,
  });

  @override
  Widget build(BuildContext context) {
    final double popupWidth = keyWidth + 4;
    const double popupHeight = 40.0;
    final Color popupBg = theme.isDark
        ? (Color.lerp(theme.keyPressedColor, Colors.white, 0.14) ?? theme.keyPressedColor)
        : theme.keyPressedColor;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        decoration: BoxDecoration(
          color: popupBg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: theme.accentColor.withOpacity(0.65),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.isDark ? 0.45 : 0.18),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: theme.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
