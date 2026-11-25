import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';

class KeyPreviewPopup extends StatelessWidget {
  final String label;
  final NoxKeyboardTheme theme;

  const KeyPreviewPopup({
    super.key,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 56,
      decoration: BoxDecoration(
        color: theme.keyColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.keyBorderWidth > 0 ? theme.keyBorderColor : theme.accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: theme.textColor,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
