import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/ime_platform_bridge.dart';

class SelectDefaultScreen extends StatefulWidget {
  const SelectDefaultScreen({super.key});

  @override
  State<SelectDefaultScreen> createState() => _SelectDefaultScreenState();
}

class _SelectDefaultScreenState extends State<SelectDefaultScreen> {
  final ImePlatformBridge _bridge = ImePlatformBridge();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final res = await _bridge.isKeyboardDefault();
    if (mounted) setState(() => _isDefault = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select as Default')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isDefault ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.arrow_up_right_circle_fill,
              size: 80,
              color: _isDefault ? const Color(0xFF10B981) : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              _isDefault ? 'Nox is Your Default Keyboard!' : 'Set Nox as Default Keyboard',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _isDefault
                  ? 'Nox Keyboard will now appear automatically when you tap any text field.'
                  : 'Tap below to open the Input Method dialog and select Nox Keyboard.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(CupertinoIcons.checkmark),
              label: const Text('Choose Input Method'),
              onPressed: () async {
                await _bridge.showInputMethodPicker();
                Future.delayed(const Duration(seconds: 1), _check);
              },
            ),
          ],
        ),
      ),
    );
  }
}
