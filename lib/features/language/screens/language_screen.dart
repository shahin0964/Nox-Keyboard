import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../languages/language_model.dart';
import '../../../languages/language_manager.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final LanguageManager _langManager = LanguageManager();

  @override
  void initState() {
    super.initState();
    _langManager.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _langManager.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = _langManager.currentLanguage;
    final enabledCodes = _langManager.enabledLanguageCodes;

    return ModernScaffold(
      title: 'Languages & Avro',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // Bangla Avro Highlight Banner
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: const Color(0xFF10B981).withOpacity(0.38),
            fillColor: const Color(0xFF10B981).withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🇧🇩', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'বাংলা অভ্র (Bangla Avro)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AVRO',
                        style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ইংরেজি অক্ষরে বাংলা লিখুন (যেমন: "ami" → "আমি", "ovro" → "অভ্র", "dhonnobad" → "ধন্যবাদ")। স্পেসবার বা 🌐 বাটন দিয়েই যেকোনো সময় বাংলা অভ্র-তে সুইচ করতে পারবেন।',
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.72), height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const ModernSectionHeader(title: 'Keyboard Languages (Tap to Set Active)'),

          ...LanguageModel.supportedLanguages.map((lang) {
            final isPrimary = lang.code == current.code;
            final isEnabled = enabledCodes.contains(lang.code);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                borderRadius: 18,
                borderColor: isPrimary
                    ? const Color(0xFF00E5FF).withOpacity(0.7)
                    : Colors.white.withOpacity(0.08),
                fillColor: isPrimary
                    ? const Color(0xFF00E5FF).withOpacity(0.08)
                    : Colors.white.withOpacity(0.04),
                onTap: () {
                  if (!isEnabled) {
                    _langManager.toggleLanguageEnabled(lang.code);
                  }
                  _langManager.setLanguage(lang.code);
                },
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  lang.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isPrimary) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00E5FF),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${lang.nativeName}${lang.hasPhonetic ? " • Phonetic Transliteration" : (lang.isRtl ? " • RTL Layout" : " • Standard Layout")}',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.55)),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isEnabled,
                      activeColor: const Color(0xFF00E5FF),
                      onChanged: (_) => _langManager.toggleLanguageEnabled(lang.code),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const ModernIconBadge(icon: CupertinoIcons.globe, color: Color(0xFF38BDF8), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Tap 🌐 or long-press the Spacebar on your keyboard to switch between enabled languages anytime.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65), height: 1.35),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
