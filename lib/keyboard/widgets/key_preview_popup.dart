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
    this.keyWidth = 42,
    this.keyHeight = 44,
  });

  @override
  Widget build(BuildContext context) {
    final double popupWidth = keyWidth + 8;
    final double popupHeight = keyHeight + 26;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        decoration: BoxDecoration(
          color: theme.keyPressedColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.keyBorderWidth > 0
                ? theme.keyBorderColor
                : Colors.white.withOpacity(theme.isDark ? 0.12 : 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.isDark ? 0.45 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Upper magnified letter area (Gboard style)
            Container(
              height: 32,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
