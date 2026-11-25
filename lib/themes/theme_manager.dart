import 'package:flutter/material.dart';
import '../data/preferences_helper.dart';
import 'theme_model.dart';
import 'built_in_themes.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  NoxKeyboardTheme _currentTheme = BuiltInThemes.noxDark;
  NoxKeyboardTheme get currentTheme => _currentTheme;

  final Map<String, NoxKeyboardTheme> _customThemes = {};
  List<NoxKeyboardTheme> get customThemes => _customThemes.values.toList();

  List<NoxKeyboardTheme> get allThemes => [
    ...BuiltInThemes.all,
    ..._customThemes.values,
  ];

  Future<void> init() async {
    final prefs = PreferencesHelper();
    await prefs.init();

    // Load custom themes
    final map = prefs.customThemes;
    _customThemes.clear();
    map.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        try {
          _customThemes[k] = NoxKeyboardTheme.fromJson(v);
        } catch (_) {}
      }
    });

    final id = prefs.selectedThemeId;
    if (_customThemes.containsKey(id)) {
      _currentTheme = _customThemes[id]!;
    } else {
      _currentTheme = BuiltInThemes.findById(id);
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    if (_customThemes.containsKey(themeId)) {
      _currentTheme = _customThemes[themeId]!;
    } else {
      _currentTheme = BuiltInThemes.findById(themeId);
    }
    await PreferencesHelper().setSelectedThemeId(themeId);
    notifyListeners();
  }

  Future<void> saveCustomTheme(NoxKeyboardTheme theme) async {
    _customThemes[theme.id] = theme;
    await PreferencesHelper().saveCustomTheme(theme.id, theme.toJson());
    await setTheme(theme.id);
  }

  Future<void> deleteCustomTheme(String id) async {
    _customThemes.remove(id);
    await PreferencesHelper().deleteCustomTheme(id);
    if (_currentTheme.id == id) {
      await setTheme('nox_dark');
    } else {
      notifyListeners();
    }
  }
}
