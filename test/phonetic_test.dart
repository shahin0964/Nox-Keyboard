import 'package:flutter_test/flutter_test.dart';
import 'package:nox_keyboard/keyboard/engine/bangla_phonetic_engine.dart';

void main() {
  group('BanglaPhoneticEngine Tests', () {
    late BanglaPhoneticEngine engine;

    setUp(() {
      engine = BanglaPhoneticEngine();
    });

    test('Exact high-frequency dictionary matches', () {
      expect(engine.getExactWord('ami'), 'আমি');
      expect(engine.getExactWord('tumi'), 'তুমি');
      expect(engine.getExactWord('apni'), 'আপনি');
      expect(engine.getExactWord('bangla'), 'বাংলা');
      expect(engine.getExactWord('bangladesh'), 'বাংলাদেশ');
      expect(engine.getExactWord('dhaka'), 'ঢাকা');
      expect(engine.getExactWord('bhalobashi'), 'ভালোবাসি');
      expect(engine.getExactWord('kemon'), 'কেমন');
      expect(engine.getExactWord('dhonnobad'), 'ধন্যবাদ');
      expect(engine.getExactWord('shagotom'), 'স্বাগতম');
    });

    test('Phonetic suggestions prefix matching', () {
      final suggestions = engine.getPhoneticSuggestions('am');
      expect(suggestions.isNotEmpty, true);
      expect(suggestions.contains('আমি') || suggestions.contains('আমার') || suggestions.contains('আমাদের'), true);
    });

    test('Rule-based phonetic transliteration', () {
      final res = engine.parse('ami');
      expect(res, 'আমি');
    });
  });
}
