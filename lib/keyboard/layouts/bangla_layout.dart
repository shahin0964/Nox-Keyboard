import 'keyboard_layout.dart';
import 'english_layout.dart';

class BanglaLayout {
  static KeyboardPage getPage({
    required bool isPhonetic,
    required bool isShifted,
    required bool isCapsLock,
  }) {
    if (isPhonetic) {
      return EnglishLayout.getPage(isShifted: isShifted, isCapsLock: isCapsLock);
    }

    final shift = isShifted || isCapsLock;

    // Complete Direct Bangla Probhat/National Script Layout
    return KeyboardPage(
      rows: [
        // Row 1 (Vowels / Numbers / Kars)
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'অ' : '১', secondary: 'অ', alternateChars: ['১', 'অ', 'ং']),
          KeyboardKey(primary: shift ? 'আ' : '২', secondary: 'আ', alternateChars: ['২', 'আ', 'ঃ']),
          KeyboardKey(primary: shift ? 'ই' : '৩', secondary: 'ই', alternateChars: ['৩', 'ই', 'ঈ']),
          KeyboardKey(primary: shift ? 'ঈ' : '৪', secondary: 'ঈ', alternateChars: ['৪', 'ঈ', 'ঋ']),
          KeyboardKey(primary: shift ? 'উ' : '৫', secondary: 'উ', alternateChars: ['৫', 'উ', 'ঊ']),
          KeyboardKey(primary: shift ? 'ঊ' : '৬', secondary: 'ঊ', alternateChars: ['৬', 'ঊ', 'ৎ']),
          KeyboardKey(primary: shift ? 'এ' : '৭', secondary: 'এ', alternateChars: ['৭', 'এ', 'ঐ']),
          KeyboardKey(primary: shift ? 'ঐ' : '৮', secondary: 'ঐ', alternateChars: ['৮', 'ঐ', 'ড়']),
          KeyboardKey(primary: shift ? 'ও' : '৯', secondary: 'ও', alternateChars: ['৯', 'ও', 'ঢ়']),
          KeyboardKey(primary: shift ? 'ঔ' : '০', secondary: 'ঔ', alternateChars: ['০', 'ঔ', 'য়']),
        ]),

        // Row 2 (Core Kars + Consonants)
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ূ' : 'ু', secondary: 'ু', alternateChars: ['ু', 'ূ', 'ৃ']),
          KeyboardKey(primary: shift ? 'ী' : 'ি', secondary: 'ি', alternateChars: ['ি', 'ী']),
          KeyboardKey(primary: shift ? 'আ' : 'া', secondary: 'আ', alternateChars: ['া', 'আ']),
          KeyboardKey(primary: shift ? 'ৈ' : 'ে', secondary: 'ৈ', alternateChars: ['ে', 'ৈ']),
          KeyboardKey(primary: shift ? 'ৌ' : 'ো', secondary: 'ৌ', alternateChars: ['ো', 'ৌ']),
          KeyboardKey(primary: shift ? 'ভ' : 'ব', secondary: 'ভ', alternateChars: ['ব', 'ভ']),
          KeyboardKey(primary: shift ? 'ঙ' : 'হ', secondary: 'ঙ', alternateChars: ['হ', 'ঙ', 'ঃ']),
          KeyboardKey(primary: shift ? 'ঘ' : 'গ', secondary: 'ঘ', alternateChars: ['গ', 'ঘ']),
          KeyboardKey(primary: shift ? 'ঢ়' : 'র', secondary: 'ঢ়', alternateChars: ['র', 'ড়', 'ঢ়']),
          KeyboardKey(primary: shift ? 'খ' : 'ক', secondary: 'খ', alternateChars: ['ক', 'খ', 'ক্ষ']),
        ]),

        // Row 3 (Consonants)
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 13),
          KeyboardKey(primary: shift ? 'ধ' : 'দ', secondary: 'ধ', alternateChars: ['দ', 'ধ', 'ড', 'ঢ']),
          KeyboardKey(primary: shift ? 'ষ' : 'স', secondary: 'ষ', alternateChars: ['স', 'শ', 'ষ']),
          KeyboardKey(primary: shift ? 'ঞ' : 'শ', secondary: 'ঞ', alternateChars: ['শ', 'ঞ', 'চ', 'ছ']),
          KeyboardKey(primary: shift ? 'ণ' : 'ন', secondary: 'ণ', alternateChars: ['ন', 'ণ', 'ল']),
          KeyboardKey(primary: shift ? 'ল' : 'ম', secondary: 'ল', alternateChars: ['ম', 'ল', 'ঁ']),
          KeyboardKey(primary: shift ? 'ফ' : 'প', secondary: 'ফ', alternateChars: ['প', 'ফ']),
          KeyboardKey(primary: shift ? 'থ' : 'ত', secondary: 'থ', alternateChars: ['ত', 'থ', 'ট', 'ঠ', 'ৎ']),
          KeyboardKey(primary: shift ? 'ঝ' : 'জ', secondary: 'ঝ', alternateChars: ['জ', 'ঝ', 'য', 'য়']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 13),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '্', secondary: 'ঁ', alternateChars: ['্', 'ঁ', 'ং', 'ঃ'], flex: 10),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 40),
          KeyboardKey(primary: '।', secondary: ',', alternateChars: ['।', '.', ',', '?'], flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
