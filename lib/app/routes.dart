import 'package:flutter/material.dart';
import '../keyboard/widgets/keyboard_view.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/enable_keyboard_screen.dart';
import '../features/onboarding/screens/select_default_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/dashboard/screens/keyboard_preview_screen.dart';
import '../features/language/screens/language_screen.dart';
import '../features/customization/screens/theme_gallery_screen.dart';
import '../features/customization/screens/theme_editor_screen.dart';
import '../features/settings/screens/typing_settings_screen.dart';
import '../features/settings/screens/dictionary_settings_screen.dart';
import '../features/clipboard/screens/clipboard_screen.dart';
import '../features/emoji/screens/emoji_screen.dart';
import '../features/voice/screens/voice_typing_screen.dart';
import '../features/privacy/screens/privacy_screen.dart';
import '../features/settings/screens/about_screen.dart';

class AppRoutes {
  static const String root = '/';
  static const String ime = '/ime';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String enable = '/enable';
  static const String selectDefault = '/select-default';
  static const String preview = '/preview';
  static const String languages = '/languages';
  static const String themes = '/themes';
  static const String themeEditor = '/theme-editor';
  static const String typingSettings = '/typing-settings';
  static const String dictionarySettings = '/dictionary-settings';
  static const String clipboard = '/clipboard';
  static const String emojiSettings = '/emoji-settings';
  static const String voiceSettings = '/voice-settings';
  static const String privacy = '/privacy';
  static const String about = '/about';

  static Map<String, WidgetBuilder> get routes => {
    ime: (context) => const NoxKeyboardView(isImeMode: true),
    onboarding: (context) => const OnboardingScreen(),
    dashboard: (context) => const DashboardScreen(),
    enable: (context) => const EnableKeyboardScreen(),
    selectDefault: (context) => const SelectDefaultScreen(),
    preview: (context) => const KeyboardPreviewScreen(),
    languages: (context) => const LanguageScreen(),
    themes: (context) => const ThemeGalleryScreen(),
    themeEditor: (context) => const ThemeEditorScreen(),
    typingSettings: (context) => const TypingSettingsScreen(),
    dictionarySettings: (context) => const DictionarySettingsScreen(),
    clipboard: (context) => const ClipboardScreen(),
    emojiSettings: (context) => const EmojiSettingsScreen(),
    voiceSettings: (context) => const VoiceTypingScreen(),
    privacy: (context) => const PrivacyScreen(),
    about: (context) => const AboutScreen(),
  };
}
