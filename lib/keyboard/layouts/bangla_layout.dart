import 'keyboard_layout.dart';
import 'english_layout.dart';

class BanglaLayout {
  static KeyboardPage getPage({
    required bool isPhonetic,
    required bool isShifted,
    required bool isCapsLock,
  }) {
    if (isPhonetic) {
      // In phonetic mode, display QWERTY with Bengali hints
      return EnglishLayout.getPage(isShifted: isShifted, isCapsLock: isCapsLock);
    }

    final shift = isShifted || isCapsLock;

    // Direct Bengali script layout
    return KeyboardPage(
      rows: [
        // Row 1
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ৎ' : '১', secondary: '!', alternateChars: ['১', 'ৎ']),
          KeyboardKey(primary: shift ? 'ূ' : '২', secondary: '@', alternateChars: ['২', 'ূ']),
          KeyboardKey(primary: shift ? 'ী' : '৩', secondary: '#', alternateChars: ['৩', 'ী']),
          KeyboardKey(primary: shift ? 'ূ' : '৪', secondary: '\$', alternateChars: ['৪', 'ূ']),
          KeyboardKey(primary: shift ? 'ৈ' : '৫', secondary: '%', alternateChars: ['৫', 'ৈ']),
          KeyboardKey(primary: shift ? 'ৌ' : '৬', secondary: '^', alternateChars: ['৬', 'ৌ']),
          KeyboardKey(primary: shift ? 'ঢ়' : '৭', secondary: '&', alternateChars: ['৭', 'ঢ়']),
          KeyboardKey(primary: shift ? 'ড়' : '৮', secondary: '*', alternateChars: ['৮', 'ড়']),
          KeyboardKey(primary: shift ? 'ঞ' : '৯', secondary: '(', alternateChars: ['৯', 'ঞ']),
          KeyboardKey(primary: shift ? 'ঙ' : '০', secondary: ')', alternateChars: ['০', 'ঙ']),
        ]),

        // Row 2
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'অ' : 'ো', alternateChars: ['ো', 'অ', 'ও']),
          KeyboardKey(primary: shift ? 'ই' : 'ে', alternateChars: ['ে', 'ই', 'এ']),
          KeyboardKey(primary: shift ? 'আ' : 'া', alternateChars: ['া', 'আ']),
          KeyboardKey(primary: shift ? 'ঈ' : 'ী', alternateChars: ['ী', 'ঈ']),
          KeyboardKey(primary: shift ? 'উ' : 'ু', alternateChars: ['ু', 'উ']),
          KeyboardKey(primary: shift ? 'ভ' : 'ব', alternateChars: ['ব', 'ভ']),
          KeyboardKey(primary: shift ? 'হ' : 'হ', alternateChars: ['হ', 'ঃ']),
          KeyboardKey(primary: shift ? 'ঘ' : 'গ', alternateChars: ['গ', 'ঘ']),
          KeyboardKey(primary: shift ? 'র' : 'র', alternateChars: ['র', 'ড়', 'ঢ়']),
          KeyboardKey(primary: shift ? 'খ' : 'ক', alternateChars: ['ক', 'খ', 'ক্ক']),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 14),
          KeyboardKey(primary: shift ? 'য' : 'দ', alternateChars: ['দ', 'ধ']),
          KeyboardKey(primary: shift ? 'শ' : 'স', alternateChars: ['স', 'শ', 'ষ']),
          KeyboardKey(primary: shift ? 'ষ' : 'শ', alternateChars: ['শ', 'ষ']),
          KeyboardKey(primary: shift ? 'ণ' : 'ন', alternateChars: ['ন', 'ণ']),
          KeyboardKey(primary: shift ? 'ম' : 'ম', alternateChars: ['ম', 'ঁ']),
          KeyboardKey(primary: shift ? 'ফ' : 'প', alternateChars: ['প', 'ফ']),
          KeyboardKey(primary: shift ? 'থ' : 'ত', alternateChars: ['ত', 'থ', 'ৎ']),
          KeyboardKey(primary: shift ? 'ঝ' : 'জ', alternateChars: ['জ', 'ঝ', 'জ্ঞ']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '্', secondary: 'hasant', alternateChars: ['্', 'ঁ', 'ং', 'ঃ'], flex: 10),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 40),
          KeyboardKey(primary: '।', secondary: '.', alternateChars: ['।', '.', ','], flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
