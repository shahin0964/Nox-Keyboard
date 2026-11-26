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
    this.keyWidth = 44,
    this.keyHeight = 52,
  });

  @override
  State<KeyPreviewPopup> createState() => _KeyPreviewPopupState();
}

class _KeyPreviewPopupState extends State<KeyPreviewPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
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
    final double popupWidth = widget.keyWidth + 12;
    final double popupHeight = widget.keyHeight + 32;

    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: popupWidth,
            height: popupHeight,
            decoration: BoxDecoration(
              color: theme.keyPressedColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.accentColor.withOpacity(0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.isDark ? 0.5 : 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: theme.accentColor.withOpacity(0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top floating magnified character (Gboard Magnifier)
                Container(
                  height: 38,
                  alignment: Alignment.center,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
