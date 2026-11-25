import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../keyboard/engine/keyboard_engine.dart';

class VoiceTypingPanel extends StatefulWidget {
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const VoiceTypingPanel({
    super.key,
    required this.theme,
    required this.engine,
  });

  @override
  State<VoiceTypingPanel> createState() => _VoiceTypingPanelState();
}

class _VoiceTypingPanelState extends State<VoiceTypingPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isListening = true;
  String _recognizedText = 'Speak now...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Simulate voice listening ready
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _recognizedText = 'Hello from Nox Keyboard!';
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Close button in top-right
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(CupertinoIcons.clear_circled_solid, color: theme.secondaryTextColor, size: 22),
              onPressed: () => widget.engine.closePanel(),
            ),
          ),

          // Pulsing microphone orb
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final scale = 1.0 + (_animController.value * 0.25);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72 * scale,
                    height: 72 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accentColor.withOpacity(0.2 * (1.0 - _animController.value)),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: theme.accentColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.mic_fill,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Recognized speech text
          Text(
            _recognizedText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Insert text action button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(CupertinoIcons.check_mark, size: 16),
            label: const Text('Insert Text'),
            onPressed: () {
              if (_recognizedText != 'Speak now...') {
                ImePlatformBridge().commitText('$_recognizedText ');
              }
              widget.engine.closePanel();
            },
          ),
        ],
      ),
    );
  }
}
