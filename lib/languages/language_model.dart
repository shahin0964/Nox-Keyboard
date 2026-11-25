class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isRtl;
  final bool hasPhonetic;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isRtl = false,
    this.hasPhonetic = false,
  });

  static const LanguageModel englishUs = LanguageModel(
    code: 'en_US',
    name: 'English (US)',
    nativeName: 'English (US)',
    flag: '🇺🇸',
    isRtl: false,
    hasPhonetic: false,
  );

  static const LanguageModel englishUk = LanguageModel(
    code: 'en_UK',
    name: 'English (UK)',
    nativeName: 'English (UK)',
    flag: '🇬🇧',
    isRtl: false,
    hasPhonetic: false,
  );

  static const LanguageModel bangla = LanguageModel(
    code: 'bn_BD',
    name: 'Bangla (Bangladesh)',
    nativeName: 'বাংলা',
    flag: '🇧🇩',
    isRtl: false,
    hasPhonetic: true,
  );

  static const LanguageModel hindi = LanguageModel(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    flag: '🇮🇳',
    isRtl: false,
    hasPhonetic: false,
  );

  static const LanguageModel arabic = LanguageModel(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flag: '🇸🇦',
    isRtl: true,
    hasPhonetic: false,
  );

  static const LanguageModel urdu = LanguageModel(
    code: 'ur',
    name: 'Urdu',
    nativeName: 'اردو',
    flag: '🇵🇰',
    isRtl: true,
    hasPhonetic: false,
  );

  static List<LanguageModel> get supportedLanguages => [
    bangla,
    englishUs,
    englishUk,
    hindi,
    arabic,
    urdu,
  ];

  static LanguageModel findByCode(String code) {
    return supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => englishUs,
    );
  }
}
