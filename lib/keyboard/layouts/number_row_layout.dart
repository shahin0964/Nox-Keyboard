import 'keyboard_layout.dart';

class NumberRowLayout {
  static KeyboardRow getRow({String languageCode = 'en_US'}) {
    if (languageCode == 'bn_BD') {
      return KeyboardRow(
        keys: const [
          KeyboardKey(primary: '১', alternateChars: ['১', '1']),
          KeyboardKey(primary: '২', alternateChars: ['২', '2']),
          KeyboardKey(primary: '৩', alternateChars: ['৩', '3']),
          KeyboardKey(primary: '৪', alternateChars: ['৪', '4']),
          KeyboardKey(primary: '৫', alternateChars: ['৫', '5']),
          KeyboardKey(primary: '৬', alternateChars: ['৬', '6']),
          KeyboardKey(primary: '৭', alternateChars: ['৭', '7']),
          KeyboardKey(primary: '৮', alternateChars: ['৮', '8']),
          KeyboardKey(primary: '৯', alternateChars: ['৯', '9']),
          KeyboardKey(primary: '০', alternateChars: ['০', '0']),
        ],
      );
    }

    return KeyboardRow(
      keys: const [
        KeyboardKey(primary: '1', alternateChars: ['1', '১', '१', '١']),
        KeyboardKey(primary: '2', alternateChars: ['2', '২', '२', '٢']),
        KeyboardKey(primary: '3', alternateChars: ['3', '৩', '३', '٣']),
        KeyboardKey(primary: '4', alternateChars: ['4', '৪', '४', '٤']),
        KeyboardKey(primary: '5', alternateChars: ['5', '৫', '५', '٥']),
        KeyboardKey(primary: '6', alternateChars: ['6', '৬', '६', '٦']),
        KeyboardKey(primary: '7', alternateChars: ['7', '৭', '७', '٧']),
        KeyboardKey(primary: '8', alternateChars: ['8', '৮', '८', '٨']),
        KeyboardKey(primary: '9', alternateChars: ['9', '৯', '९', '٩']),
        KeyboardKey(primary: '0', alternateChars: ['0', '০', '०', '٠']),
      ],
    );
  }
}
