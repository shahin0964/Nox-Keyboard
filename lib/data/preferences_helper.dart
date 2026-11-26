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
    await _seedDefaultDictionaryIfNeeded();
  }

  Future<void> reload() async {
    await init();
    await _prefs?.reload();
  }

  Future<void> _seedDefaultDictionaryIfNeeded() async {
    if (_prefs == null) return;
    final seeded = _prefs!.getBool(AppConstants.keyDictionarySeeded) ?? false;
    if (seeded) return;

    await _prefs!.setBool(AppConstants.keyDictionarySeeded, true);
    if ((_prefs!.getStringList(AppConstants.keyUserDictionary) ?? []).isEmpty) {
      await _prefs!.setStringList(AppConstants.keyUserDictionary, [
        'nox',
        'bangladesh',
        'dhaka',
        'assalamualaikum',
        'alhamdulillah',
        'inshallah',
      ]);
    }
    if ((_prefs!.getString(AppConstants.keyCustomShortcuts) ?? '').isEmpty) {
      await _prefs!.setString(
        AppConstants.keyCustomShortcuts,
        jsonEncode({
          'slm': 'আসসালামু আলাইকুম',
          'hlw': 'হ্যালো, কেমন আছেন?',
          'brb': 'Be right back',
          'omw': 'On my way!',
          'thx': 'Thanks a lot!',
          'ty': 'Thank you!',
          'gm': 'Good morning!',
          'gn': 'Good night!',
          'np': 'No problem!',
        }),
      );
    }
  }

  // Language settings
  String get selectedLanguage => _prefs?.getString(AppConstants.keySelectedLanguage) ?? 'en_US';
  Future<bool> setSelectedLanguage(String lang) async => await _prefs?.setString(AppConstants.keySelectedLanguage, lang) ?? false;

  List<String> get enabledLanguages => _prefs?.getStringList(AppConstants.keyEnabledLanguages) ?? ['en_US', 'bn_avro', 'bn_BD', 'hi', 'ar', 'ur'];
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

  // Custom Text Shortcuts JSON map (shortcut -> expansion)
  Map<String, String> get customShortcuts {
    final raw = _prefs?.getString(AppConstants.keyCustomShortcuts);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> addCustomShortcut(String shortcut, String expansion) async {
    final cleanKey = shortcut.trim().toLowerCase();
    final cleanVal = expansion.trim();
    if (cleanKey.isEmpty || cleanVal.isEmpty) return;
    final map = Map<String, String>.from(customShortcuts);
    map[cleanKey] = cleanVal;
    await _prefs?.setString(AppConstants.keyCustomShortcuts, jsonEncode(map));
  }

  Future<void> removeCustomShortcut(String shortcut) async {
    final map = Map<String, String>.from(customShortcuts);
    map.remove(shortcut.trim().toLowerCase());
    await _prefs?.setString(AppConstants.keyCustomShortcuts, jsonEncode(map));
  }

  Future<void> clearCustomShortcuts() async {
    await _prefs?.setString(AppConstants.keyCustomShortcuts, jsonEncode({}));
  }

  // Auto-Learned Typing Vocabulary (word -> frequency)
  Map<String, int> get learnedWordFreq {
    final raw = _prefs?.getString(AppConstants.keyLearnedWordFreq);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> recordLearnedWord(String word) async {
    final clean = word.trim();
    if (clean.length < 2 || clean.length > 40) return;
    if (RegExp(r'^\d+$').hasMatch(clean)) return;
    final map = Map<String, int>.from(learnedWordFreq);
    map[clean] = (map[clean] ?? 0) + 1;
    if (map.length > 400) {
      final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      map
        ..clear()
        ..addEntries(sorted.take(350));
    }
    await _prefs?.setString(AppConstants.keyLearnedWordFreq, jsonEncode(map));
  }

  List<String> searchLearnedPrefix(String prefix, {int limit = 3}) {
    final clean = prefix.trim().toLowerCase();
    if (clean.isEmpty) return [];
    final entries = learnedWordFreq.entries
        .where((e) => e.key.toLowerCase().startsWith(clean))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).map((e) => e.key).toList();
  }

  Future<void> clearLearnedData() async {
    await _prefs?.setString(AppConstants.keyLearnedWordFreq, jsonEncode({}));
    await _prefs?.setString(AppConstants.keyLearnedBigrams, jsonEncode({}));
  }

  // Auto-Learned Next-Word Followups (prevWord -> [nextWords])
  Map<String, List<String>> get learnedBigrams {
    final raw = _prefs?.getString(AppConstants.keyLearnedBigrams);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, List<String>.from(v as List)));
    } catch (_) {
      return {};
    }
  }

  Future<void> recordLearnedBigram(String prevWord, String nextWord) async {
    final p = prevWord.trim().toLowerCase();
    final n = nextWord.trim();
    if (p.length < 2 || n.length < 2) return;
    final map = Map<String, List<String>>.from(learnedBigrams);
    final list = List<String>.from(map[p] ?? []);
    list.remove(n);
    list.insert(0, n);
    if (list.length > 4) list.removeRange(4, list.length);
    map[p] = list;
    if (map.length > 250) {
      map.remove(map.keys.first);
    }
    await _prefs?.setString(AppConstants.keyLearnedBigrams, jsonEncode(map));
  }

  List<String> getLearnedNextWords(String prevWord, {int limit = 3}) {
    final p = prevWord.trim().toLowerCase();
    if (p.isEmpty) return [];
    return (learnedBigrams[p] ?? []).take(limit).toList();
  }

  // Temporary Image / Screenshot Clips (auto-expire unpinned after 30 minutes)
  List<Map<String, dynamic>> get imageClips {
    final raw = _prefs?.getString(AppConstants.keyImageClips);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final cutoff = DateTime.now().millisecondsSinceEpoch - const Duration(minutes: 30).inMilliseconds;
      return list.where((item) {
        final isPinned = item['pinned'] as bool? ?? false;
        final ts = (item['timestamp'] as num?)?.toInt() ?? 0;
        return isPinned || ts >= cutoff;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addImageClip(String path) async {
    if (path.trim().isEmpty) return;
    final list = List<Map<String, dynamic>>.from(imageClips);
    final existingIdx = list.indexWhere((e) => e['path'] == path);
    bool wasPinned = false;
    if (existingIdx != -1) {
      wasPinned = list[existingIdx]['pinned'] as bool? ?? false;
      list.removeAt(existingIdx);
    }
    list.insert(0, {
      'path': path,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'pinned': wasPinned,
    });
    if (list.length > 12) {
      list.removeRange(12, list.length);
    }
    await _prefs?.setString(AppConstants.keyImageClips, jsonEncode(list));
  }

  Future<void> togglePinImageClip(String path) async {
    final list = List<Map<String, dynamic>>.from(imageClips);
    for (final item in list) {
      if (item['path'] == path) {
        item['pinned'] = !(item['pinned'] as bool? ?? false);
        break;
      }
    }
    await _prefs?.setString(AppConstants.keyImageClips, jsonEncode(list));
  }

  Future<void> deleteImageClip(String path) async {
    final list = List<Map<String, dynamic>>.from(imageClips)
      ..removeWhere((e) => e['path'] == path);
    await _prefs?.setString(AppConstants.keyImageClips, jsonEncode(list));
  }

  Future<void> clearUnpinnedImageClips() async {
    final list = imageClips.where((e) => e['pinned'] as bool? ?? false).toList();
    await _prefs?.setString(AppConstants.keyImageClips, jsonEncode(list));
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
