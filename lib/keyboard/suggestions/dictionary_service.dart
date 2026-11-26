import '../../data/preferences_helper.dart';
import '../../languages/dictionaries/en_us_dictionary.dart';
import '../../languages/dictionaries/bn_bd_dictionary.dart';
import '../../languages/dictionaries/hi_dictionary.dart';
import '../../languages/dictionaries/ar_dictionary.dart';
import '../../languages/dictionaries/ur_dictionary.dart';

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal();

  List<String> getWordsForLanguage(String languageCode) {
    final List<String> list = [];

    // Add user custom dictionary words first (highest priority)
    list.addAll(PreferencesHelper().userDictionary);

    switch (languageCode) {
      case 'bn_avro':
      case 'bn_BD':
        list.addAll(BnBdDictionary.words);
        break;
      case 'en_US':
      case 'en_UK':
        list.addAll(EnUsDictionary.words);
        break;
      case 'hi':
        list.addAll(HiDictionary.words);
        break;
      case 'ar':
        list.addAll(ArDictionary.words);
        break;
      case 'ur':
        list.addAll(UrDictionary.words);
        break;
      default:
        list.addAll(EnUsDictionary.words);
    }
    return list;
  }

  List<String> searchPrefix(String prefix, String languageCode, {int limit = 5}) {
    if (prefix.trim().isEmpty) return [];
    final clean = prefix.toLowerCase();
    final allWords = getWordsForLanguage(languageCode);
    final List<String> matches = [];

    for (final word in allWords) {
      if (word.toLowerCase().startsWith(clean)) {
        if (!matches.contains(word)) {
          matches.add(word);
          if (matches.length >= limit) break;
        }
      }
    }
    return matches;
  }
}
