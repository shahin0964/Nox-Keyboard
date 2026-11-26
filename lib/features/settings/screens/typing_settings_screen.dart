import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../data/preferences_helper.dart';
import '../../../services/ime_platform_bridge.dart';

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
  late String _soundStyle;
  late double _soundVolume;
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
    _soundStyle = _prefs.soundStyle;
    _soundVolume = _prefs.soundVolume;
    _vibrateOnKeypress = _prefs.vibrateOnKeypress;
    _vibrationIntensity = _prefs.vibrationIntensity;
    _keyboardHeight = _prefs.keyboardHeight.clamp(220.0, 340.0);
    _showNumberRow = _prefs.showNumberRow;
  }

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: 'Typing & Smart Settings',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          const ModernSectionHeader(title: 'Smart Typing & Corrections'),
          GlassCard(
            child: Column(
              children: [
                ModernSwitchTile(
                  icon: CupertinoIcons.wand_stars,
                  iconColor: const Color(0xFF00E5FF),
                  title: 'Autocorrection',
                  subtitle: 'Correct words automatically when pressing space',
                  value: _autoCorrection,
                  onChanged: (val) async {
                    await _prefs.setAutoCorrection(val);
                    setState(() => _autoCorrection = val);
                  },
                ),
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.sparkles,
                  iconColor: const Color(0xFFA855F7),
                  title: 'Next-Word Prediction',
                  subtitle: 'Predict likely upcoming words from context',
                  value: _nextWordPrediction,
                  onChanged: (val) async {
                    await _prefs.setNextWordPrediction(val);
                    setState(() => _nextWordPrediction = val);
                  },
                ),
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.arrow_up_square_fill,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Auto-Capitalization',
                  subtitle: 'Capitalize the first word of each sentence',
                  value: _autoCapitalization,
                  onChanged: (val) async {
                    await _prefs.setAutoCapitalization(val);
                    setState(() => _autoCapitalization = val);
                  },
                ),
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.textformat,
                  iconColor: const Color(0xFF10B981),
                  title: 'Double-Space Period',
                  subtitle: 'Double-tapping space inserts "." and space',
                  value: _doubleSpacePeriod,
                  onChanged: (val) async {
                    await _prefs.setDoubleSpacePeriod(val);
                    setState(() => _doubleSpacePeriod = val);
                  },
                ),
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.text_bubble_fill,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Show Suggestions Bar',
                  subtitle: 'Show live word & Avro candidates above keys',
                  value: _showSuggestionsBar,
                  onChanged: (val) async {
                    await _prefs.setShowSuggestionsBar(val);
                    setState(() => _showSuggestionsBar = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const ModernSectionHeader(title: 'Keypress Feedback & Layout', accentColor: Color(0xFFA855F7)),
          GlassCard(
            child: Column(
              children: [
                ModernSwitchTile(
                  icon: CupertinoIcons.chat_bubble_text_fill,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Key Press Bubble Popup',
                  subtitle: 'Show floating letter bubble above pressed keys',
                  value: _popupOnKeypress,
                  onChanged: (val) async {
                    await _prefs.setPopupOnKeypress(val);
                    setState(() => _popupOnKeypress = val);
                  },
                ),
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.speaker_2_fill,
                  iconColor: const Color(0xFF10B981),
                  title: 'Sound on Keypress',
                  subtitle: 'Built-in low-latency key click audio',
                  value: _soundOnKeypress,
                  onChanged: (val) async {
                    await _prefs.setSoundOnKeypress(val);
                    setState(() => _soundOnKeypress = val);
                    if (val) {
                      ImePlatformBridge().playKeySound(0, _soundStyle, _soundVolume);
                    }
                  },
                ),
                if (_soundOnKeypress) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sound Profile (Tap to Test)',
                          style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _soundStyleChip('Soft', 'soft'),
                            const SizedBox(width: 6),
                            _soundStyleChip('Mech', 'mechanical'),
                            const SizedBox(width: 6),
                            _soundStyleChip('Bubble', 'bubble'),
                            const SizedBox(width: 6),
                            _soundStyleChip('Type', 'typewriter'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sound Volume',
                              style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.7)),
                            ),
                            _valuePill('${(_soundVolume * 100).round()}%', const Color(0xFF10B981)),
                          ],
                        ),
                        Slider(
                          value: _soundVolume,
                          min: 0.1,
                          max: 1.0,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) async {
                            await _prefs.setSoundVolume(val);
                            setState(() => _soundVolume = val);
                          },
                          onChangeEnd: (val) {
                            ImePlatformBridge().playKeySound(0, _soundStyle, val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.waveform,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Haptic Vibration',
                  subtitle: 'Tactile feedback when pressing keys',
                  value: _vibrateOnKeypress,
                  onChanged: (val) async {
                    await _prefs.setVibrateOnKeypress(val);
                    setState(() => _vibrateOnKeypress = val);
                  },
                ),
                if (_vibrateOnKeypress) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Vibration Strength',
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                            ),
                            _valuePill('$_vibrationIntensity ms', const Color(0xFFEC4899)),
                          ],
                        ),
                        Slider(
                          value: _vibrationIntensity.toDouble(),
                          min: 5,
                          max: 50,
                          divisions: 9,
                          activeColor: const Color(0xFFEC4899),
                          onChanged: (val) async {
                            final intVal = val.toInt();
                            await _prefs.setVibrationIntensity(intVal);
                            setState(() => _vibrationIntensity = intVal);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                _glassDivider(),
                ModernSwitchTile(
                  icon: CupertinoIcons.number_square_fill,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Dedicated Number Row',
                  subtitle: 'Always show 0–9 digits row above letters',
                  value: _showNumberRow,
                  onChanged: (val) async {
                    await _prefs.setShowNumberRow(val);
                    setState(() => _showNumberRow = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const ModernSectionHeader(title: 'Keyboard Size (Small ↔ Large)', accentColor: Color(0xFF10B981)),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const ModernIconBadge(
                          icon: CupertinoIcons.arrow_up_down,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Keyboard Height',
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            Text(
                              'Tap preset or drag slider to resize',
                              style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _valuePill('${_keyboardHeight.toStringAsFixed(0)} dp', const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _sizePresetBtn('Small', 235.0),
                    const SizedBox(width: 8),
                    _sizePresetBtn('Normal', 275.0),
                    const SizedBox(width: 8),
                    _sizePresetBtn('Large', 305.0),
                    const SizedBox(width: 8),
                    _sizePresetBtn('XL', 335.0),
                  ],
                ),
                const SizedBox(height: 6),
                Slider(
                  value: _keyboardHeight,
                  min: 220,
                  max: 340,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) async {
                    await _prefs.setKeyboardHeight(val);
                    setState(() => _keyboardHeight = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sizePresetBtn(String label, double heightVal) {
    final isSelected = (_keyboardHeight - heightVal).abs() < 10;
    return Expanded(
      child: InkWell(
        onTap: () async {
          await _prefs.setKeyboardHeight(heightVal);
          setState(() => _keyboardHeight = heightVal);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withOpacity(0.24)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : Colors.white.withOpacity(0.1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF34D399) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _soundStyleChip(String label, String styleId) {
    final active = _soundStyle == styleId;
    return Expanded(
      child: InkWell(
        onTap: () async {
          await _prefs.setSoundStyle(styleId);
          setState(() => _soundStyle = styleId);
          ImePlatformBridge().playKeySound(0, styleId, _soundVolume);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF10B981).withOpacity(0.24) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? const Color(0xFF10B981) : Colors.white12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF34D399) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassDivider() {
    return Divider(height: 1, indent: 60, color: Colors.white.withOpacity(0.06));
  }

  Widget _valuePill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
