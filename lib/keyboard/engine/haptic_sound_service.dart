import '../../data/preferences_helper.dart';
import '../../services/ime_platform_bridge.dart';

class HapticSoundService {
  static final HapticSoundService _instance = HapticSoundService._internal();
  factory HapticSoundService() => _instance;
  HapticSoundService._internal();

  final PreferencesHelper _prefs = PreferencesHelper();
  final ImePlatformBridge _bridge = ImePlatformBridge();

  void playKeyClick([int effect = 0]) {
    if (_prefs.soundOnKeypress) {
      _bridge.playKeySound(
        effect,
        _prefs.soundStyle,
        _prefs.soundVolume,
      );
    }
  }

  void performHaptic() {
    if (_prefs.vibrateOnKeypress) {
      final intensity = _prefs.vibrationIntensity;
      _bridge.performHaptic(intensity);
    }
  }

  void onKeyFeedback([int effect = 0]) {
    final playSound = _prefs.soundOnKeypress;
    final vibrate = _prefs.vibrateOnKeypress;
    if (!playSound && !vibrate) return;
    _bridge.triggerKeyFeedback(
      playSound: playSound,
      effect: effect,
      style: _prefs.soundStyle,
      volume: _prefs.soundVolume,
      vibrate: vibrate,
      durationMs: _prefs.vibrationIntensity,
    );
  }
}
