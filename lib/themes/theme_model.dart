import 'package:flutter/material.dart';

class NoxKeyboardTheme {
  final String id;
  final String name;
  final bool isDark;
  final Color backgroundColor;
  final Color keyColor;
  final Color keyPressedColor;
  final Color actionKeyColor;
  final Color actionKeyPressedColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color accentColor;
  final Color suggestionBarColor;
  final Color toolbarColor;
  final double keyBorderRadius;
  final double keyBorderWidth;
  final Color keyBorderColor;
  final double keyMarginH;
  final double keyMarginV;
  final double fontSize;

  const NoxKeyboardTheme({
    required this.id,
    required this.name,
    required this.isDark,
    required this.backgroundColor,
    required this.keyColor,
    required this.keyPressedColor,
    required this.actionKeyColor,
    required this.actionKeyPressedColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.accentColor,
    required this.suggestionBarColor,
    required this.toolbarColor,
    this.keyBorderRadius = 8.0,
    this.keyBorderWidth = 0.0,
    this.keyBorderColor = Colors.transparent,
    this.keyMarginH = 3.0,
    this.keyMarginV = 5.0,
    this.fontSize = 20.0,
  });

  NoxKeyboardTheme copyWith({
    String? id,
    String? name,
    bool? isDark,
    Color? backgroundColor,
    Color? keyColor,
    Color? keyPressedColor,
    Color? actionKeyColor,
    Color? actionKeyPressedColor,
    Color? textColor,
    Color? secondaryTextColor,
    Color? accentColor,
    Color? suggestionBarColor,
    Color? toolbarColor,
    double? keyBorderRadius,
    double? keyBorderWidth,
    Color? keyBorderColor,
    double? keyMarginH,
    double? keyMarginV,
    double? fontSize,
  }) {
    return NoxKeyboardTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      isDark: isDark ?? this.isDark,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      keyColor: keyColor ?? this.keyColor,
      keyPressedColor: keyPressedColor ?? this.keyPressedColor,
      actionKeyColor: actionKeyColor ?? this.actionKeyColor,
      actionKeyPressedColor: actionKeyPressedColor ?? this.actionKeyPressedColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      accentColor: accentColor ?? this.accentColor,
      suggestionBarColor: suggestionBarColor ?? this.suggestionBarColor,
      toolbarColor: toolbarColor ?? this.toolbarColor,
      keyBorderRadius: keyBorderRadius ?? this.keyBorderRadius,
      keyBorderWidth: keyBorderWidth ?? this.keyBorderWidth,
      keyBorderColor: keyBorderColor ?? this.keyBorderColor,
      keyMarginH: keyMarginH ?? this.keyMarginH,
      keyMarginV: keyMarginV ?? this.keyMarginV,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDark': isDark,
      'backgroundColor': backgroundColor.value,
      'keyColor': keyColor.value,
      'keyPressedColor': keyPressedColor.value,
      'actionKeyColor': actionKeyColor.value,
      'actionKeyPressedColor': actionKeyPressedColor.value,
      'textColor': textColor.value,
      'secondaryTextColor': secondaryTextColor.value,
      'accentColor': accentColor.value,
      'suggestionBarColor': suggestionBarColor.value,
      'toolbarColor': toolbarColor.value,
      'keyBorderRadius': keyBorderRadius,
      'keyBorderWidth': keyBorderWidth,
      'keyBorderColor': keyBorderColor.value,
      'keyMarginH': keyMarginH,
      'keyMarginV': keyMarginV,
      'fontSize': fontSize,
    };
  }

  factory NoxKeyboardTheme.fromJson(Map<String, dynamic> json) {
    return NoxKeyboardTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      isDark: json['isDark'] as bool? ?? true,
      backgroundColor: Color(json['backgroundColor'] as int),
      keyColor: Color(json['keyColor'] as int),
      keyPressedColor: Color(json['keyPressedColor'] as int),
      actionKeyColor: Color(json['actionKeyColor'] as int),
      actionKeyPressedColor: Color(json['actionKeyPressedColor'] as int),
      textColor: Color(json['textColor'] as int),
      secondaryTextColor: Color(json['secondaryTextColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      suggestionBarColor: Color(json['suggestionBarColor'] as int),
      toolbarColor: Color(json['toolbarColor'] as int),
      keyBorderRadius: (json['keyBorderRadius'] as num?)?.toDouble() ?? 8.0,
      keyBorderWidth: (json['keyBorderWidth'] as num?)?.toDouble() ?? 0.0,
      keyBorderColor: json['keyBorderColor'] != null ? Color(json['keyBorderColor'] as int) : Colors.transparent,
      keyMarginH: (json['keyMarginH'] as num?)?.toDouble() ?? 3.0,
      keyMarginV: (json['keyMarginV'] as num?)?.toDouble() ?? 5.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20.0,
    );
  }
}
