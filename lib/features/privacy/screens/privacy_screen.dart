import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Security Shield Badge
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.shield_fill, color: Color(0xFF10B981), size: 52),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Your Keystrokes Never Leave Your Device',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Nox Keyboard is architected with a strict privacy-first, zero-cloud policy. We believe a keyboard must never transmit user input to remote servers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Security Guarantees
          _buildPledgeItem(
            icon: CupertinoIcons.lock_shield_fill,
            title: 'Password & Secure Input Protection',
            description: 'When typing into password fields or credit card numbers, Nox Keyboard automatically enters Private Mode. Autocorrection and word suggestions are strictly disabled.',
          ),

          _buildPledgeItem(
            icon: CupertinoIcons.wifi_slash,
            title: '100% Offline Typing Engine',
            description: 'The multilingual dictionaries, Bangla phonetic engine, autocorrection, and theme engine function completely offline without internet connectivity.',
          ),

          _buildPledgeItem(
            icon: CupertinoIcons.eye_slash_fill,
            title: 'Zero Keystroke Logging or Telemetry',
            description: 'We do not collect keystrokes, clipboard snippets, or user-learned frequency lists. All personalization data remains encrypted and stored strictly on your local phone.',
          ),

          _buildPledgeItem(
            icon: CupertinoIcons.doc_plaintext,
            title: 'Encrypted Personal Dictionary',
            description: 'Your personal words and frequent vocabulary are stored locally in Android app storage.',
          ),

          const SizedBox(height: 20),

          // Data Management Actions
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            color: Colors.red.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.trash, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete All Learned Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Erase all user-added dictionary words and recent clipboard history stored locally on this phone.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Learned Data?'),
                          content: const Text('This will reset your personal dictionary and clipboard history.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete All'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _prefs.clearUserDictionary();
                        await _prefs.clearUnpinnedClipboard();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All local learned data erased!')),
                          );
                        }
                      }
                    },
                    child: const Text('Reset Learned Data'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPledgeItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
