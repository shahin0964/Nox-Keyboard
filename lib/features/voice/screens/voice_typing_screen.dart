import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoiceTypingScreen extends StatefulWidget {
  const VoiceTypingScreen({super.key});

  @override
  State<VoiceTypingScreen> createState() => _VoiceTypingScreenState();
}

class _VoiceTypingScreenState extends State<VoiceTypingScreen> {
  bool _voiceEnabled = true;
  bool _autoPunctuation = true;
  bool _fasterVoiceTyping = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Typing', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Info banner
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(CupertinoIcons.mic_circle_fill, size: 36, color: Color(0xFF3B82F6)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Voice typing uses on-device speech recognition whenever available to protect your privacy.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Enable Voice Typing'),
            subtitle: const Text('Show microphone icon in keyboard toolbar'),
            value: _voiceEnabled,
            onChanged: (val) => setState(() => _voiceEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Auto-Punctuation'),
            subtitle: const Text('Insert commas and periods based on vocal pauses'),
            value: _autoPunctuation,
            onChanged: (val) => setState(() => _autoPunctuation = val),
          ),
          SwitchListTile(
            title: const Text('Faster Voice Typing'),
            subtitle: const Text('Process speech recognition directly on-device'),
            value: _fasterVoiceTyping,
            onChanged: (val) => setState(() => _fasterVoiceTyping = val),
          ),
        ],
      ),
    );
  }
}
