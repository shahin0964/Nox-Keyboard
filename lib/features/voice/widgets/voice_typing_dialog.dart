import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../languages/language_manager.dart';
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

class _VoiceTypingPanelState extends State<VoiceTypingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ImePlatformBridge _bridge = ImePlatformBridge();

  bool _isListening = false;
  bool _needsPermission = false;
  String _statusText = 'Tap mic to speak';
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bridge.onVoiceStateCallback = (state) {
      if (!mounted) return;
      setState(() {
        if (state == 'listening' || state == 'speaking') {
          _isListening = true;
          _needsPermission = false;
          _statusText = state == 'speaking' ? 'Listening...' : 'Speak now...';
          if (!_animController.isAnimating) _animController.repeat(reverse: true);
        } else if (state == 'processing') {
          _statusText = 'Processing...';
        }
      });
    };

    _bridge.onVoiceResultCallback = (text, isFinal) {
      if (!mounted) return;
      setState(() {
        _recognizedText = text;
        if (isFinal) {
          _isListening = false;
          _animController.stop();
          _statusText = text.isNotEmpty ? 'Inserted! Tap mic to speak again' : 'No speech detected';
        }
      });
      if (isFinal && text.trim().isNotEmpty) {
        _bridge.commitText('${text.trim()} ');
      }
    };

    _bridge.onVoiceErrorCallback = (error) {
      if (!mounted) return;
      _animController.stop();
      setState(() {
        _isListening = false;
        if (error == 'PERMISSION_REQUIRED') {
          _needsPermission = true;
          _statusText = 'Microphone permission required';
        } else if (error == 'UNAVAILABLE') {
          _statusText = 'Voice recognition unavailable on device';
        } else if (error == 'NO_SPEECH') {
          _statusText = 'Didn\'t catch that. Tap mic to retry';
        } else if (error == 'NETWORK') {
          _statusText = 'Network error. Check internet & retry';
        } else {
          _statusText = 'Tap mic to speak ($error)';
        }
      });
    };

    _startListening();
  }

  Future<void> _startListening() async {
    final langCode = LanguageManager().currentLanguage.code;
    setState(() {
      _needsPermission = false;
      _statusText = 'Starting mic...';
      _recognizedText = '';
    });
    final ok = await _bridge.startVoiceRecognition(langCode);
    if (ok && mounted) {
      setState(() {
        _isListening = true;
        _statusText = 'Speak now...';
      });
      _animController.repeat(reverse: true);
    }
  }

  Future<void> _stopListening() async {
    await _bridge.stopVoiceRecognition();
    _animController.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusText = 'Tap mic to speak';
      });
    }
  }

  @override
  void dispose() {
    _bridge.stopVoiceRecognition();
    _bridge.onVoiceResultCallback = null;
    _bridge.onVoiceErrorCallback = null;
    _bridge.onVoiceStateCallback = null;
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final langName = LanguageManager().currentLanguage.nativeName;

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          // Top row: language badge + close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(theme.isDark ? 0.07 : 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Voice • $langName',
                  style: TextStyle(
                    color: theme.secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              InkWell(
                onTap: () => widget.engine.closePanel(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(CupertinoIcons.clear_circled_solid, color: theme.secondaryTextColor, size: 22),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Pulsing mic button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = _isListening ? (1.0 + _animController.value * 0.22) : 1.0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 66 * scale,
                      height: 66 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentColor.withOpacity(_isListening ? 0.22 * (1.0 - _animController.value) : 0.08),
                      ),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? theme.accentColor : theme.keyColor,
                        border: Border.all(color: theme.accentColor.withOpacity(0.7), width: 1.5),
                      ),
                      child: Icon(
                        _isListening ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                        color: _isListening ? Colors.black : theme.accentColor,
                        size: 26,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _recognizedText.isNotEmpty ? _recognizedText : _statusText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _recognizedText.isNotEmpty ? theme.textColor : theme.secondaryTextColor,
              fontSize: 14,
              fontWeight: _recognizedText.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
            ),
          ),

          if (_needsPermission) ...[
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => _bridge.requestAudioPermissionFromSettings(),
              child: const Text('Grant Mic Permission', style: TextStyle(fontSize: 12)),
            ),
          ],

          const Spacer(),
        ],
      ),
    );
  }
}
