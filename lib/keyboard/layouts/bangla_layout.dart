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

    // Google Keyboard (Gboard) style Complete Bangla Alphabetical Layout
    // All vowels, consonants, hasant, and modifiers visible cleanly with zero Shift needed.
    // Tapping a vowel right after a consonant automatically applies its Kar sign (া ি ী ু ূ ৃ ে ৈ ো ৌ);
    // long-press lets you pick either the independent vowel or Kar explicitly.
    return KeyboardPage(
      rows: [
        // Row 1: Vowels (অ - ঔ)
        KeyboardRow(keys: [
          KeyboardKey(primary: 'অ', alternateChars: ['অ']),
          KeyboardKey(primary: 'আ', secondary: 'া', alternateChars: ['আ', 'া']),
          KeyboardKey(primary: 'ই', secondary: 'ি', alternateChars: ['ই', 'ি']),
          KeyboardKey(primary: 'ঈ', secondary: 'ী', alternateChars: ['ঈ', 'ী']),
          KeyboardKey(primary: 'উ', secondary: 'ু', alternateChars: ['উ', 'ু']),
          KeyboardKey(primary: 'ঊ', secondary: 'ূ', alternateChars: ['ঊ', 'ূ']),
          KeyboardKey(primary: 'এ', secondary: 'ে', alternateChars: ['এ', 'ে']),
          KeyboardKey(primary: 'ঐ', secondary: 'ৈ', alternateChars: ['ঐ', 'ৈ']),
          KeyboardKey(primary: 'ও', secondary: 'ো', alternateChars: ['ও', 'ো']),
          KeyboardKey(primary: 'ঔ', secondary: 'ৌ', alternateChars: ['ঔ', 'ৌ']),
        ]),

        // Row 2: ক খ গ ঘ ঙ চ ছ জ ঝ ঞ
        KeyboardRow(keys: [
          KeyboardKey(primary: 'ক', secondary: '১', alternateChars: ['ক', '১', 'ক্ষ']),
          KeyboardKey(primary: 'খ', secondary: '২', alternateChars: ['খ', '২']),
          KeyboardKey(primary: 'গ', secondary: '৩', alternateChars: ['গ', '৩']),
          KeyboardKey(primary: 'ঘ', secondary: '৪', alternateChars: ['ঘ', '৪']),
          KeyboardKey(primary: 'ঙ', secondary: '৫', alternateChars: ['ঙ', '৫']),
          KeyboardKey(primary: 'চ', secondary: '৬', alternateChars: ['চ', '৬']),
          KeyboardKey(primary: 'ছ', secondary: '৭', alternateChars: ['ছ', '৭']),
          KeyboardKey(primary: 'জ', secondary: '৮', alternateChars: ['জ', '৮', 'জ্ঞ']),
          KeyboardKey(primary: 'ঝ', secondary: '৯', alternateChars: ['ঝ', '৯']),
          KeyboardKey(primary: 'ঞ', secondary: '০', alternateChars: ['ঞ', '০']),
        ]),

        // Row 3: ট ঠ ড ঢ ণ ত থ দ ধ ন
        KeyboardRow(keys: [
          KeyboardKey(primary: 'ট'),
          KeyboardKey(primary: 'ঠ'),
          KeyboardKey(primary: 'ড'),
          KeyboardKey(primary: 'ঢ'),
          KeyboardKey(primary: 'ণ'),
          KeyboardKey(primary: 'ত'),
          KeyboardKey(primary: 'থ'),
          KeyboardKey(primary: 'দ'),
          KeyboardKey(primary: 'ধ'),
          KeyboardKey(primary: 'ন'),
        ]),

        // Row 4: প ফ ব ভ ম য র ল শ ষ
        KeyboardRow(keys: [
          KeyboardKey(primary: 'প'),
          KeyboardKey(primary: 'ফ'),
          KeyboardKey(primary: 'ব'),
          KeyboardKey(primary: 'ভ'),
          KeyboardKey(primary: 'ম'),
          KeyboardKey(primary: 'য'),
          KeyboardKey(primary: 'র', secondary: '্র', alternateChars: ['র', '্র', 'র্']),
          KeyboardKey(primary: 'ল'),
          KeyboardKey(primary: 'শ'),
          KeyboardKey(primary: 'ষ'),
        ]),

        // Row 5: স হ ড় ঢ় য় ৎ ্য ঋ ্ Backspace
        KeyboardRow(keys: [
          KeyboardKey(primary: 'স'),
          KeyboardKey(primary: 'হ'),
          KeyboardKey(primary: 'ড়'),
          KeyboardKey(primary: 'ঢ়'),
          KeyboardKey(primary: 'য়'),
          KeyboardKey(primary: 'ৎ'),
          KeyboardKey(primary: '্য', secondary: '্র', alternateChars: ['্য', '্র']),
          KeyboardKey(primary: 'ঋ', secondary: 'ৃ', alternateChars: ['ঋ', 'ৃ']),
          KeyboardKey(primary: '্', secondary: 'ং', alternateChars: ['ং', 'ঃ', 'ঁ', '্']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace),
        ]),

        // Row 6: Exact same fixed 🌐 slot (index 1) & flex ratios as every other layout
        KeyboardRow(keys: [
          KeyboardKey(primary: '?১২৩', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: ',', alternateChars: [',', 'ং', 'ঃ', 'ঁ'], flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '।', secondary: '.', alternateChars: ['।', '.', ',', '?', '!'], flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
