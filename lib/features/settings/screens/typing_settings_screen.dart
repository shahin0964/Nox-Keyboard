import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/preferences_helper.dart';

class TypingSettingsScreen extends StatefulWidget {
  const TypingSettingsScreen({super.key});

  @override
  State<TypingSettingsScreen> createState() => _TypingSettingsScreenState();
}

class _TypingSettingsScreenState extends State<TypingSettingsScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();

  late bool _autoCorrection;
  late bool _nextWordPrediction;
  late bool _autoCapitalization;
  late bool _doubleSpacePeriod;
  late bool _showSuggestionsBar;
  late bool _popupOnKeypress;
  late bool _soundOnKeypress;
  late bool _vibrateOnKeypress;
  late int _vibrationIntensity;
  late double _keyboardHeight;
  late bool _showNumberRow;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  void _loadValues() {
    _autoCorrection = _prefs.autoCorrection;
    _nextWordPrediction = _prefs.nextWordPrediction;
    _autoCapitalization = _prefs.autoCapitalization;
    _doubleSpacePeriod = _prefs.doubleSpacePeriod;
    _showSuggestionsBar = _prefs.showSuggestionsBar;
    _popupOnKeypress = _prefs.popupOnKeypress;
    _soundOnKeypress = _prefs.soundOnKeypress;
    _vibrateOnKeypress = _prefs.vibrateOnKeypress;
    _vibrationIntensity = _prefs.vibrationIntensity;
    _keyboardHeight = _prefs.keyboardHeight;
    _showNumberRow = _prefs.showNumberRow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing & Smart Features', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Smart Text Input section
          _buildSectionHeader('Smart Typing & Corrections'),
          SwitchListTile(
            title: const Text('Autocorrection'),
            subtitle: const Text('Correct words automatically when pressing space'),
            value: _autoCorrection,
            onChanged: (val) async {
              await _prefs.setAutoCorrection(val);
              setState(() => _autoCorrection = val);
            },
          ),
          SwitchListTile(
            title: const Text('Next-Word Prediction'),
            subtitle: const Text('Predict likely upcoming words based on typed context'),
            value: _nextWordPrediction,
            onChanged: (val) async {
              await _prefs.setNextWordPrediction(val);
              setState(() => _nextWordPrediction = val);
            },
          ),
          SwitchListTile(
            title: const Text('Auto-Capitalization'),
            subtitle: const Text('Capitalize the first word of each sentence'),
            value: _autoCapitalization,
            onChanged: (val) async {
              await _prefs.setAutoCapitalization(val);
              setState(() => _autoCapitalization = val);
            },
          ),
          SwitchListTile(
            title: const Text('Double-Space Period'),
            subtitle: const Text('Double-tapping space inserts a period and space'),
            value: _doubleSpacePeriod,
            onChanged: (val) async {
              await _prefs.setDoubleSpacePeriod(val);
              setState(() => _doubleSpacePeriod = val);
            },
          ),
          SwitchListTile(
            title: const Text('Show Suggestions Bar'),
            subtitle: const Text('Display word candidates and autocorrect bar'),
            value: _showSuggestionsBar,
            onChanged: (val) async {
              await _prefs.setShowSuggestionsBar(val);
              setState(() => _showSuggestionsBar = val);
            },
          ),

          const Divider(height: 32),

          // Feedback & Preferences
          _buildSectionHeader('Keypress Feedback & Layout'),
          SwitchListTile(
            title: const Text('Key Press Popup'),
            subtitle: const Text('Show visual character bubble above pressed key'),
            value: _popupOnKeypress,
            onChanged: (val) async {
              await _prefs.setPopupOnKeypress(val);
              setState(() => _popupOnKeypress = val);
            },
          ),
          SwitchListTile(
            title: const Text('Sound on Keypress'),
            subtitle: const Text('Play subtle click audio on each keystroke'),
            value: _soundOnKeypress,
            onChanged: (val) async {
              await _prefs.setSoundOnKeypress(val);
              setState(() => _soundOnKeypress = val);
            },
          ),
          SwitchListTile(
            title: const Text('Vibration on Keypress'),
            subtitle: const Text('Tactile haptic feedback on keypress'),
            value: _vibrateOnKeypress,
            onChanged: (val) async {
              await _prefs.setVibrateOnKeypress(val);
              setState(() => _vibrateOnKeypress = val);
            },
          ),
          if (_vibrateOnKeypress) ...[
            ListTile(
              title: const Text('Vibration Intensity'),
              subtitle: Text('$_vibrationIntensity ms duration'),
            ),
            Slider(
              value: _vibrationIntensity.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              onChanged: (val) async {
                final intVal = val.toInt();
                await _prefs.setVibrationIntensity(intVal);
                setState(() => _vibrationIntensity = intVal);
              },
            ),
          ],
          SwitchListTile(
            title: const Text('Dedicated Number Row'),
            subtitle: const Text('Always show 0-9 digits row above letters'),
            value: _showNumberRow,
            onChanged: (val) async {
              await _prefs.setShowNumberRow(val);
              setState(() => _showNumberRow = val);
            },
          ),

          const Divider(height: 32),

          // Sizing
          _buildSectionHeader('Keyboard Height & Sizing'),
          ListTile(
            title: const Text('Keyboard Height'),
            subtitle: Text('${_keyboardHeight.toStringAsFixed(0)} dp'),
          ),
          Slider(
            value: _keyboardHeight,
            min: 220,
            max: 340,
            onChanged: (val) async {
              await _prefs.setKeyboardHeight(val);
              setState(() => _keyboardHeight = val);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
