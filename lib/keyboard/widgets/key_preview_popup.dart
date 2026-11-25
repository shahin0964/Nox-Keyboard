import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';

class KeyPreviewPopup extends StatefulWidget {
  final String label;
  final NoxKeyboardTheme theme;
  final bool isVisible;

  const KeyPreviewPopup({
    super.key,
    required this.label,
    required this.theme,
    this.isVisible = true,
  });

  @override
  State<KeyPreviewPopup> createState() => _KeyPreviewPopupState();
}

class _KeyPreviewPopupState extends State<KeyPreviewPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Google Gboard-style upward floating spring animation
    _scaleAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant KeyPreviewPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    } else if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomCenter,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              // Frosted glass gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.keyColor.withOpacity(theme.isDark ? 0.95 : 0.98),
                  theme.keyColor.withOpacity(theme.isDark ? 0.88 : 0.92),
                ],
              ),
              border: Border.all(
                color: theme.accentColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.isDark ? 0.5 : 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: theme.accentColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top subtle glassy highlight
                Positioned(
                  top: 0,
                  left: 10,
                  right: 10,
                  height: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(theme.isDark ? 0.25 : 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Floating character label
                Center(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
