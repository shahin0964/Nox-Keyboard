import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class PreferencesHelper {
  static final PreferencesHelper _instance = PreferencesHelper._internal();
  factory PreferencesHelper() => _instance;
  PreferencesHelper._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Language settings
  String get selectedLanguage => _prefs?.getString(AppConstants.keySelectedLanguage) ?? 'en_US';
  Future<bool> setSelectedLanguage(String lang) async => await _prefs?.setString(AppConstants.keySelectedLanguage, lang) ?? false;

  List<String> get enabledLanguages => _prefs?.getStringList(AppConstants.keyEnabledLanguages) ?? ['en_US', 'bn_BD', 'hi', 'ar', 'ur'];
  Future<bool> setEnabledLanguages(List<String> langs) async => await _prefs?.setStringList(AppConstants.keyEnabledLanguages, langs) ?? false;

  bool get isBanglaPhonetic => _prefs?.getBool(AppConstants.keyIsBanglaPhonetic) ?? true;
  Future<bool> setIsBanglaPhonetic(bool val) async => await _prefs?.setBool(AppConstants.keyIsBanglaPhonetic, val) ?? false;

  // Theme settings
  String get selectedThemeId => _prefs?.getString(AppConstants.keySelectedThemeId) ?? 'nox_dark';
  Future<bool> setSelectedThemeId(String id) async => await _prefs?.setString(AppConstants.keySelectedThemeId, id) ?? false;

  double get keyboardHeight => _prefs?.getDouble(AppConstants.keyKeyboardHeight) ?? AppConstants.defaultKeyboardHeight;
  Future<bool> setKeyboardHeight(double height) async => await _prefs?.setDouble(AppConstants.keyKeyboardHeight, height) ?? false;

  bool get showNumberRow => _prefs?.getBool(AppConstants.keyShowNumberRow) ?? false;
  Future<bool> setShowNumberRow(bool val) async => await _prefs?.setBool(AppConstants.keyShowNumberRow, val) ?? false;

  bool get soundOnKeypress => _prefs?.getBool(AppConstants.keySoundOnKeypress) ?? true;
  Future<bool> setSoundOnKeypress(bool val) async => await _prefs?.setBool(AppConstants.keySoundOnKeypress, val) ?? false;

  bool get vibrateOnKeypress => _prefs?.getBool(AppConstants.keyVibrateOnKeypress) ?? true;
  Future<bool> setVibrateOnKeypress(bool val) async => await _prefs?.setBool(AppConstants.keyVibrateOnKeypress, val) ?? false;

  int get vibrationIntensity => _prefs?.getInt(AppConstants.keyVibrationIntensity) ?? AppConstants.defaultVibrationMs;
  Future<bool> setVibrationIntensity(int val) async => await _prefs?.setInt(AppConstants.keyVibrationIntensity, val) ?? false;

  bool get popupOnKeypress => _prefs?.getBool(AppConstants.keyPopupOnKeypress) ?? true;
  Future<bool> setPopupOnKeypress(bool val) async => await _prefs?.setBool(AppConstants.keyPopupOnKeypress, val) ?? false;

  bool get autoCapitalization => _prefs?.getBool(AppConstants.keyAutoCapitalization) ?? true;
  Future<bool> setAutoCapitalization(bool val) async => await _prefs?.setBool(AppConstants.keyAutoCapitalization, val) ?? false;

  bool get doubleSpacePeriod => _prefs?.getBool(AppConstants.keyDoubleSpacePeriod) ?? true;
  Future<bool> setDoubleSpacePeriod(bool val) async => await _prefs?.setBool(AppConstants.keyDoubleSpacePeriod, val) ?? false;

  bool get autoCorrection => _prefs?.getBool(AppConstants.keyAutoCorrection) ?? true;
  Future<bool> setAutoCorrection(bool val) async => await _prefs?.setBool(AppConstants.keyAutoCorrection, val) ?? false;

  bool get nextWordPrediction => _prefs?.getBool(AppConstants.keyNextWordPrediction) ?? true;
  Future<bool> setNextWordPrediction(bool val) async => await _prefs?.setBool(AppConstants.keyNextWordPrediction, val) ?? false;

  bool get showSuggestionsBar => _prefs?.getBool(AppConstants.keyShowSuggestionsBar) ?? true;
  Future<bool> setShowSuggestionsBar(bool val) async => await _prefs?.setBool(AppConstants.keyShowSuggestionsBar, val) ?? false;

  String get oneHandedMode => _prefs?.getString(AppConstants.keyOneHandedMode) ?? 'none';
  Future<bool> setOneHandedMode(String mode) async => await _prefs?.setString(AppConstants.keyOneHandedMode, mode) ?? false;

  bool get isFloatingMode => _prefs?.getBool(AppConstants.keyIsFloatingMode) ?? false;
  Future<bool> setIsFloatingMode(bool val) async => await _prefs?.setBool(AppConstants.keyIsFloatingMode, val) ?? false;

  bool get onboardingCompleted => _prefs?.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  Future<bool> setOnboardingCompleted(bool val) async => await _prefs?.setBool(AppConstants.keyOnboardingCompleted, val) ?? false;

  // Clipboard
  List<String> get pinnedClipboard => _prefs?.getStringList(AppConstants.keyPinnedClipboard) ?? [];
  Future<bool> setPinnedClipboard(List<String> items) async => await _prefs?.setStringList(AppConstants.keyPinnedClipboard, items) ?? false;

  List<String> get recentClipboard => _prefs?.getStringList(AppConstants.keyRecentClipboard) ?? [];
  Future<bool> setRecentClipboard(List<String> items) async => await _prefs?.setStringList(AppConstants.keyRecentClipboard, items) ?? false;

  Future<void> addClipboardItem(String text) async {
    if (text.trim().isEmpty) return;
    final recents = List<String>.from(recentClipboard);
    recents.remove(text);
    recents.insert(0, text);
    if (recents.length > 30) {
      recents.removeRange(30, recents.length);
    }
    await setRecentClipboard(recents);
  }

  Future<void> togglePinClipboardItem(String text) async {
    final pinned = List<String>.from(pinnedClipboard);
    if (pinned.contains(text)) {
      pinned.remove(text);
    } else {
      pinned.insert(0, text);
    }
    await setPinnedClipboard(pinned);
  }

  Future<void> deleteClipboardItem(String text) async {
    final recents = List<String>.from(recentClipboard);
    recents.remove(text);
    await setRecentClipboard(recents);

    final pinned = List<String>.from(pinnedClipboard);
    pinned.remove(text);
    await setPinnedClipboard(pinned);
  }

  Future<void> clearUnpinnedClipboard() async {
    await setRecentClipboard([]);
  }

  // Recent Emojis
  List<String> get recentEmojis => _prefs?.getStringList(AppConstants.keyRecentEmojis) ?? ['😀', '😂', '❤️', '👍', '🙏', '🔥', '✨', '🎉', '😍', '😊'];
  Future<void> addRecentEmoji(String emoji) async {
    final list = List<String>.from(recentEmojis);
    list.remove(emoji);
    list.insert(0, emoji);
    if (list.length > 30) {
      list.removeRange(30, list.length);
    }
    await _prefs?.setStringList(AppConstants.keyRecentEmojis, list);
  }

  // User Dictionary
  List<String> get userDictionary => _prefs?.getStringList(AppConstants.keyUserDictionary) ?? [];
  Future<void> addUserWord(String word) async {
    final clean = word.trim().toLowerCase();
    if (clean.isEmpty) return;
    final list = List<String>.from(userDictionary);
    if (!list.contains(clean)) {
      list.add(clean);
      await _prefs?.setStringList(AppConstants.keyUserDictionary, list);
    }
  }

  Future<void> removeUserWord(String word) async {
    final list = List<String>.from(userDictionary);
    list.remove(word.trim().toLowerCase());
    await _prefs?.setStringList(AppConstants.keyUserDictionary, list);
  }

  Future<void> clearUserDictionary() async {
    await _prefs?.setStringList(AppConstants.keyUserDictionary, []);
  }

  // Custom Themes JSON map
  Map<String, dynamic> get customThemes {
    final raw = _prefs?.getString(AppConstants.keyCustomThemes);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveCustomTheme(String id, Map<String, dynamic> data) async {
    final map = Map<String, dynamic>.from(customThemes);
    map[id] = data;
    await _prefs?.setString(AppConstants.keyCustomThemes, jsonEncode(map));
  }

  Future<void> deleteCustomTheme(String id) async {
    final map = Map<String, dynamic>.from(customThemes);
    map.remove(id);
    await _prefs?.setString(AppConstants.keyCustomThemes, jsonEncode(map));
  }
}
