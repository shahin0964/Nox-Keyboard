import 'keyboard_layout.dart';

class SymbolsLayout {
  static KeyboardPage getPage1() {
    return KeyboardPage(
      rows: [
        // Row 1: Numbers
        KeyboardRow(keys: [
          KeyboardKey(primary: '1', alternateChars: ['1', '¹', '½']),
          KeyboardKey(primary: '2', alternateChars: ['2', '²', '⅓']),
          KeyboardKey(primary: '3', alternateChars: ['3', '³', '¼']),
          KeyboardKey(primary: '4', alternateChars: ['4', '⁴']),
          KeyboardKey(primary: '5', alternateChars: ['5', '⅝']),
          KeyboardKey(primary: '6', alternateChars: ['6']),
          KeyboardKey(primary: '7', alternateChars: ['7', '⅞']),
          KeyboardKey(primary: '8', alternateChars: ['8']),
          KeyboardKey(primary: '9', alternateChars: ['9']),
          KeyboardKey(primary: '0', alternateChars: ['0', '⁰', '∅']),
        ]),

        // Row 2: Basic symbols
        KeyboardRow(keys: [
          KeyboardKey(primary: '@'),
          KeyboardKey(primary: '#'),
          KeyboardKey(primary: '\$'),
          KeyboardKey(primary: '_'),
          KeyboardKey(primary: '&'),
          KeyboardKey(primary: '-'),
          KeyboardKey(primary: '+'),
          KeyboardKey(primary: '('),
          KeyboardKey(primary: ')'),
          KeyboardKey(primary: '/'),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: '=\\<', action: KeyAction.switchMoreSymbols, flex: 14),
          KeyboardKey(primary: '*'),
          KeyboardKey(primary: '"'),
          KeyboardKey(primary: "'"),
          KeyboardKey(primary: ':'),
          KeyboardKey(primary: ';'),
          KeyboardKey(primary: '!'),
          KeyboardKey(primary: '?'),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: 'ABC', action: KeyAction.switchLetters, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: ',', flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '.', flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }

  static KeyboardPage getPage2() {
    return KeyboardPage(
      rows: [
        // Row 1: Math and special symbols
        KeyboardRow(keys: [
          KeyboardKey(primary: '~'),
          KeyboardKey(primary: '`'),
          KeyboardKey(primary: '|'),
          KeyboardKey(primary: '•'),
          KeyboardKey(primary: '√'),
          KeyboardKey(primary: 'π'),
          KeyboardKey(primary: '÷'),
          KeyboardKey(primary: '×'),
          KeyboardKey(primary: '¶'),
          KeyboardKey(primary: '∆'),
        ]),

        // Row 2: Currency and brackets
        KeyboardRow(keys: [
          KeyboardKey(primary: '£'),
          KeyboardKey(primary: '€'),
          KeyboardKey(primary: '¥'),
          KeyboardKey(primary: '৳', alternateChars: ['৳', '₹', '₽']),
          KeyboardKey(primary: '^'),
          KeyboardKey(primary: '°'),
          KeyboardKey(primary: '='),
          KeyboardKey(primary: '{'),
          KeyboardKey(primary: '}'),
          KeyboardKey(primary: '\\'),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '%'),
          KeyboardKey(primary: '©'),
          KeyboardKey(primary: '®'),
          KeyboardKey(primary: '™'),
          KeyboardKey(primary: '✓'),
          KeyboardKey(primary: '['),
          KeyboardKey(primary: ']'),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4: Keep 🌐 locked in exact same position across symbols pages
        KeyboardRow(keys: [
          KeyboardKey(primary: 'ABC', action: KeyAction.switchLetters, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: '<', alternateChars: ['<', '«'], flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '>', secondary: '…', alternateChars: ['>', '»', '…'], flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
