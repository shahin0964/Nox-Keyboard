class BanglaPhoneticEngine {
  static final BanglaPhoneticEngine _instance = BanglaPhoneticEngine._internal();
  factory BanglaPhoneticEngine() => _instance;
  BanglaPhoneticEngine._internal();

  // Common high-frequency phonetic dictionary mappings
  static const Map<String, String> _dictionary = {
    'ami': 'আমি',
    'amra': 'আমরা',
    'amar': 'আমার',
    'amader': 'আমাদের',
    'amake': 'আমাকে',
    'tumi': 'তুমি',
    'tomra': 'তোমরা',
    'tomar': 'তোমার',
    'tomader': 'তোমাদের',
    'tomake': 'তোমাকে',
    'apni': 'আপনি',
    'apnara': 'আপনারা',
    'apnar': 'আপনার',
    'apnader': 'আপনাদের',
    'she': 'সে',
    'tara': 'তারা',
    'tader': 'তাদের',
    'take': 'তাকে',
    'tini': 'তিনি',
    'bangla': 'বাংলা',
    'bangladesh': 'বাংলাদেশ',
    'dhaka': 'ঢাকা',
    'bhalobashi': 'ভালোবাসি',
    'bhalobasha': 'ভালোবাসা',
    'kemon': 'কেমন',
    'achen': 'আছেন',
    'acho': 'আছো',
    'achi': 'আছি',
    'ki': 'কী',
    'khobor': 'খবর',
    'dhonnobad': 'ধন্যবাদ',
    'shagotom': 'স্বাগতম',
    'shundor': 'সুন্দর',
    'desh': 'দেশ',
    'kichu': 'কিছু',
    'shomoy': 'সময়',
    'kaj': 'কাজ',
    'bhalo': 'ভালো',
    'khub': 'খুব',
    'onek': 'অনেক',
    'ekhon': 'এখন',
    'kokhon': 'কখন',
    'tokhon': 'তখন',
    'kothay': 'কোথায়',
    'keno': 'কেন',
    'kivabe': 'কীভাবে',
    'hobe': 'হবে',
    'hoyeche': 'হয়েছে',
    'hoye': 'হয়ে',
    'ache': 'আছে',
    'nai': 'নাই',
    'nei': 'নেই',
    'asche': 'আসছে',
    'ashbo': 'আসবো',
    'jachhi': 'যাচ্ছি',
    'jabo': 'যাবো',
    'dekhi': 'দেখি',
    'dekho': 'দেখো',
    'dekhun': 'দেখুন',
    'bolchi': 'বলছি',
    'bolbo': 'বলবো',
    'shunchen': 'শুনছেন',
    'shunchi': 'শুনছি',
    'chai': 'চাই',
    'chan': 'চান',
    'parbo': 'পারবো',
    'paren': 'পারেন',
    'shob': 'সব',
    'shobai': 'সবাই',
    'manush': 'মানুষ',
    'jibon': 'জীবন',
    'mon': 'মন',
    'bondhu': 'বন্ধু',
    'bhai': 'ভাই',
    'bon': 'বোন',
    'ma': 'মা',
    'baba': 'বাবা',
    'ghor': 'ঘর',
    'bari': 'বাড়ি',
    'shokal': 'সকাল',
    'dupur': 'দুপুর',
    'shondha': 'সন্ধ্যা',
    'raat': 'রাত',
    'din': 'দিন',
    'aaj': 'আজ',
    'kal': 'কাল',
    'porshu': 'পরশু',
    'bochor': 'বছর',
    'mash': 'মাস',
    'shoptaho': 'সপ্তাহ',
    'notun': 'নতুন',
    'puraton': 'পুরাতন',
    'shotti': 'সত্যি',
    'mitthe': 'মিথ্যা',
    'thik': 'ঠিক',
    'bhul': 'ভুল',
    'shanto': 'শান্ত',
    'alo': 'আলো',
    'andhar': 'অন্ধকার',
    'pani': 'পানি',
    'jol': 'জল',
    'khabar': 'খাবার',
    'cha': 'চা',
    'bhat': 'ভাত',
    'roti': 'রুটি',
    'mach': 'মাছ',
    'mangsho': 'মাংস',
    'sobji': 'সবজি',
    'fol': 'ফল',
    'boi': 'বই',
    'katha': 'কথা',
    'gaan': 'গান',
    'chobi': 'ছবি',
    'mobile': 'মোবাইল',
    'phone': 'ফোন',
    'computer': 'কম্পিউটার',
    'internet': 'ইন্টারনেট',
    'shikha': 'শিক্ষা',
    'school': 'স্কুল',
    'college': 'কলেজ',
    'university': 'বিশ্ববিদ্যালয়',
    'office': 'অফিস',
    'bazar': 'বাজার',
    'dokan': 'দোকান',
    'rasta': 'রাস্তা',
    'gari': 'গাড়ি',
    'train': 'ট্রেন',
    'bristy': 'বৃষ্টি',
    'rod': 'রোদ',
    'batas': 'বাতাস',
    'akash': 'আকাশ',
    'nodi': 'নদী',
    'shaghor': 'সাগর',
    'pahar': 'পাহাড়',
    'gram': 'গ্রাম',
    'shohor': 'শহর',
    'nam': 'নাম',
    'kothao': 'কোথাও',
    'ekta': 'একটা',
    'duto': 'দুটো',
    'tin': 'তিন',
    'char': 'চার',
    'paach': 'পাঁচ',
    'choy': 'ছয়',
    'shaat': 'সাত',
    'aat': 'আট',
    'noy': 'নয়',
    'dosh': 'দশ',
    'shoto': 'শত',
    'hazar': 'হাজার',
    'lakh': 'লাখ',
    'koti': 'কোটি',
    'prothom': 'প্রথম',
    'shesh': 'শেষ',
    'shuru': 'শুরু',
    'kintu': 'কিন্তু',
    'ebong': 'এবং',
    'othoba': 'অথবা',
    'karon': 'কারণ',
    'tai': 'তাই',
    'tobu': 'তবু',
    'jodi': 'যদি',
    'tobe': 'তবে',
    'shathe': 'সাথে',
    'por': 'পর',
    'age': 'আগে',
    'majhe': 'মাঝে',
    'bhetore': 'ভেতরে',
    'baire': 'বাইরে',
    'upore': 'উপরে',
    'niche': 'নিচে',
    'samne': 'সামনে',
    'pichone': 'পেছনে',
    'kache': 'কাছে',
    'dure': 'দূরে',
    'choto': 'ছোট',
    'boro': 'বড়',
    'esho': 'এসো',
    'ashun': 'আসুন',
    'jaan': 'যান',
    'jao': 'যাও',
    'koro': 'করো',
    'korun': 'করুন',
    'korchi': 'করছি',
    'korbo': 'করবো',
    'khushi': 'খুশি',
    'duhkho': 'দুঃখ',
    'koshto': 'কষ্ট',
    'anondo': 'আনন্দ',
    'bhalo_theko': 'ভালো থেকো',
    'shubhokal': 'শুভ সকাল',
    'shubhoraat': 'শুভ রাত্রি',
  };

  // Check direct dictionary match
  String? getExactWord(String roman) {
    return _dictionary[roman.toLowerCase()];
  }

  // Get matching prefix candidates for auto-suggest
  List<String> getPhoneticSuggestions(String roman, {int limit = 5}) {
    if (roman.isEmpty) return [];
    final clean = roman.toLowerCase();
    final List<String> results = [];

    // Exact match first
    if (_dictionary.containsKey(clean)) {
      results.add(_dictionary[clean]!);
    }

    // Prefix matches in dictionary
    for (final entry in _dictionary.entries) {
      if (entry.key.startsWith(clean) && !results.contains(entry.value)) {
        results.add(entry.value);
        if (results.length >= limit) break;
      }
    }

    // Algorithmic transliteration fallback if needed
    final transliterated = parse(roman);
    if (!results.contains(transliterated)) {
      results.insert(results.isEmpty ? 0 : 1, transliterated);
    }

    return results.take(limit).toList();
  }

  // Full rule-based phonetic parser
  String parse(String input) {
    if (input.isEmpty) return '';
    final exact = _dictionary[input.toLowerCase()];
    if (exact != null) return exact;

    final StringBuffer buffer = StringBuffer();
    int i = 0;
    final int len = input.length;

    while (i < len) {
      bool matched = false;

      // 4-letter patterns
      if (i + 4 <= len) {
        final sub = input.substring(i, i + 4).toLowerCase();
        if (_fourLetterMap.containsKey(sub)) {
          buffer.write(_fourLetterMap[sub]);
          i += 4;
          continue;
        }
      }

      // 3-letter patterns
      if (i + 3 <= len) {
        final sub = input.substring(i, i + 3).toLowerCase();
        if (_threeLetterMap.containsKey(sub)) {
          buffer.write(_threeLetterMap[sub]);
          i += 3;
          continue;
        }
      }

      // 2-letter patterns
      if (i + 2 <= len) {
        final sub = input.substring(i, i + 2).toLowerCase();
        if (_twoLetterMap.containsKey(sub)) {
          buffer.write(_twoLetterMap[sub]);
          i += 2;
          continue;
        }
      }

      // Single letter
      final char = input[i];
      final lower = char.toLowerCase();
      final isUpper = char != lower;

      if (isUpper && _upperSingleMap.containsKey(char)) {
        buffer.write(_upperSingleMap[char]);
      } else if (_singleMap.containsKey(lower)) {
        buffer.write(_singleMap[lower]);
      } else {
        buffer.write(char);
      }
      i++;
    }

    return _postProcess(buffer.toString());
  }

  static const Map<String, String> _fourLetterMap = {
    'shch': 'শ্ছ',
    'kkhy': 'ক্ষ্য',
  };

  static const Map<String, String> _threeLetterMap = {
    'kkh': 'ক্ষ',
    'kkt': 'ক্ত',
    'gdh': 'গ্ধ',
    'ngh': 'ঙ্ঘ',
    'cch': 'চ্ছ',
    'jjh': 'জ্ঝ',
    'tth': 'ত্থ',
    'ddh': 'দ্ধ',
    'ndh': 'ন্ধ',
    'mbh': 'ম্ভ',
    'shc': 'শ্চ',
    'shn': 'শ্ন',
    'shm': 'শ্ম',
    'shl': 'শ্ল',
    'shk': 'ষ্ক',
    'sht': 'ষ্ট',
    'shth': 'ষ্ঠ',
    'shhn': 'ষ্ণ',
    'shp': 'ষ্প',
    'sph': 'স্ফ',
    'sth': 'স্থ',
    'skh': 'স্খ',
    'rri': 'ঋ',
    'kri': 'কৃ',
    'pri': 'পৃ',
    'mri': 'মৃ',
  };

  static const Map<String, String> _twoLetterMap = {
    'kh': 'খ',
    'gh': 'ঘ',
    'ng': 'ঙ',
    'ch': 'চ',
    'jh': 'ঝ',
    'th': 'থ',
    'dh': 'ধ',
    'ph': 'ফ',
    'bh': 'ভ',
    'sh': 'শ',
    'shh': 'ষ',
    'aa': 'া',
    'ee': 'ী',
    'oo': 'ূ',
    'oi': 'ৈ',
    'ou': 'ৌ',
    'ai': 'াই',
    'au': 'াউ',
    'kk': 'ক্ক',
    'gg': 'জ্ঞ',
    'cc': 'চ্চ',
    'jj': 'জ্জ',
    'tt': 'ত্ত',
    'dd': 'দ্দ',
    'nn': 'ন্ন',
    'pp': 'প্প',
    'bb': 'ব্ব',
    'mm': 'ম্ম',
    'll': 'ল্ল',
    'ss': 'স্স',
    'tr': 'ত্র',
    'pr': 'প্র',
    'kr': 'ক্র',
    'gr': 'গ্র',
    'br': 'ব্র',
    'dr': 'দ্র',
    'ky': 'ক্য',
    'py': 'প্য',
    'by': 'ব্য',
    'my': 'ম্য',
    'sy': 'স্য',
    'ty': 'ত্য',
    'dy': 'দ্য',
    'ly': 'ল্য',
  };

  static const Map<String, String> _upperSingleMap = {
    'T': 'ট',
    'D': 'ড',
    'N': 'ণ',
    'S': 'ষ',
    'R': 'ড়',
    'Y': 'য়',
  };

  static const Map<String, String> _singleMap = {
    'a': 'া',
    'b': 'ব',
    'c': 'চ',
    'd': 'দ',
    'e': 'ে',
    'f': 'ফ',
    'g': 'গ',
    'h': 'হ',
    'i': 'ি',
    'j': 'জ',
    'k': 'ক',
    'l': 'ল',
    'm': 'ম',
    'n': 'ন',
    'o': 'ো',
    'p': 'প',
    'q': 'ক',
    'r': 'র',
    's': 'স',
    't': 'ত',
    'u': 'ু',
    'v': 'ভ',
    'w': 'ও',
    'x': 'ক্স',
    'y': 'ই',
    'z': 'য',
  };

  String _postProcess(String str) {
    if (str.isEmpty) return str;
    // Replace standalone initial kar with full vowel
    final Map<String, String> initialVowelMap = {
      'া': 'আ',
      'ি': 'ই',
      'ী': 'ঈ',
      'ু': 'উ',
      'ূ': 'ঊ',
      'ে': 'এ',
      'ৈ': 'ঐ',
      'ো': 'ও',
      'ৌ': 'ঔ',
    };

    if (initialVowelMap.containsKey(str.substring(0, 1))) {
      str = initialVowelMap[str.substring(0, 1)]! + str.substring(1);
    }

    return str;
  }
}
