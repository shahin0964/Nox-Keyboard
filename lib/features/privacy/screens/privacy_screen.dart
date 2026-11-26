import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../data/preferences_helper.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: 'Privacy & Security',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: const Color(0xFF10B981).withOpacity(0.35),
            fillColor: const Color(0xFF10B981).withOpacity(0.07),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.shield_fill, color: Color(0xFF34D399), size: 42),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your Keystrokes Never Leave Your Device',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Strict offline architecture. No telemetry, no cloud sync, no hidden logging.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.68)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const ModernSectionHeader(title: 'Security Guarantees', accentColor: Color(0xFF10B981)),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildPledgeItem(
                  icon: CupertinoIcons.lock_shield_fill,
                  color: const Color(0xFF38BDF8),
                  title: 'Password & Private Field Protection',
                  description: 'Suggestions and learning pause automatically inside password or credit card fields.',
                ),
                Divider(height: 22, color: Colors.white.withOpacity(0.06)),
                _buildPledgeItem(
                  icon: CupertinoIcons.wifi_slash,
                  color: const Color(0xFF10B981),
                  title: '100% Offline Typing & Avro Engine',
                  description: 'Dictionaries, Bangla Avro phonetic engine, and RGB themes run locally on your device.',
                ),
                Divider(height: 22, color: Colors.white.withOpacity(0.06)),
                _buildPledgeItem(
                  icon: CupertinoIcons.eye_slash_fill,
                  color: const Color(0xFFA855F7),
                  title: 'Zero Keystroke Logging',
                  description: 'Everything you save in custom dictionary or clipboard stays exclusively in local storage.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: Colors.redAccent.withOpacity(0.35),
            fillColor: Colors.redAccent.withOpacity(0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(CupertinoIcons.trash_fill, color: Colors.redAccent, size: 19),
                    SizedBox(width: 8),
                    Text(
                      'Delete All Learned Data',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Erase all custom words, shortcuts, and unpinned clipboard history from local storage.',
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.65)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF111827),
                          title: const Text('Delete Learned Data?', style: TextStyle(color: Colors.white)),
                          content: const Text(
                            'This will clear your custom words, shortcuts, and clipboard history.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete All'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _prefs.clearUserDictionary();
                        await _prefs.clearCustomShortcuts();
                        await _prefs.clearLearnedData();
                        await _prefs.clearUnpinnedClipboard();
                        await _prefs.clearUnpinnedImageClips();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All local learned data erased!')),
                          );
                        }
                      }
                    },
                    child: const Text('Reset Learned Data', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildPledgeItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernIconBadge(icon: icon, color: color, size: 18),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 3),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.58), height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
