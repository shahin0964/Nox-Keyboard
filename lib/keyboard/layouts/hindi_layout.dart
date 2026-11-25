import 'keyboard_layout.dart';

class HindiLayout {
  static KeyboardPage getPage({required bool isShifted, required bool isCapsLock}) {
    final shift = isShifted || isCapsLock;

    return KeyboardPage(
      rows: [
        // Row 1
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? '१' : 'ौ', alternateChars: ['ौ', '१']),
          KeyboardKey(primary: shift ? '२' : 'ै', alternateChars: ['ै', '२']),
          KeyboardKey(primary: shift ? '३' : 'ा', alternateChars: ['ा', '३', 'आ']),
          KeyboardKey(primary: shift ? '४' : 'ी', alternateChars: ['ी', '४', 'ई']),
          KeyboardKey(primary: shift ? '५' : 'ू', alternateChars: ['ू', '५', 'ऊ']),
          KeyboardKey(primary: shift ? '६' : 'ब', alternateChars: ['ब', '६', 'भ']),
          KeyboardKey(primary: shift ? '७' : 'ह', alternateChars: ['ह', '७']),
          KeyboardKey(primary: shift ? '८' : 'ग', alternateChars: ['ग', '८', 'घ']),
          KeyboardKey(primary: shift ? '९' : 'द', alternateChars: ['द', '९', 'ध']),
          KeyboardKey(primary: shift ? '०' : 'ज', alternateChars: ['ज', '०', 'झ']),
        ]),

        // Row 2
        KeyboardRow(keys: [
          KeyboardKey(primary: shift ? 'ओ' : 'ो', alternateChars: ['ो', 'ओ']),
          KeyboardKey(primary: shift ? 'ए' : 'े', alternateChars: ['े', 'ए']),
          KeyboardKey(primary: shift ? 'अ' : '्', alternateChars: ['्', 'अ']),
          KeyboardKey(primary: shift ? 'इ' : 'ि', alternateChars: ['ि', 'इ']),
          KeyboardKey(primary: shift ? 'उ' : 'ु', alternateChars: ['ु', 'उ']),
          KeyboardKey(primary: shift ? 'फ' : 'प', alternateChars: ['प', 'फ']),
          KeyboardKey(primary: shift ? 'र' : 'र', alternateChars: ['र', 'ऋ']),
          KeyboardKey(primary: shift ? 'क' : 'क', alternateChars: ['क', 'ख']),
          KeyboardKey(primary: shift ? 'त' : 'त', alternateChars: ['त', 'थ']),
          KeyboardKey(primary: shift ? 'च' : 'च', alternateChars: ['च', 'छ']),
        ]),

        // Row 3
        KeyboardRow(keys: [
          KeyboardKey(primary: 'SHIFT', action: KeyAction.shift, flex: 14),
          KeyboardKey(primary: shift ? 'ऐ' : 'ं', alternateChars: ['ं', 'ँ']),
          KeyboardKey(primary: shift ? 'म' : 'म', alternateChars: ['म', 'ण']),
          KeyboardKey(primary: shift ? 'न' : 'न', alternateChars: ['न', 'ञ']),
          KeyboardKey(primary: shift ? 'व' : 'व', alternateChars: ['व']),
          KeyboardKey(primary: shift ? 'ल' : 'ल', alternateChars: ['ल']),
          KeyboardKey(primary: shift ? 'स' : 'स', alternateChars: ['स', 'श', 'ष']),
          KeyboardKey(primary: shift ? 'य' : 'य', alternateChars: ['य']),
          KeyboardKey(primary: 'BACKSPACE', action: KeyAction.backspace, flex: 14),
        ]),

        // Row 4
        KeyboardRow(keys: [
          KeyboardKey(primary: '?123', action: KeyAction.switchSymbols, flex: 14),
          KeyboardKey(primary: '🌐', action: KeyAction.switchLanguage, flex: 10),
          KeyboardKey(primary: ',', flex: 10),
          KeyboardKey(primary: 'SPACE', action: KeyAction.space, flex: 44),
          KeyboardKey(primary: '।', flex: 10),
          KeyboardKey(primary: 'ENTER', action: KeyAction.enter, flex: 16),
        ]),
      ],
    );
  }
}
