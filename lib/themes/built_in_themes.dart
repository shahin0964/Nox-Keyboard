import 'package:flutter/material.dart';
import 'theme_model.dart';

class BuiltInThemes {
  static const NoxKeyboardTheme noxDark = NoxKeyboardTheme(
    id: 'nox_dark',
    name: 'Nox Dark',
    isDark: true,
    backgroundColor: Color(0xFF11141A),
    keyColor: Color(0xFF1E232F),
    keyPressedColor: Color(0xFF2B3345),
    actionKeyColor: Color(0xFF181C26),
    actionKeyPressedColor: Color(0xFF262D3D),
    textColor: Color(0xFFF8FAFC),
    secondaryTextColor: Color(0xFF94A3B8),
    accentColor: Color(0xFF00E5FF),
    suggestionBarColor: Color(0xFF151922),
    toolbarColor: Color(0xFF151922),
    keyBorderRadius: 12.0,
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
    keyBorderRadius: 12.0,
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
    backgroundColor: Color(0xFF091024),
    keyColor: Color(0xFF17203B),
    keyPressedColor: Color(0xFF233056),
    actionKeyColor: Color(0xFF11182D),
    actionKeyPressedColor: Color(0xFF1E2A4C),
    textColor: Color(0xFFF0F4FF),
    secondaryTextColor: Color(0xFF8DA4C4),
    accentColor: Color(0xFF48CAE4),
    suggestionBarColor: Color(0xFF0E162F),
    toolbarColor: Color(0xFF0E162F),
    keyBorderRadius: 12.0,
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
    actionKeyColor: Color(0xFF0C0C0C),
    actionKeyPressedColor: Color(0xFF1E1E1E),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFF888888),
    accentColor: Color(0xFF10B981),
    suggestionBarColor: Color(0xFF080808),
    toolbarColor: Color(0xFF080808),
    keyBorderRadius: 12.0,
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
    backgroundColor: Color(0xFF081426),
    keyColor: Color(0xFF13233B),
    keyPressedColor: Color(0xFF1C3454),
    actionKeyColor: Color(0xFF0D1B2E),
    actionKeyPressedColor: Color(0xFF18304F),
    textColor: Color(0xFFCCD6F6),
    secondaryTextColor: Color(0xFF8892B0),
    accentColor: Color(0xFF64FFDA),
    suggestionBarColor: Color(0xFF0B192E),
    toolbarColor: Color(0xFF0B192E),
    keyBorderRadius: 12.0,
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
    keyBorderRadius: 12.0,
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
