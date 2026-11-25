import 'package:flutter/material.dart';
import 'theme_model.dart';

class BuiltInThemes {
  static const NoxKeyboardTheme noxDark = NoxKeyboardTheme(
    id: 'nox_dark',
    name: 'Nox Dark',
    isDark: true,
    backgroundColor: Color(0xFF13151B),
    keyColor: Color(0xFF202430),
    keyPressedColor: Color(0xFF2C3243),
    actionKeyColor: Color(0xFF1B1E29),
    actionKeyPressedColor: Color(0xFF282C3D),
    textColor: Color(0xFFF1F5F9),
    secondaryTextColor: Color(0xFF94A3B8),
    accentColor: Color(0xFF00E5FF),
    suggestionBarColor: Color(0xFF181B23),
    toolbarColor: Color(0xFF181B23),
    keyBorderRadius: 8.0,
    keyMarginH: 3.0,
    keyMarginV: 4.5,
    fontSize: 20.0,
  );

  static const NoxKeyboardTheme noxLight = NoxKeyboardTheme(
    id: 'nox_light',
    name: 'Nox Light',
    isDark: false,
    backgroundColor: Color(0xFFECEFF3),
    keyColor: Color(0xFFFFFFFF),
    keyPressedColor: Color(0xFFE2E8F0),
    actionKeyColor: Color(0xFFDCE2E9),
    actionKeyPressedColor: Color(0xFFCAD3DF),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF64748B),
    accentColor: Color(0xFF3B82F6),
    suggestionBarColor: Color(0xFFE3E7ED),
    toolbarColor: Color(0xFFE3E7ED),
    keyBorderRadius: 8.0,
    keyBorderWidth: 0.5,
    keyBorderColor: Color(0xFFD1D5DB),
    keyMarginH: 3.0,
    keyMarginV: 4.5,
    fontSize: 20.0,
  );

  static const NoxKeyboardTheme midnightBlue = NoxKeyboardTheme(
    id: 'midnight_blue',
    name: 'Midnight Blue',
    isDark: true,
    backgroundColor: Color(0xFF0B132B),
    keyColor: Color(0xFF1C2541),
    keyPressedColor: Color(0xFF273458),
    actionKeyColor: Color(0xFF141C33),
    actionKeyPressedColor: Color(0xFF212E52),
    textColor: Color(0xFFF0F4FF),
    secondaryTextColor: Color(0xFF8DA4C4),
    accentColor: Color(0xFF48CAE4),
    suggestionBarColor: Color(0xFF101A38),
    toolbarColor: Color(0xFF101A38),
    keyBorderRadius: 9.0,
    keyMarginH: 3.0,
    keyMarginV: 4.5,
    fontSize: 20.0,
  );

  static const NoxKeyboardTheme amoledBlack = NoxKeyboardTheme(
    id: 'amoled_black',
    name: 'AMOLED Black',
    isDark: true,
    backgroundColor: Color(0xFF000000),
    keyColor: Color(0xFF141414),
    keyPressedColor: Color(0xFF242424),
    actionKeyColor: Color(0xFF0A0A0A),
    actionKeyPressedColor: Color(0xFF1C1C1C),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFF888888),
    accentColor: Color(0xFF10B981),
    suggestionBarColor: Color(0xFF050505),
    toolbarColor: Color(0xFF050505),
    keyBorderRadius: 8.0,
    keyBorderWidth: 1.0,
    keyBorderColor: Color(0xFF222222),
    keyMarginH: 3.0,
    keyMarginV: 4.5,
    fontSize: 20.0,
  );

  static const NoxKeyboardTheme ocean = NoxKeyboardTheme(
    id: 'ocean',
    name: 'Ocean',
    isDark: true,
    backgroundColor: Color(0xFF0A192F),
    keyColor: Color(0xFF172A45),
    keyPressedColor: Color(0xFF203A60),
    actionKeyColor: Color(0xFF0E223D),
    actionKeyPressedColor: Color(0xFF19365E),
    textColor: Color(0xFFCCD6F6),
    secondaryTextColor: Color(0xFF8892B0),
    accentColor: Color(0xFF64FFDA),
    suggestionBarColor: Color(0xFF0D203C),
    toolbarColor: Color(0xFF0D203C),
    keyBorderRadius: 8.0,
    keyMarginH: 3.0,
    keyMarginV: 4.5,
    fontSize: 20.0,
  );

  static const NoxKeyboardTheme minimalWhite = NoxKeyboardTheme(
    id: 'minimal_white',
    name: 'Minimal White',
    isDark: false,
    backgroundColor: Color(0xFFFAFAFA),
    keyColor: Color(0xFFF2F4F7),
    keyPressedColor: Color(0xFFE4E7EC),
    actionKeyColor: Color(0xFFEAECF0),
    actionKeyPressedColor: Color(0xFFD0D5DD),
    textColor: Color(0xFF1D2939),
    secondaryTextColor: Color(0xFF667085),
    accentColor: Color(0xFFF97316),
    suggestionBarColor: Color(0xFFF2F4F7),
    toolbarColor: Color(0xFFF2F4F7),
    keyBorderRadius: 10.0,
    keyMarginH: 3.0,
    keyMarginV: 4.5,
    fontSize: 20.0,
  );

  static List<NoxKeyboardTheme> get all => [
    noxDark,
    noxLight,
    midnightBlue,
    amoledBlack,
    ocean,
    minimalWhite,
  ];

  static NoxKeyboardTheme findById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => noxDark);
  }
}
