import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/ime_platform_bridge.dart';

class EnableKeyboardScreen extends StatefulWidget {
  const EnableKeyboardScreen({super.key});

  @override
  State<EnableKeyboardScreen> createState() => _EnableKeyboardScreenState();
}

class _EnableKeyboardScreenState extends State<EnableKeyboardScreen> {
  final ImePlatformBridge _bridge = ImePlatformBridge();
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final res = await _bridge.isKeyboardEnabled();
    if (mounted) setState(() => _isEnabled = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enable Nox Keyboard')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEnabled ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.keyboard,
              size: 80,
              color: _isEnabled ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              _isEnabled ? 'Nox Keyboard is Enabled!' : 'Enable in Android Settings',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _isEnabled
                  ? 'Nox Keyboard is turned on and ready in system settings.'
                  : 'Tap the button below to open Manage Keyboards settings and toggle on Nox Keyboard.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(CupertinoIcons.gear),
              label: const Text('Open Keyboard Settings'),
              onPressed: () async {
                await _bridge.openInputMethodSettings();
                Future.delayed(const Duration(seconds: 1), _check);
              },
            ),
          ],
        ),
      ),
    );
  }
}
