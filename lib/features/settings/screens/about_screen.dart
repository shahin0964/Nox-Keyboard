import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Nox Keyboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // App Logo / Avatar
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.keyboard, size: 44, color: Colors.white),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              'Version ${AppConstants.appVersion} (${AppConstants.packageName})',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 24),

          // Overview card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Identity & Vision', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text(
                    'Nox Keyboard is a production-quality Android system keyboard application engineered with Flutter/Dart. It delivers a fast, responsive, and private typing experience inspired by Google Gboard.',
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow('Package', AppConstants.packageName),
                  _buildDetailRow('Platform', 'Android System Input Method (IME)'),
                  _buildDetailRow('Framework', 'Flutter & Dart Engine'),
                  _buildDetailRow('License', 'Apache-2.0 / Proprietary Nox'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Core highlights
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Key Capabilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  _buildCheck('Bangla Phonetic Transliteration (Avro/Ridmik inspired)'),
                  _buildCheck('Multilingual Support (Bangla, English, Hindi, Arabic, Urdu)'),
                  _buildCheck('Modern Material 3 Design with 6 Built-in Themes'),
                  _buildCheck('Custom Theme Visual Editor with Live Preview'),
                  _buildCheck('Spacebar Glide Cursor Dragging & Swipe Delete'),
                  _buildCheck('Personal Dictionary, Smart Suggestions & Autocorrect'),
                  _buildCheck('Pinned Clipboard History Manager'),
                  _buildCheck('Rich Categorized Emoji Picker with Search'),
                  _buildCheck('100% Local-First & Zero Telemetry Privacy Policy'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCheck(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 16, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.3))),
        ],
      ),
    );
  }
}
