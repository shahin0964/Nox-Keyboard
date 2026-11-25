import 'dart:math';
import 'dictionary_service.dart';

class AutocorrectService {
  static final AutocorrectService _instance = AutocorrectService._internal();
  factory AutocorrectService() => _instance;
  AutocorrectService._internal();

  static const Map<String, String> _commonEnglishTypos = {
    'teh': 'the',
    'adn': 'and',
    'taht': 'that',
    'recieve': 'receive',
    'seperate': 'separate',
    'becuase': 'because',
    'definatly': 'definitely',
    'im': "I'm",
    'dont': "don't",
    'cant': "can't",
    'wont': "won't",
    'youre': "you're",
    'theyre': "they're",
    'hes': "he's",
    'shes': "she's",
    'weve': "we've",
    'didnt': "didn't",
    'couldnt': "couldn't",
    'wouldnt': "wouldn't",
    'shouldnt': "shouldn't",
    'alot': 'a lot',
    'occured': 'occurred',
    'thier': 'their',
    'untill': 'until',
  };

  // Stack of last applied autocorrection: {original: 'teh', corrected: 'the'}
  Map<String, String>? _lastAutocorrection;
  Map<String, String>? get lastAutocorrection => _lastAutocorrection;

  void recordAutocorrect(String original, String corrected) {
    _lastAutocorrection = {'original': original, 'corrected': corrected};
  }

  void clearLastAutocorrect() {
    _lastAutocorrection = null;
  }

  String? findCorrection(String input, String languageCode) {
    if (input.length < 2) return null;
    final lower = input.toLowerCase();

    // Check common typos
    if (_commonEnglishTypos.containsKey(lower)) {
      return _matchCase(input, _commonEnglishTypos[lower]!);
    }

    // Levenshtein distance against known vocabulary
    final words = DictionaryService().getWordsForLanguage(languageCode);
    String? bestMatch;
    int minDistance = 999;

    for (final word in words) {
      if ((word.length - input.length).abs() > 2) continue;
      final dist = _levenshtein(lower, word.toLowerCase());
      if (dist <= 2 && dist < minDistance) {
        minDistance = dist;
        bestMatch = word;
      }
    }

    if (bestMatch != null && minDistance <= (input.length > 4 ? 2 : 1)) {
      return _matchCase(input, bestMatch);
    }

    return null;
  }

  int _levenshtein(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        dp[i][j] = min(
          dp[i - 1][j] + 1, // deletion
          min(
            dp[i][j - 1] + 1, // insertion
            dp[i - 1][j - 1] + cost, // substitution
          ),
        );
      }
    }
    return dp[m][n];
  }

  String _matchCase(String source, String target) {
    if (source.isEmpty || target.isEmpty) return target;
    if (source == source.toUpperCase()) return target.toUpperCase();
    if (source[0] == source[0].toUpperCase()) {
      return target[0].toUpperCase() + target.substring(1);
    }
    return target;
  }
}
