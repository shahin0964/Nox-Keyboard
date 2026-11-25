import 'keyboard_layout.dart';

class ArabicLayout {
  static KeyboardPage getPage({required bool isShifted, required bool isCapsLock}) {
    final shift = isShifted || isCapsLock;

    return KeyboardPage(
      rows: [
        // Row 1
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'َ' : 'ض', alternateChars: ['ض', 'َ']),
          KeyboardKey(primary: shift ? 'ً' : 'ص', alternateChars: ['ص', 'ً']),
          KeyboardKey(primary: shift ? 'ُ' : 'ث', alternateChars: ['ث', 'ُ']),
          KeyboardKey(primary: shift ? 'ٌ' : 'ق', alternateChars: ['ق', 'ٌ']),
          KeyboardKey(primary: shift ? 'لإ' : 'ف', alternateChars: ['ف', 'لإ']),
          KeyboardKey(primary: shift ? 'إ' : 'غ', alternateChars: ['غ', 'إ']),
          KeyboardKey(primary: shift ? '‘' : 'ع', alternateChars: ['ع']),
          KeyboardKey(primary: shift ? '÷' : 'ه', alternateChars: ['ه']),
          KeyboardKey(primary: shift ? '×' : 'خ', alternateChars: ['خ']),
          KeyboardKey(primary: shift ? '؛' : 'ح', alternateChars: ['ح']),
          KeyboardKey(primary: shift ? '<' : 'ج', alternateChars: ['ج']),
        ]),

        // Row 2
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ِ' : 'ش', alternateChars: ['ش', 'ِ']),
          KeyboardKey(primary: shift ? 'ٍ' : 'س', alternateChars: ['س', 'ٍ']),
          KeyboardKey(primary: shift ? ']' : 'ي', alternateChars: ['ي', 'ى']),
          KeyboardKey(primary: shift ? '[' : 'ب', alternateChars: ['ب']),
          KeyboardKey(primary: shift ? 'لأ' : 'ل', alternateChars: ['ل', 'لا']),
          KeyboardKey(primary: shift ? 'أ' : 'ا', alternateChars: ['ا', 'أ', 'إ', 'آ']),
          KeyboardKey(primary: shift ? 'ـ' : 'ت', alternateChars: ['ت', 'ة']),
          KeyboardKey(primary: shift ? '،' : 'ن', alternateChars: ['ن']),
          KeyboardKey(primary: shift ? '/' : 'م', alternateChars: ['م']),
          KeyboardKey(primary: shift ? ':' : 'ك', alternateChars: ['ك']),
          KeyboardKey(primary: shift ? '"' : 'ط', alternateChars: ['ط']),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 14),
          KeyboardKey(primary: shift ? '~' : 'ئ', alternateChars: ['ئ', 'ء']),
          KeyboardKey(primary: shift ? 'ْ' : 'ء', alternateChars: ['ء']),
          KeyboardKey(primary: shift ? '}' : 'ؤ', alternateChars: ['ؤ']),
          KeyboardKey(primary: shift ? '{' : 'ر', alternateChars: ['ر']),
          KeyboardKey(primary: shift ? 'لآ' : 'لا', alternateChars: ['لا', 'لآ']),
          KeyboardKey(primary: shift ? 'آ' : 'ى', alternateChars: ['ى']),
          KeyboardKey(primary: shift ? '’' : 'ة', alternateChars: ['ة']),
          KeyboardKey(primary: shift ? '?' : 'و', alternateChars: ['و']),
          KeyboardKey(primary: shift ? '!' : 'ز', alternateChars: ['ز']),
          KeyboardKey(primary: shift ? 'ّ' : 'ظ', alternateChars: ['ظ']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: '،', flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '.', flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
