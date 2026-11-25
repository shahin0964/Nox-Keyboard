import 'package:flutter/material.dart';
import 'theme_model.dart';

class BuiltInThemes {
  static const NoxKeyboardTheme noxDark = NoxKeyboardTheme(
    id: 'nox_dark',
    name: 'Nox Dark',
    isDark: true,
    backgroundColor: Color(0xFF13151B),
    keyColor: Color(0xFF222634),
    keyPressedColor: Color(0xFF32384C),
    actionKeyColor: Color(0xFF1B1F2A),
    actionKeyPressedColor: Color(0xFF2B3243),
    textColor: Color(0xFFF8FAFC),
    secondaryTextColor: Color(0xFF94A3B8),
    accentColor: Color(0xFF00E5FF),
    suggestionBarColor: Color(0xFF171A22),
    toolbarColor: Color(0xFF171A22),
    keyBorderRadius: 8.0,
    keyMarginH: 2.5,
    keyMarginV: 3.5,
    fontSize: 21.0,
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
    keyMarginH: 2.5,
    keyMarginV: 3.5,
    fontSize: 21.0,
  );

  static const NoxKeyboardTheme midnightBlue = NoxKeyboardTheme(
    id: 'midnight_blue',
    name: 'Midnight Blue',
    isDark: true,
    backgroundColor: Color(0xFF091024),
    keyColor: Color(0xFF1A2340),
    keyPressedColor: Color(0xFF283660),
    actionKeyColor: Color(0xFF121A30),
    actionKeyPressedColor: Color(0xFF212E52),
    textColor: Color(0xFFF0F4FF),
    secondaryTextColor: Color(0xFF8DA4C4),
    accentColor: Color(0xFF48CAE4),
    suggestionBarColor: Color(0xFF0E162F),
    toolbarColor: Color(0xFF0E162F),
    keyBorderRadius: 8.0,
    keyMarginH: 2.5,
    keyMarginV: 3.5,
    fontSize: 21.0,
  );

  static const NoxKeyboardTheme amoledBlack = NoxKeyboardTheme(
    id: 'amoled_black',
    name: 'AMOLED Black',
    isDark: true,
    backgroundColor: Color(0xFF000000),
    keyColor: Color(0xFF151515),
    keyPressedColor: Color(0xFF282828),
    actionKeyColor: Color(0xFF0E0E0E),
    actionKeyPressedColor: Color(0xFF202020),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFF888888),
    accentColor: Color(0xFF10B981),
    suggestionBarColor: Color(0xFF080808),
    toolbarColor: Color(0xFF080808),
    keyBorderRadius: 8.0,
    keyBorderWidth: 1.0,
    keyBorderColor: Color(0xFF222222),
    keyMarginH: 2.5,
    keyMarginV: 3.5,
    fontSize: 21.0,
  );

  static const NoxKeyboardTheme ocean = NoxKeyboardTheme(
    id: 'ocean',
    name: 'Ocean',
    isDark: true,
    backgroundColor: Color(0xFF081426),
    keyColor: Color(0xFF142640),
    keyPressedColor: Color(0xFF203B60),
    actionKeyColor: Color(0xFF0E1D32),
    actionKeyPressedColor: Color(0xFF1A3356),
    textColor: Color(0xFFCCD6F6),
    secondaryTextColor: Color(0xFF8892B0),
    accentColor: Color(0xFF64FFDA),
    suggestionBarColor: Color(0xFF0B192E),
    toolbarColor: Color(0xFF0B192E),
    keyBorderRadius: 8.0,
    keyMarginH: 2.5,
    keyMarginV: 3.5,
    fontSize: 21.0,
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
    keyBorderRadius: 8.0,
    keyMarginH: 2.5,
    keyMarginV: 3.5,
    fontSize: 21.0,
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
