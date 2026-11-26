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

    // Complete Standard Bangla Script Layout (11 + 11 + 9 + consistent bottom row)
    // Covers all 11 vowels, 10 kars, 39 consonants, Hasant (্), Dari (।), and Bangla digits on long-press.
    return KeyboardPage(
      rows: [
        // Row 1 (11 keys): Kars / Vowels + Consonants + Digits in secondary/long-press
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ঔ' : 'ৌ', secondary: '১', alternateChars: ['১', 'ৌ', 'ঔ']),
          KeyboardKey(primary: shift ? 'ঐ' : 'ৈ', secondary: '২', alternateChars: ['২', 'ৈ', 'ঐ']),
          KeyboardKey(primary: shift ? 'আ' : 'া', secondary: '৩', alternateChars: ['৩', 'া', 'আ']),
          KeyboardKey(primary: shift ? 'ঈ' : 'ী', secondary: '৪', alternateChars: ['৪', 'ী', 'ঈ']),
          KeyboardKey(primary: shift ? 'ঊ' : 'ূ', secondary: '৫', alternateChars: ['৫', 'ূ', 'ঊ']),
          KeyboardKey(primary: shift ? 'ভ' : 'ব', secondary: '৬', alternateChars: ['৬', 'ব', 'ভ']),
          KeyboardKey(primary: shift ? 'ঙ' : 'হ', secondary: '৭', alternateChars: ['৭', 'হ', 'ঙ']),
          KeyboardKey(primary: shift ? 'ঘ' : 'গ', secondary: '৮', alternateChars: ['৮', 'গ', 'ঘ']),
          KeyboardKey(primary: shift ? 'ধ' : 'দ', secondary: '৯', alternateChars: ['৯', 'দ', 'ধ']),
          KeyboardKey(primary: shift ? 'ঝ' : 'জ', secondary: '০', alternateChars: ['০', 'জ', 'ঝ']),
          KeyboardKey(primary: shift ? 'ঢ' : 'ড', secondary: 'ড়', alternateChars: ['ড', 'ঢ', 'ড়', 'ঢ়']),
        ]),

        // Row 2 (11 keys): Core Kars, Hasant (্), and High-Frequency Consonants
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ও' : 'ো', secondary: 'ও', alternateChars: ['ো', 'ও']),
          KeyboardKey(primary: shift ? 'এ' : 'ে', secondary: 'এ', alternateChars: ['ে', 'এ']),
          KeyboardKey(primary: shift ? 'অ' : '্', secondary: 'অ', alternateChars: ['্', 'অ', '্র', '্য']),
          KeyboardKey(primary: shift ? 'ই' : 'ি', secondary: 'ই', alternateChars: ['ি', 'ই']),
          KeyboardKey(primary: shift ? 'উ' : 'ু', secondary: 'উ', alternateChars: ['ু', 'উ']),
          KeyboardKey(primary: shift ? 'ফ' : 'প', secondary: 'ফ', alternateChars: ['প', 'ফ']),
          KeyboardKey(primary: shift ? 'ঋ' : 'র', secondary: 'ঋ', alternateChars: ['র', 'ঋ', 'ৃ', '্র']),
          KeyboardKey(primary: shift ? 'খ' : 'ক', secondary: 'খ', alternateChars: ['ক', 'খ', 'ক্ষ']),
          KeyboardKey(primary: shift ? 'থ' : 'ত', secondary: 'থ', alternateChars: ['ত', 'থ', 'ৎ']),
          KeyboardKey(primary: shift ? 'ছ' : 'চ', secondary: 'ছ', alternateChars: ['চ', 'ছ']),
          KeyboardKey(primary: shift ? 'ঠ' : 'ট', secondary: 'ঠ', alternateChars: ['ট', 'ঠ']),
        ]),

        // Row 3 (Shift + 9 keys + Backspace)
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 12),
          KeyboardKey(primary: shift ? 'ঁ' : 'ৃ', secondary: 'ঁ', alternateChars: ['ৃ', 'ঁ'], flex: 9),
          KeyboardKey(primary: shift ? 'ঃ' : 'ং', secondary: 'ঃ', alternateChars: ['ং', 'ঃ', 'ঁ'], flex: 9),
          KeyboardKey(primary: shift ? 'ঞ' : 'ম', secondary: 'ঞ', alternateChars: ['ম', 'ঞ'], flex: 9),
          KeyboardKey(primary: shift ? 'ণ' : 'ন', secondary: 'ণ', alternateChars: ['ন', 'ণ'], flex: 9),
          KeyboardKey(primary: shift ? 'য়' : 'য', secondary: 'য়', alternateChars: ['য', 'য়', '্য'], flex: 9),
          KeyboardKey(primary: shift ? 'ৎ' : 'ল', secondary: 'ৎ', alternateChars: ['ল', 'ৎ'], flex: 9),
          KeyboardKey(primary: shift ? 'ষ' : 'স', secondary: 'ষ', alternateChars: ['স', 'ষ', 'শ'], flex: 9),
          KeyboardKey(primary: shift ? 'ঢ়' : 'শ', secondary: 'ঢ়', alternateChars: ['শ', 'ঢ়'], flex: 9),
          KeyboardKey(primary: shift ? 'ক্ষ' : 'ড়', secondary: 'ক্ষ', alternateChars: ['ড়', 'ঢ়', 'ক্ষ', 'জ্ঞ'], flex: 9),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 12),
        ]),

        // Row 4: Exact same fixed 🌐 slot (index 1) & flex ratios as every other layout
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: ',', alternateChars: [',', '্', 'ঃ'], flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '।', secondary: '.', alternateChars: ['।', '.', ',', '?', '!'], flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
