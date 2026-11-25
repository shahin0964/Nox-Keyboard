enum KeyAction {
  character,
  shift,
  backspace,
  enter,
  space,
  switchSymbols,
  switchMoreSymbols,
  switchLetters,
  switchLanguage,
  emoji,
}

class KeyboardKey {
  final String primary;
  final String? secondary;
  final List<String> alternateChars;
  final KeyAction action;
  final int flex;

  const KeyboardKey({
    required this.primary,
    this.secondary,
    this.alternateChars = const [],
    this.action = KeyAction.character,
    this.flex = 10,
  });

  KeyboardKey copyWith({
    String? primary,
    String? secondary,
    List<String>? alternateChars,
    KeyAction? action,
    int? flex,
  }) {
    return KeyboardKey(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      alternateChars: alternateChars ?? this.alternateChars,
      action: action ?? this.action,
      flex: flex ?? this.flex,
    );
  }
}

class KeyboardRow {
  final List<KeyboardKey> keys;
  const KeyboardRow({required this.keys});
}

class KeyboardPage {
  final List<KeyboardRow> rows;
  const KeyboardPage({required this.rows});
}
