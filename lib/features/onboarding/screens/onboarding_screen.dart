import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/preferences_helper.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../keyboard/widgets/keyboard_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final ImePlatformBridge _bridge = ImePlatformBridge();
  final PreferencesHelper _prefs = PreferencesHelper();

  int _currentStep = 1;
  bool _isEnabled = false;
  bool _isDefault = false;
  final TextEditingController _testInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final enabled = await _bridge.isKeyboardEnabled();
    final isDef = await _bridge.isKeyboardDefault();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isDefault = isDef;
        if (!_isEnabled) {
          _currentStep = 1;
        } else if (!_isDefault) {
          _currentStep = 2;
        } else {
          _currentStep = 3;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Nox Keyboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              await _prefs.setOnboardingCompleted(true);
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              }
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildStepPill(1, 'Enable', _currentStep >= 1, _isEnabled),
                  _buildStepDivider(_currentStep > 1),
                  _buildStepPill(2, 'Select', _currentStep >= 2, _isDefault),
                  _buildStepDivider(_currentStep > 2),
                  _buildStepPill(3, 'Test', _currentStep >= 3, _isEnabled && _isDefault),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildCurrentStepContent(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPill(int step, String label, bool isActive, bool isDone) {
    final color = isDone
        ? const Color(0xFF10B981)
        : (isActive ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.4));

    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text('$step', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? null : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: isActive ? const Color(0xFF10B981) : Colors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    if (_currentStep == 1) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Icon(CupertinoIcons.keyboard, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          const Text(
            'Step 1: Enable Nox Keyboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'To use Nox Keyboard across Android applications, enable it in your device\'s Virtual Keyboard settings.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(CupertinoIcons.gear_alt_fill),
            label: const Text('Open Keyboard Settings', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await _bridge.openInputMethodSettings();
              Future.delayed(const Duration(seconds: 1), _checkStatus);
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _checkStatus,
            child: const Text('I Have Enabled It'),
          ),
        ],
      );
    } else if (_currentStep == 2) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Icon(CupertinoIcons.checkmark_shield_fill, size: 80, color: Color(0xFF10B981)),
          const SizedBox(height: 20),
          const Text(
            'Step 2: Select as Default Keyboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Make Nox Keyboard your primary typing input method so it appears whenever you tap a text field.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(CupertinoIcons.checkmark_alt_circle_fill),
            label: const Text('Select Input Method', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await _bridge.showInputMethodPicker();
              Future.delayed(const Duration(seconds: 1), _checkStatus);
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _checkStatus,
            child: const Text('Check Status'),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 10),
          const Icon(CupertinoIcons.sparkles, size: 50, color: Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          const Text(
            'Ready! Test Your Keyboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Type below to test English, Bangla phonetic transliteration, emojis, and suggestions.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _testInputController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tap here to type (e.g. ami bangla bhalobashi)...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              prefixIcon: const Icon(CupertinoIcons.text_cursor),
              suffixIcon: IconButton(
                icon: const Icon(CupertinoIcons.clear_circled),
                onPressed: () => _testInputController.clear(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.done_all),
            label: const Text('Finish Setup & Go to Home', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await _prefs.setOnboardingCompleted(true);
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              }
            },
          ),
        ],
      );
    }
  }
}
