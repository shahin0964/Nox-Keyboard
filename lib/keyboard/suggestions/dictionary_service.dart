import 'dart:collection';
import 'package:flutter/services.dart' show rootBundle;
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

  final Map<String, List<String>> _assetWords = {};
  final Map<String, HashSet<String>> _wordSets = {};
  final Map<String, Map<String, List<String>>> _prefixBuckets = {};
  final Map<String, Map<int, List<String>>> _lengthBuckets = {};
  final Map<String, Map<String, String>> _deleteIndex = {};
  final Map<String, Future<void>> _loadingFutures = {};

  static String _groupFor(String languageCode) {
    switch (languageCode) {
      case 'bn_avro':
      case 'bn_BD':
        return 'bn';
      case 'hi':
        return 'hi';
      case 'ar':
        return 'ar';
      case 'ur':
        return 'ur';
      case 'en_US':
      case 'en_UK':
      default:
        return 'en';
    }
  }

  static String _assetForGroup(String group) {
    switch (group) {
      case 'bn':
        return 'assets/dictionaries/bn_bd.txt';
      case 'hi':
        return 'assets/dictionaries/hi.txt';
      case 'ar':
        return 'assets/dictionaries/ar.txt';
      case 'ur':
        return 'assets/dictionaries/ur.txt';
      case 'en':
      default:
        return 'assets/dictionaries/en_us.txt';
    }
  }

  static List<String> _fallbackWordsForGroup(String group) {
    switch (group) {
      case 'bn':
        return BnBdDictionary.words;
      case 'hi':
        return HiDictionary.words;
      case 'ar':
        return ArDictionary.words;
      case 'ur':
        return UrDictionary.words;
      case 'en':
      default:
        return EnUsDictionary.words;
    }
  }

  /// Preloads full offline frequency wordlists cleanly on first use without blocking UI.
  Future<void> ensureLoaded(String languageCode) {
    final group = _groupFor(languageCode);
    if (_assetWords.containsKey(group)) return Future.value();
    return _loadingFutures[group] ??= _loadGroup(group);
  }

  Future<void> _loadGroup(String group) async {
    try {
      final raw = await rootBundle.loadString(_assetForGroup(group));
      final lines = raw.split('\n');
      final List<String> merged = [];
      final HashSet<String> seen = HashSet<String>();

      void addWord(String rawWord) {
        final w = rawWord.trim();
        if (w.isEmpty) return;
        final low = w.toLowerCase();
        if (seen.add(low)) {
          merged.add(w);
        }
      }

      for (final w in _fallbackWordsForGroup(group)) {
        addWord(w);
      }
      for (final line in lines) {
        addWord(line);
      }

      _assetWords[group] = merged;
      _buildIndices(group, merged);
    } catch (_) {
      // Safe fallback when running in headless Dart tests without asset bundle
      final fallback = _fallbackWordsForGroup(group);
      _assetWords[group] = fallback;
      _buildIndices(group, fallback);
    }
  }

  void _ensureSyncIndices(String group) {
    if (_wordSets.containsKey(group)) return;
    _buildIndices(group, _fallbackWordsForGroup(group));
  }

  void _buildIndices(String group, List<String> words) {
    final HashSet<String> set = HashSet<String>();
    final Map<String, List<String>> prefix = {};
    final Map<int, List<String>> lengths = {};
    final Map<String, String> deletes = {};

    final int symSpellLimit = words.length < 9000 ? words.length : 9000;

    for (int i = 0; i < words.length; i++) {
      final w = words[i];
      if (w.isEmpty) continue;
      final low = w.toLowerCase();
      set.add(low);

      final firstChar = low[0];
      prefix.putIfAbsent(firstChar, () => []).add(w);

      final len = low.length;
      final lenList = lengths.putIfAbsent(len, () => []);
      if (lenList.length < 600) {
        lenList.add(w);
      }

      if (i < symSpellLimit && len >= 3 && len <= 16) {
        for (int pos = 0; pos < len; pos++) {
          final del = '${low.substring(0, pos)}${low.substring(pos + 1)}';
          deletes.putIfAbsent(del, () => w);
        }
      }
    }

    _wordSets[group] = set;
    _prefixBuckets[group] = prefix;
    _lengthBuckets[group] = lengths;
    _deleteIndex[group] = deletes;
  }

  List<String> getWordsForLanguage(String languageCode) {
    final group = _groupFor(languageCode);
    final userWords = PreferencesHelper().userDictionary;
    final base = _assetWords[group] ?? _fallbackWordsForGroup(group);
    if (userWords.isEmpty) return base;
    return [...userWords, ...base];
  }

  int wordCountForLanguage(String languageCode) {
    final group = _groupFor(languageCode);
    return (_assetWords[group] ?? _fallbackWordsForGroup(group)).length;
  }

  bool containsExact(String word, String languageCode) {
    final clean = word.trim().toLowerCase();
    if (clean.isEmpty) return false;
    for (final uw in PreferencesHelper().userDictionary) {
      if (uw.toLowerCase() == clean) return true;
    }
    final group = _groupFor(languageCode);
    _ensureSyncIndices(group);
    return _wordSets[group]?.contains(clean) ?? false;
  }

  /// O(1) lookup for edit-distance-1 errors (deletions, insertions, swaps, substitutions).
  String? findFastCorrection(String input, String languageCode) {
    final low = input.trim().toLowerCase();
    if (low.length < 2) return null;

    final group = _groupFor(languageCode);
    _ensureSyncIndices(group);
    final set = _wordSets[group]!;
    final deletes = _deleteIndex[group]!;

    // 1. Exact deletion hit -> input had an extra char (e.g. "helllo" -> "hello", "বাংলাা" -> "বাংলা")
    for (int i = 0; i < low.length; i++) {
      final del = '${low.substring(0, i)}${low.substring(i + 1)}';
      if (set.contains(del)) {
        return _findCanonicalCase(group, del);
      }
    }

    // 2. Adjacent character swap -> transposition (e.g. "teh" -> "the", "recieve" -> "receive")
    for (int i = 0; i < low.length - 1; i++) {
      final swapped =
          '${low.substring(0, i)}${low[i + 1]}${low[i]}${low.substring(i + 2)}';
      if (set.contains(swapped)) {
        return _findCanonicalCase(group, swapped);
      }
    }

    // 3. Direct SymSpell delete hit -> input missed 1 char (e.g. "tomorow" -> "tomorrow")
    if (deletes.containsKey(low)) {
      return deletes[low];
    }

    // 4. Delete-1 on input checked against deleteIndex -> 1 substituted char (e.g. "helo" or "বাংলাদেস")
    for (int i = 0; i < low.length; i++) {
      final del = '${low.substring(0, i)}${low.substring(i + 1)}';
      final candidate = deletes[del];
      if (candidate != null && (candidate.length - low.length).abs() <= 1) {
        return candidate;
      }
    }

    return null;
  }

  String _findCanonicalCase(String group, String lowerMatch) {
    final bucket = _prefixBuckets[group]?[lowerMatch[0]];
    if (bucket != null) {
      for (final w in bucket) {
        if (w.toLowerCase() == lowerMatch) return w;
      }
    }
    return lowerMatch;
  }

  List<String> getLengthBucketCandidates(int targetLen, String languageCode) {
    final group = _groupFor(languageCode);
    _ensureSyncIndices(group);
    final buckets = _lengthBuckets[group];
    if (buckets == null) return const [];
    return [
      ...?buckets[targetLen],
      ...?buckets[targetLen - 1],
      ...?buckets[targetLen + 1],
    ];
  }

  List<String> searchPrefix(String prefix, String languageCode, {int limit = 5}) {
    final clean = prefix.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final List<String> matches = [];
    final HashSet<String> seen = HashSet<String>();

    for (final w in PreferencesHelper().userDictionary) {
      if (w.toLowerCase().startsWith(clean) && seen.add(w.toLowerCase())) {
        matches.add(w);
        if (matches.length >= limit) return matches;
      }
    }

    final group = _groupFor(languageCode);
    _ensureSyncIndices(group);
    final bucket = _prefixBuckets[group]?[clean[0]];
    if (bucket != null) {
      for (final w in bucket) {
        final low = w.toLowerCase();
        if (low.startsWith(clean) && seen.add(low)) {
          matches.add(w);
          if (matches.length >= limit) break;
        }
      }
    }
    return matches;
  }
}
