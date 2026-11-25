import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../themes/theme_manager.dart';

class ThemeEditorScreen extends StatefulWidget {
  const ThemeEditorScreen({super.key});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'My Custom Theme');

  Color _bgColor = const Color(0xFF1E1E2E);
  Color _keyColor = const Color(0xFF2A2A3E);
  Color _textColor = const Color(0xFFCDD6F4);
  Color _accentColor = const Color(0xFFCBA6F7);
  double _borderRadius = 8.0;
  double _borderWidth = 0.0;
  double _marginH = 3.0;
  double _fontSize = 20.0;

  static const List<Color> _presetColors = [
    Color(0xFF13151B), Color(0xFF0B132B), Color(0xFF000000), Color(0xFF0A192F),
    Color(0xFF1E1E2E), Color(0xFF181825), Color(0xFF2E3440), Color(0xFF3B4252),
    Color(0xFFECEFF3), Color(0xFFFAFAFA), Color(0xFFFFFFFF), Color(0xFFE2E8F0),
    Color(0xFF00E5FF), Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFFEF4444), Color(0xFF64FFDA),
  ];

  NoxKeyboardTheme _buildPreviewTheme() {
    return NoxKeyboardTheme(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isEmpty ? 'Custom Theme' : _nameController.text.trim(),
      isDark: _bgColor.computeLuminance() < 0.5,
      backgroundColor: _bgColor,
      keyColor: _keyColor,
      keyPressedColor: _keyColor.withOpacity(0.8),
      actionKeyColor: _bgColor.withOpacity(0.9),
      actionKeyPressedColor: _keyColor,
      textColor: _textColor,
      secondaryTextColor: _textColor.withOpacity(0.6),
      accentColor: _accentColor,
      suggestionBarColor: _bgColor,
      toolbarColor: _bgColor,
      keyBorderRadius: _borderRadius,
      keyBorderWidth: _borderWidth,
      keyBorderColor: _accentColor.withOpacity(0.5),
      keyMarginH: _marginH,
      keyMarginV: 4.5,
      fontSize: _fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreviewTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Theme Editor', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            icon: const Icon(CupertinoIcons.checkmark_alt),
            label: const Text('Save & Apply', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              await ThemeManager().saveCustomTheme(preview);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom theme saved and applied!')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Preview Header Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: preview.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Preview',
                      style: TextStyle(color: preview.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      preview.name,
                      style: TextStyle(color: preview.textColor, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Miniature keyboard row previews
                Row(
                  children: ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']
                      .map((char) => _buildLiveKey(preview, char))
                      .toList(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']
                      .map((char) => _buildLiveKey(preview, char))
                      .toList(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildSpecialLiveKey(preview, '⇧', 14),
                    ...['Z', 'X', 'C', 'V', 'B', 'N', 'M'].map((char) => _buildLiveKey(preview, char)),
                    _buildSpecialLiveKey(preview, '⌫', 14),
                  ],
                ),
              ],
            ),
          ),

          // Customization Controls
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                // Theme Name field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Theme Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 16),

                // Color Selectors
                _buildColorSection('Keyboard Background', _bgColor, (c) => setState(() => _bgColor = c)),
                _buildColorSection('Key Background', _keyColor, (c) => setState(() => _keyColor = c)),
                _buildColorSection('Text Color', _textColor, (c) => setState(() => _textColor = c)),
                _buildColorSection('Accent / Highlights', _accentColor, (c) => setState(() => _accentColor = c)),

                const Divider(height: 32),

                // Sliders
                _buildSlider(
                  label: 'Key Corner Radius',
                  value: _borderRadius,
                  min: 0.0,
                  max: 18.0,
                  unit: 'dp',
                  onChanged: (v) => setState(() => _borderRadius = v),
                ),

                _buildSlider(
                  label: 'Key Border Width',
                  value: _borderWidth,
                  min: 0.0,
                  max: 3.0,
                  unit: 'dp',
                  onChanged: (v) => setState(() => _borderWidth = v),
                ),

                _buildSlider(
                  label: 'Key Horizontal Spacing',
                  value: _marginH,
                  min: 1.0,
                  max: 6.0,
                  unit: 'dp',
                  onChanged: (v) => setState(() => _marginH = v),
                ),

                _buildSlider(
                  label: 'Font Size',
                  value: _fontSize,
                  min: 14.0,
                  max: 26.0,
                  unit: 'sp',
                  onChanged: (v) => setState(() => _fontSize = v),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveKey(NoxKeyboardTheme t, String char) {
    return Expanded(
      flex: 10,
      child: Container(
        height: 28,
        margin: EdgeInsets.symmetric(horizontal: t.keyMarginH / 2),
        decoration: BoxDecoration(
          color: t.keyColor,
          borderRadius: BorderRadius.circular(t.keyBorderRadius),
          border: t.keyBorderWidth > 0 ? Border.all(color: t.keyBorderColor, width: t.keyBorderWidth) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          char,
          style: TextStyle(color: t.textColor, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSpecialLiveKey(NoxKeyboardTheme t, String char, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 28,
        margin: EdgeInsets.symmetric(horizontal: t.keyMarginH / 2),
        decoration: BoxDecoration(
          color: t.actionKeyColor,
          borderRadius: BorderRadius.circular(t.keyBorderRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          char,
          style: TextStyle(color: t.textColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildColorSection(String title, Color selected, ValueChanged<Color> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _presetColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final color = _presetColors[index];
              final isPicked = color.value == selected.value;

              return InkWell(
                onTap: () => onSelect(color),
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPicked ? Colors.cyanAccent : Colors.grey.withOpacity(0.4),
                      width: isPicked ? 2.5 : 1,
                    ),
                  ),
                  child: isPicked ? const Icon(Icons.check, size: 18, color: Colors.cyanAccent) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
