class AppConstants {
  static const String appName = 'Nox Keyboard';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.Nox.Keyboard';
  static const String imeServiceClass = 'com.Nox.Keyboard.NoxInputMethodService';

  // Method Channels
  static const String imeChannel = 'com.nox.keyboard/ime';
  static const String appChannel = 'com.nox.keyboard/app';

  // Storage Keys
  static const String keySelectedLanguage = 'selected_language';
  static const String keyEnabledLanguages = 'enabled_languages';
  static const String keyIsBanglaPhonetic = 'is_bangla_phonetic';
  static const String keySelectedThemeId = 'selected_theme_id';
  static const String keyKeyboardHeight = 'keyboard_height';
  static const String keyShowNumberRow = 'show_number_row';
  static const String keySoundOnKeypress = 'sound_on_keypress';
  static const String keySoundStyle = 'sound_style';
  static const String keySoundVolume = 'sound_volume';
  static const String keyVibrateOnKeypress = 'vibrate_on_keypress';
  static const String keyVibrationIntensity = 'vibration_intensity';
  static const String keyPopupOnKeypress = 'popup_on_keypress';
  static const String keyAutoCapitalization = 'auto_capitalization';
  static const String keyDoubleSpacePeriod = 'double_space_period';
  static const String keyAutoCorrection = 'auto_correction';
  static const String keyNextWordPrediction = 'next_word_prediction';
  static const String keyShowSuggestionsBar = 'show_suggestions_bar';
  static const String keyOneHandedMode = 'one_handed_mode';
  static const String keyIsFloatingMode = 'is_floating_mode';
  static const String keyPinnedClipboard = 'pinned_clipboard';
  static const String keyRecentClipboard = 'recent_clipboard';
  static const String keyRecentEmojis = 'recent_emojis';
  static const String keyCustomThemes = 'custom_themes';
  static const String keyUserDictionary = 'user_dictionary';
  static const String keyCustomShortcuts = 'custom_shortcuts';
  static const String keyDictionarySeeded = 'dictionary_seeded';
  static const String keyLearnedWordFreq = 'learned_word_freq';
  static const String keyLearnedBigrams = 'learned_bigrams';
  static const String keyImageClips = 'image_clips';
  static const String keyToolbarOrder = 'toolbar_tool_order';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyTypingHistoryData = 'typing_history_data';
  static const String keyTypingHistoryEnabled = 'typing_history_enabled';
  static const String keyKeyCommandsMap = 'key_commands_map';
  static const String keyKeyModeStayActive = 'key_mode_stay_active';

  // Default Values
  static const double defaultKeyboardHeight = 275.0;
  static const double minKeyboardHeight = 220.0;
  static const double maxKeyboardHeight = 340.0;
  static const int defaultVibrationMs = 15;
}
