import 'dart:math';
import 'dictionary_service.dart';

class AutocorrectService {
  static final AutocorrectService _instance = AutocorrectService._internal();
  factory AutocorrectService() => _instance;
  AutocorrectService._internal();

  static const Map<String, String> _commonTypos = {
    'teh': 'the',
    'adn': 'and',
    'taht': 'that',
    'recieve': 'receive',
    'seperate': 'separate',
    'becuase': 'because',
    'definatly': 'definitely',
    'definately': 'definitely',
    'tomorow': 'tomorrow',
    'tommorow': 'tomorrow',
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
    'ভালবাসা': 'ভালোবাসা',
    'ভাল': 'ভালো',
    'বাংলাদেস': 'বাংলাদেশ',
    'বাঙলাদেশ': 'বাংলাদেশ',
    'সন্দুর': 'সুন্দর',
    'ধন্যবাধ': 'ধন্যবাদ',
    'কেমোন': 'কেমন',
  };

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

    // 1. O(1) known typo map
    final common = _commonTypos[lower];
    if (common != null) {
      return _matchCase(input, common);
    }

    if (input.length < 3) return null;

    final dict = DictionaryService();

    // 2. O(1) exact dictionary exit (never alter already-valid words)
    if (dict.containsExact(lower, languageCode)) {
      return null;
    }

    // 3. O(1) SymSpell fast edit-distance-1 match across full loaded dictionary
    final fastMatch = dict.findFastCorrection(lower, languageCode);
    if (fastMatch != null && fastMatch.toLowerCase() != lower) {
      return _matchCase(input, fastMatch);
    }

    // 4. Bounded edit-distance-2 check on same/adjacent length frequency buckets
    final candidates = dict.getLengthBucketCandidates(lower.length, languageCode);
    String? bestMatch;
    int minDistance = 999;
    int scanned = 0;

    for (final word in candidates) {
      if (++scanned > 260) break;
      final wLow = word.toLowerCase();
      if (wLow.isEmpty || wLow[0] != lower[0]) continue;
      final dist = _levenshtein(lower, wLow);
      if (dist <= 2 && dist < minDistance) {
        minDistance = dist;
        bestMatch = word;
        if (dist == 1) break;
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
    List<int> prev = List<int>.generate(n + 1, (j) => j);
    List<int> curr = List<int>.filled(n + 1, 0);

    for (int i = 1; i <= m; i++) {
      curr[0] = i;
      final c1 = s1.codeUnitAt(i - 1);
      for (int j = 1; j <= n; j++) {
        final cost = (c1 == s2.codeUnitAt(j - 1)) ? 0 : 1;
        final del = prev[j] + 1;
        final ins = curr[j - 1] + 1;
        final sub = prev[j - 1] + cost;
        curr[j] = min(min(del, ins), sub);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }

    return prev[n];
  }

  String _matchCase(String original, String corrected) {
    if (original.isEmpty || corrected.isEmpty) return corrected;
    if (original == original.toUpperCase() && original != original.toLowerCase()) {
      return corrected.toUpperCase();
    }
    if (original[0] == original[0].toUpperCase() && original[0] != original[0].toLowerCase()) {
      return corrected[0].toUpperCase() + corrected.substring(1);
    }
    return corrected;
  }
}
