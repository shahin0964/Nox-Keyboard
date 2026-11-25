import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/preferences_helper.dart';

class EmojiSettingsScreen extends StatefulWidget {
  const EmojiSettingsScreen({super.key});

  @override
  State<EmojiSettingsScreen> createState() => _EmojiSettingsScreenState();
}

class _EmojiSettingsScreenState extends State<EmojiSettingsScreen> {
  final PreferencesHelper _prefs = PreferencesHelper();
  List<String> _recents = [];

  @override
  void initState() {
    super.initState();
    _recents = _prefs.recentEmojis;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji & Emoticons', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text('Dedicated Emoji Key in Toolbar'),
            subtitle: const Text('Access the emoji palette directly from the top toolbar'),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Predictive Emojis'),
            subtitle: const Text('Suggest relevant emojis based on typed emotion words'),
            value: true,
            onChanged: (val) {},
          ),

          const Divider(height: 32),

          _buildSectionHeader('Recently Used Emojis'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recents.map((emoji) {
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            icon: const Icon(CupertinoIcons.trash),
            label: const Text('Clear Recent Emojis'),
            onPressed: () async {
              setState(() => _recents.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recent emojis cleared!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}
