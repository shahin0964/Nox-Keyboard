import 'package:flutter/foundation.dart';
import '../data/preferences_helper.dart';
import 'language_model.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  LanguageModel _currentLanguage = LanguageModel.bangla;
  LanguageModel get currentLanguage => _currentLanguage;

  List<String> _enabledLanguageCodes = ['bn_BD', 'en_US', 'hi', 'ar', 'ur'];
  List<String> get enabledLanguageCodes => _enabledLanguageCodes;

  bool _isBanglaPhonetic = true;
  bool get isBanglaPhonetic => _isBanglaPhonetic;

  Future<void> init() async {
    final prefs = PreferencesHelper();
    await prefs.init();

    _enabledLanguageCodes = prefs.enabledLanguages;
    _isBanglaPhonetic = prefs.isBanglaPhonetic;

    final code = prefs.selectedLanguage;
    _currentLanguage = LanguageModel.findByCode(code);
    notifyListeners();
  }

  Future<void> reload() async {
    await PreferencesHelper().reload();
    await init();
  }

  Future<void> setLanguage(String code) async {
    _currentLanguage = LanguageModel.findByCode(code);
    await PreferencesHelper().setSelectedLanguage(code);
    notifyListeners();
  }

  Future<void> cycleNextLanguage() async {
    if (_enabledLanguageCodes.isEmpty) return;
    int idx = _enabledLanguageCodes.indexOf(_currentLanguage.code);
    if (idx == -1) idx = 0;
    final nextIdx = (idx + 1) % _enabledLanguageCodes.length;
    final nextCode = _enabledLanguageCodes[nextIdx];
    await setLanguage(nextCode);
  }

  Future<void> toggleBanglaPhonetic() async {
    _isBanglaPhonetic = !_isBanglaPhonetic;
    await PreferencesHelper().setIsBanglaPhonetic(_isBanglaPhonetic);
    notifyListeners();
  }

  Future<void> toggleLanguageEnabled(String code) async {
    final list = List<String>.from(_enabledLanguageCodes);
    if (list.contains(code)) {
      if (list.length > 1) {
        list.remove(code);
      }
    } else {
      list.add(code);
    }
    _enabledLanguageCodes = list;
    await PreferencesHelper().setEnabledLanguages(list);

    if (!_enabledLanguageCodes.contains(_currentLanguage.code)) {
      await setLanguage(_enabledLanguageCodes.first);
    } else {
      notifyListeners();
    }
  }
}
