import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Languages & Layouts', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Bangla Special Mode Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            ),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🇧🇩', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      const Text(
                        'Bangla Typing Mode',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how you prefer to type Bangla characters:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<bool>(
                    title: const Text('Phonetic Typing (Recommended)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Type roman letters to produce Bangla words (e.g. "ami" -> "আমি")'),
                    value: true,
                    groupValue: _langManager.isBanglaPhonetic,
                    onChanged: (val) {
                      if (val != null) _langManager.toggleBanglaPhonetic();
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('National / Probhat Layout', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Direct Bengali keyboard layout with vowels, consonants & kar'),
                    value: false,
                    groupValue: _langManager.isBanglaPhonetic,
                    onChanged: (val) {
                      if (val != null) _langManager.toggleBanglaPhonetic();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Active Primary Language',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),

          const SizedBox(height: 8),

          // Primary language selector
          ...LanguageModel.supportedLanguages.map((lang) {
            final isPrimary = lang.code == current.code;
            final isEnabled = enabledCodes.contains(lang.code);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isPrimary
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.15),
                  width: isPrimary ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: Text(lang.flag, style: const TextStyle(fontSize: 26)),
                title: Text(
                  lang.name,
                  style: TextStyle(
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${lang.nativeName} • ${lang.isRtl ? "RTL Layout • " : ""}Offline Dictionary Ready',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isEnabled,
                      onChanged: (val) {
                        _langManager.toggleLanguageEnabled(lang.code);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  _langManager.setLanguage(lang.code);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
