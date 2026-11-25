import '../../languages/dictionaries/en_us_dictionary.dart';
import '../../languages/dictionaries/bn_bd_dictionary.dart';
import '../../languages/dictionaries/hi_dictionary.dart';
import '../../languages/dictionaries/ar_dictionary.dart';
import '../../languages/dictionaries/ur_dictionary.dart';

class NgramPredictor {
  static final NgramPredictor _instance = NgramPredictor._internal();
  factory NgramPredictor() => _instance;
  NgramPredictor._internal();

  List<String> predictNextWords(String previousText, String languageCode, {int limit = 3}) {
    if (previousText.trim().isEmpty) return [];
    final tokens = previousText.trim().split(RegExp(r'\s+'));
    if (tokens.isEmpty) return [];

    final lastWord = tokens.last.toLowerCase();
    final lastTwoWords = tokens.length >= 2
        ? '${tokens[tokens.length - 2].toLowerCase()} $lastWord'
        : '';

    Map<String, List<String>> bigramMap;
    switch (languageCode) {
      case 'bn_BD':
        bigramMap = BnBdDictionary.bigrams;
        break;
      case 'en_US':
      case 'en_UK':
        bigramMap = EnUsDictionary.bigrams;
        break;
      case 'hi':
        bigramMap = HiDictionary.bigrams;
        break;
      case 'ar':
        bigramMap = ArDictionary.bigrams;
        break;
      case 'ur':
        bigramMap = UrDictionary.bigrams;
        break;
      default:
        bigramMap = EnUsDictionary.bigrams;
    }

    // Check 2-word context first
    if (lastTwoWords.isNotEmpty && bigramMap.containsKey(lastTwoWords)) {
      return bigramMap[lastTwoWords]!.take(limit).toList();
    }

    // Check single previous word context
    if (bigramMap.containsKey(lastWord)) {
      return bigramMap[lastWord]!.take(limit).toList();
    }

    return [];
  }
}
