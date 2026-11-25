import 'keyboard_layout.dart';

class EnglishLayout {
  static KeyboardPage getPage({required bool isShifted, required bool isCapsLock}) {
    final shift = isShifted || isCapsLock;

    return KeyboardPage(
      rows: [
        // Row 1
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'Q' : 'q', secondary: '1', alternateChars: ['1', 'q', 'Q']),
          KeyboardKey(primary: shift ? 'W' : 'w', secondary: '2', alternateChars: ['2', 'w', 'W']),
          KeyboardKey(primary: shift ? 'E' : 'e', secondary: '3', alternateChars: ['3', 'e', 'E', 'é', 'è', 'ê', 'ë']),
          KeyboardKey(primary: shift ? 'R' : 'r', secondary: '4', alternateChars: ['4', 'r', 'R']),
          KeyboardKey(primary: shift ? 'T' : 't', secondary: '5', alternateChars: ['5', 't', 'T']),
          KeyboardKey(primary: shift ? 'Y' : 'y', secondary: '6', alternateChars: ['6', 'y', 'Y']),
          KeyboardKey(primary: shift ? 'U' : 'u', secondary: '7', alternateChars: ['7', 'u', 'U', 'ú', 'ù', 'û', 'ü']),
          KeyboardKey(primary: shift ? 'I' : 'i', secondary: '8', alternateChars: ['8', 'i', 'I', 'í', 'ì', 'î', 'ï']),
          KeyboardKey(primary: shift ? 'O' : 'o', secondary: '9', alternateChars: ['9', 'o', 'O', 'ó', 'ò', 'ô', 'ö', 'õ']),
          KeyboardKey(primary: shift ? 'P' : 'p', secondary: '0', alternateChars: ['0', 'p', 'P']),
        ]),

        // Row 2
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'A' : 'a', secondary: '@', alternateChars: ['@', 'a', 'A', 'á', 'à', 'â', 'ä', 'ã', 'å']),
          KeyboardKey(primary: shift ? 'S' : 's', secondary: '#', alternateChars: ['#', 's', 'S', 'ß', 'š']),
          KeyboardKey(primary: shift ? 'D' : 'd', secondary: '\$', alternateChars: ['\$', 'd', 'D']),
          KeyboardKey(primary: shift ? 'F' : 'f', secondary: '_', alternateChars: ['_', 'f', 'F']),
          KeyboardKey(primary: shift ? 'G' : 'g', secondary: '&', alternateChars: ['&', 'g', 'G']),
          KeyboardKey(primary: shift ? 'H' : 'h', secondary: '-', alternateChars: ['-', 'h', 'H']),
          KeyboardKey(primary: shift ? 'J' : 'j', secondary: '+', alternateChars: ['+', 'j', 'J']),
          KeyboardKey(primary: shift ? 'K' : 'k', secondary: '(', alternateChars: ['(', 'k', 'K']),
          KeyboardKey(primary: shift ? 'L' : 'l', secondary: ')', alternateChars: [')', 'l', 'L']),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 14),
          KeyboardKey(primary: shift ? 'Z' : 'z', secondary: '%', alternateChars: ['%', 'z', 'Z', 'ž']),
          KeyboardKey(primary: shift ? 'X' : 'x', secondary: '*', alternateChars: ['*', 'x', 'X']),
          KeyboardKey(primary: shift ? 'C' : 'c', secondary: '"', alternateChars: ['"', 'c', 'C', 'ç']),
          KeyboardKey(primary: shift ? 'V' : 'v', secondary: "'", alternateChars: ["'", 'v', 'V']),
          KeyboardKey(primary: shift ? 'B' : 'b', secondary: ':', alternateChars: [':', 'b', 'B']),
          KeyboardKey(primary: shift ? 'N' : 'n', secondary: ';', alternateChars: [';', 'n', 'N', 'ñ']),
          KeyboardKey(primary: shift ? 'M' : 'm', secondary: '!', alternateChars: ['!', 'm', 'M']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: ',', flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '.', flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
