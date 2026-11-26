import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';

class KeyPreviewPopup extends StatefulWidget {
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
  State<KeyPreviewPopup> createState() => _KeyPreviewPopupState();
}

class _KeyPreviewPopupState extends State<KeyPreviewPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    // Compact Gboard-style floating key bubble
    final double popupWidth = widget.keyWidth + 4;
    const double popupHeight = 40.0;
    final Color popupBg = theme.isDark
        ? (Color.lerp(theme.keyPressedColor, Colors.white, 0.14) ?? theme.keyPressedColor)
        : theme.keyPressedColor;

    return Material(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomCenter,
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
                color: Colors.black.withOpacity(theme.isDark ? 0.5 : 0.2),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: theme.accentColor.withOpacity(0.18),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
