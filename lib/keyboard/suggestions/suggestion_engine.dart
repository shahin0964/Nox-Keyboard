import '../../data/preferences_helper.dart';
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
      final cleanLower = composingWord.toLowerCase();
      final prefs = PreferencesHelper();
      final shortcuts = prefs.customShortcuts;
      if (shortcuts.containsKey(cleanLower)) {
        candidates.add(SuggestionCandidate(text: composingWord));
        candidates.add(SuggestionCandidate(text: shortcuts[cleanLower]!, isAutocorrect: true, isUserWord: true));
      }

      // Prioritize user's personally learned words from their past typing
      final learnedMatches = prefs.searchLearnedPrefix(composingWord, limit: 3);
      for (final lw in learnedMatches) {
        if (!candidates.any((c) => c.text == lw)) {
          candidates.add(SuggestionCandidate(text: lw, isUserWord: true));
        }
      }

      if (languageCode == 'bn_avro' || (languageCode == 'bn_BD' && isBanglaPhonetic)) {
        // Bangla Avro Phonetic Suggestions
        final phoneticMatches = _banglaPhonetic.getPhoneticSuggestions(composingWord, limit: 3);
        for (int i = 0; i < phoneticMatches.length; i++) {
          final text = phoneticMatches[i];
          if (!candidates.any((c) => c.text == text)) {
            candidates.add(
              SuggestionCandidate(
                text: text,
                isAutocorrect: candidates.isEmpty && i == 0,
              ),
            );
          }
        }
      } else {
        // Direct language suggestions
        final prefixMatches = _dictionaryService.searchPrefix(composingWord, languageCode, limit: 3);
        String? correction;
        if (autocorrectEnabled && candidates.isEmpty) {
          correction = _autocorrectService.findCorrection(composingWord, languageCode);
        }

        // Center candidate is autocorrect or exact top prefix match
        if (candidates.isEmpty && correction != null && correction.toLowerCase() != cleanLower) {
          candidates.add(SuggestionCandidate(text: composingWord)); // Raw literal typed on left
          candidates.add(SuggestionCandidate(text: correction, isAutocorrect: true)); // Autocorrect in center
          if (prefixMatches.isNotEmpty && prefixMatches.first != correction) {
            candidates.add(SuggestionCandidate(text: prefixMatches.first));
          }
        } else if (prefixMatches.isNotEmpty) {
          if (candidates.isEmpty && prefixMatches.length >= 3) {
            candidates.add(SuggestionCandidate(text: prefixMatches[1]));
            candidates.add(SuggestionCandidate(text: prefixMatches[0], isAutocorrect: true));
            candidates.add(SuggestionCandidate(text: prefixMatches[2]));
          } else {
            if (candidates.isEmpty) {
              candidates.add(SuggestionCandidate(text: composingWord));
            }
            for (final m in prefixMatches) {
              if (!candidates.any((c) => c.text == m)) {
                candidates.add(SuggestionCandidate(text: m, isAutocorrect: candidates.length == 1));
              }
            }
          }
        } else if (candidates.isEmpty) {
          // No dictionary matches: present what user typed
          candidates.add(SuggestionCandidate(text: composingWord, isAutocorrect: false));
        }
      }
    } else if (nextWordEnabled && contextBefore.isNotEmpty) {
      // 2. Composing word is empty: prioritize user's learned follow-up words, then n-grams
      final tokens = contextBefore.trim().split(RegExp(r'\s+'));
      if (tokens.isNotEmpty) {
        final learnedNext = PreferencesHelper().getLearnedNextWords(tokens.last, limit: 2);
        for (final ln in learnedNext) {
          candidates.add(SuggestionCandidate(text: ln, isUserWord: true));
        }
      }
      final nextWords = _ngramPredictor.predictNextWords(contextBefore, languageCode, limit: 3);
      for (final nw in nextWords) {
        if (!candidates.any((c) => c.text == nw)) {
          candidates.add(SuggestionCandidate(text: nw));
        }
      }
    }

    return candidates.take(3).toList();
  }
}
