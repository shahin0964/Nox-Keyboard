import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nox_keyboard/keyboard/suggestions/dictionary_service.dart';
import 'package:nox_keyboard/keyboard/suggestions/ngram_predictor.dart';
import 'package:nox_keyboard/keyboard/suggestions/autocorrect_service.dart';
import 'package:nox_keyboard/keyboard/suggestions/suggestion_engine.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Suggestions and Autocorrect Tests', () {
    test('DictionaryService prefix search', () {
      final service = DictionaryService();
      final results = service.searchPrefix('tha', 'en_US');
      expect(results.isNotEmpty, true);
      expect(results.contains('that') || results.contains('thanks') || results.contains('thank'), true);
    });

    test('NgramPredictor predicts next word', () {
      final predictor = NgramPredictor();
      final nextWords = predictor.predictNextWords('how are', 'en_US');
      expect(nextWords.contains('you'), true);
    });

    test('AutocorrectService detects common typos across English & Bangla', () {
      final autocorrect = AutocorrectService();
      expect(autocorrect.findCorrection('teh', 'en_US'), 'the');
      expect(autocorrect.findCorrection('adn', 'en_US'), 'and');
      expect(autocorrect.findCorrection('dont', 'en_US'), "don't");
      expect(autocorrect.findCorrection('tomorow', 'en_US'), 'tomorrow');
      expect(autocorrect.findCorrection('ভালবাসা', 'bn_BD'), 'ভালোবাসা');
      expect(autocorrect.findCorrection('বাংলাদেস', 'bn_BD'), 'বাংলাদেশ');
    });

    test('SuggestionEngine generates candidates including Bangla spell fix', () {
      final engine = SuggestionEngine();
      final candidates = engine.getSuggestions(
        composingWord: 'tha',
        contextBefore: '',
        languageCode: 'en_US',
        isBanglaPhonetic: false,
        autocorrectEnabled: true,
        nextWordEnabled: true,
      );
      expect(candidates.isNotEmpty, true);

      final bnCandidates = engine.getSuggestions(
        composingWord: 'বাংলাদেস',
        contextBefore: '',
        languageCode: 'bn_BD',
        isBanglaPhonetic: false,
        autocorrectEnabled: true,
        nextWordEnabled: true,
      );
      expect(bnCandidates.any((c) => c.text == 'বাংলাদেশ'), true);
    });
  });
}
