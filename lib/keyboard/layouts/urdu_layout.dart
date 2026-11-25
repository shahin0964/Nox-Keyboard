import 'keyboard_layout.dart';

class UrduLayout {
  static KeyboardPage getPage({required bool isShifted, required bool isCapsLock}) {
    final shift = isShifted || isCapsLock;

    return KeyboardPage(
      rows: [
        // Row 1
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ط' : 'ق', alternateChars: ['ق', 'ط']),
          KeyboardKey(primary: shift ? 'ظ' : 'و', alternateChars: ['و', 'ظ', 'ؤ']),
          KeyboardKey(primary: shift ? 'ع' : 'ع', alternateChars: ['ع']),
          KeyboardKey(primary: shift ? 'غ' : 'ر', alternateChars: ['ر', 'ڑ']),
          KeyboardKey(primary: shift ? 'ف' : 'ت', alternateChars: ['ت', 'ٹ']),
          KeyboardKey(primary: shift ? 'ق' : 'ے', alternateChars: ['ے', 'ی']),
          KeyboardKey(primary: shift ? 'ث' : 'ء', alternateChars: ['ء']),
          KeyboardKey(primary: shift ? 'ص' : 'ی', alternateChars: ['ی', 'ئ']),
          KeyboardKey(primary: shift ? 'ض' : 'ہ', alternateChars: ['ہ', 'ھ']),
          KeyboardKey(primary: shift ? 'پ' : 'پ', alternateChars: ['پ']),
        ]),

        // Row 2
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'آ' : 'ا', alternateChars: ['ا', 'آ']),
          KeyboardKey(primary: shift ? 'س' : 'س', alternateChars: ['س']),
          KeyboardKey(primary: shift ? 'ش' : 'د', alternateChars: ['د', 'ڈ']),
          KeyboardKey(primary: shift ? 'د' : 'ف', alternateChars: ['ف']),
          KeyboardKey(primary: shift ? 'ڈ' : 'گ', alternateChars: ['گ']),
          KeyboardKey(primary: shift ? 'ح' : 'ح', alternateChars: ['ح', 'خ']),
          KeyboardKey(primary: shift ? 'ج' : 'ج', alternateChars: ['ج', 'چ']),
          KeyboardKey(primary: shift ? 'چ' : 'ک', alternateChars: ['ک']),
          KeyboardKey(primary: shift ? 'ل' : 'ل', alternateChars: ['ل']),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 14),
          KeyboardKey(primary: shift ? 'ذ' : 'ز', alternateChars: ['ز', 'ژ']),
          KeyboardKey(primary: shift ? 'ڑ' : 'خ', alternateChars: ['خ']),
          KeyboardKey(primary: shift ? 'ٹ' : 'چ', alternateChars: ['چ']),
          KeyboardKey(primary: shift ? 'ث' : 'ش', alternateChars: ['ش']),
          KeyboardKey(primary: shift ? 'ں' : 'ب', alternateChars: ['ب', 'بھ']),
          KeyboardKey(primary: shift ? 'ن' : 'ن', alternateChars: ['ن', 'ں']),
          KeyboardKey(primary: shift ? 'م' : 'م', alternateChars: ['م']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: '،', flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '۔', flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
