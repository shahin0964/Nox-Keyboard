import '../engine/bangla_phonetic_engine.dart';
import 'dictionary_service.dart';
import 'ngram_predictor.dart';
import 'autocorrect_service.dart';

class SuggestionCandidate {
  final String text;
  final bool isAutocorrect;
  final bool isUserWord;

  const SuggestionCandidate({
    required this.text,
    this.isAutocorrect = false,
    this.isUserWord = false,
  });
}

class SuggestionEngine {
  static final SuggestionEngine _instance = SuggestionEngine._internal();
  factory SuggestionEngine() => _instance;
  SuggestionEngine._internal();

  final DictionaryService _dictionaryService = DictionaryService();
  final NgramPredictor _ngramPredictor = NgramPredictor();
  final AutocorrectService _autocorrectService = AutocorrectService();
  final BanglaPhoneticEngine _banglaPhonetic = BanglaPhoneticEngine();

  List<SuggestionCandidate> getSuggestions({
    required String composingWord,
    required String contextBefore,
    required String languageCode,
    required bool isBanglaPhonetic,
    required bool autocorrectEnabled,
    required bool nextWordEnabled,
  }) {
    final List<SuggestionCandidate> candidates = [];

    // 1. If currently typing a word
    if (composingWord.isNotEmpty) {
      if (languageCode == 'bn_BD' && isBanglaPhonetic) {
        // Bangla Phonetic Suggestions
        final phoneticMatches = _banglaPhonetic.getPhoneticSuggestions(composingWord, limit: 3);
        for (int i = 0; i < phoneticMatches.length; i++) {
          candidates.add(
            SuggestionCandidate(
              text: phoneticMatches[i],
              isAutocorrect: i == 0,
            ),
          );
        }
      } else {
        // Direct language suggestions
        final prefixMatches = _dictionaryService.searchPrefix(composingWord, languageCode, limit: 3);
        String? correction;
        if (autocorrectEnabled) {
          correction = _autocorrectService.findCorrection(composingWord, languageCode);
        }

        // Center candidate is autocorrect or exact top prefix match
        if (correction != null && correction.toLowerCase() != composingWord.toLowerCase()) {
          candidates.add(SuggestionCandidate(text: composingWord)); // Raw literal typed on left
          candidates.add(SuggestionCandidate(text: correction, isAutocorrect: true)); // Autocorrect in center
          if (prefixMatches.isNotEmpty && prefixMatches.first != correction) {
            candidates.add(SuggestionCandidate(text: prefixMatches.first));
          }
        } else if (prefixMatches.isNotEmpty) {
          if (prefixMatches.length >= 3) {
            candidates.add(SuggestionCandidate(text: prefixMatches[1]));
            candidates.add(SuggestionCandidate(text: prefixMatches[0], isAutocorrect: true));
            candidates.add(SuggestionCandidate(text: prefixMatches[2]));
          } else if (prefixMatches.length == 2) {
            candidates.add(SuggestionCandidate(text: composingWord));
            candidates.add(SuggestionCandidate(text: prefixMatches[0], isAutocorrect: true));
            candidates.add(SuggestionCandidate(text: prefixMatches[1]));
          } else {
            candidates.add(SuggestionCandidate(text: composingWord));
            candidates.add(SuggestionCandidate(text: prefixMatches[0], isAutocorrect: true));
          }
        } else {
          // No dictionary matches: present what user typed
          candidates.add(SuggestionCandidate(text: composingWord, isAutocorrect: false));
        }
      }
    } else if (nextWordEnabled && contextBefore.isNotEmpty) {
      // 2. Composing word is empty: perform Next-Word Prediction based on context
      final nextWords = _ngramPredictor.predictNextWords(contextBefore, languageCode, limit: 3);
      for (final nw in nextWords) {
        candidates.add(SuggestionCandidate(text: nw));
      }
    }

    return candidates.take(3).toList();
  }
}
