import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../themes/theme_model.dart';
import '../../../themes/theme_manager.dart';
import '../../../keyboard/widgets/keyboard_view.dart';

class ThemeEditorScreen extends StatefulWidget {
  const ThemeEditorScreen({super.key});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'My Custom Theme');

  Color _bgColor = const Color(0xFF0E131F);
  Color _keyColor = const Color(0xFF1B2336);
  Color _textColor = const Color(0xFFF8FAFC);
  Color _accentColor = const Color(0xFF00E5FF);
  double _borderRadius = 10.0;
  double _borderWidth = 1.0;
  double _marginH = 2.6;
  double _fontSize = 20.5;
  String _keyShape = 'rounded';
  String _animationType = 'none';

  static const List<Color> _presetColors = [
    Color(0xFF090D16), Color(0xFF0E131F), Color(0xFF000000), Color(0xFF0A192F),
    Color(0xFF1B2336), Color(0xFF181825), Color(0xFF2E3440), Color(0xFF3B4252),
    Color(0xFFECEFF3), Color(0xFFFAFAFA), Color(0xFFFFFFFF), Color(0xFFE2E8F0),
    Color(0xFF00E5FF), Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFFEF4444), Color(0xFF64FFDA),
  ];

  static const Map<String, String> _shapeOptions = {
    'rounded': 'Rounded',
    'pill': 'Pill',
    'mechanical_3d': '3D Mech',
    'cyber_sharp': 'Cyber Sharp',
    'glass_frost': 'Glass Frost',
    'neon_outline': 'Neon Wire',
  };

  static const Map<String, String> _animOptions = {
    'none': 'Static',
    'rgb_wave': 'RGB Wave',
    'aurora': 'Aurora',
    'pulse_glow': 'Pulse Glow',
    'shimmer': 'Shimmer',
    'cyber_scan': 'Cyber Scan',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  NoxKeyboardTheme _buildPreviewTheme() {
    return NoxKeyboardTheme(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isEmpty ? 'Custom Theme' : _nameController.text.trim(),
      isDark: _bgColor.computeLuminance() < 0.5,
      backgroundColor: _bgColor,
      keyColor: _keyColor,
      keyPressedColor: _keyColor.withOpacity(0.75),
      actionKeyColor: _bgColor.withOpacity(0.9),
      actionKeyPressedColor: _keyColor,
      textColor: _textColor,
      secondaryTextColor: _textColor.withOpacity(0.65),
      accentColor: _accentColor,
      suggestionBarColor: _bgColor,
      toolbarColor: _bgColor,
      keyBorderRadius: _borderRadius,
      keyBorderWidth: _borderWidth,
      keyBorderColor: _accentColor.withOpacity(0.55),
      keyMarginH: _marginH,
      keyMarginV: 3.8,
      fontSize: _fontSize,
      category: _animationType != 'none' ? 'Animated RGB' : 'Minimal',
      keyShape: _keyShape,
      animationType: _animationType,
      gradientColors: [_accentColor, const Color(0xFF8B5CF6)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreviewTheme();

    return ModernScaffold(
      title: 'Custom Theme Studio',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(CupertinoIcons.checkmark_alt, size: 16),
            label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              await ThemeManager().saveCustomTheme(preview);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom theme applied to keyboard!')),
                );
              }
            },
          ),
        ),
      ],
      body: Column(
        children: [
          // Live Interactive Keyboard Preview (with real RGB/3D/Glass effects)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            child: NoxKeyboardView(isImeMode: false, overrideTheme: preview),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Theme Name',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                const SizedBox(height: 16),
                const ModernSectionHeader(title: 'Key Design Style'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _shapeOptions.entries.map((e) {
                    final active = _keyShape == e.key;
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: active,
                      onSelected: (_) => setState(() => _keyShape = e.key),
                      backgroundColor: Colors.white.withOpacity(0.05),
                      selectedColor: const Color(0xFF00E5FF).withOpacity(0.22),
                      side: BorderSide(color: active ? const Color(0xFF00E5FF) : Colors.white12),
                      labelStyle: TextStyle(color: active ? const Color(0xFF00E5FF) : Colors.white70, fontSize: 12),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const ModernSectionHeader(title: 'RGB & Dynamic Animation', accentColor: Color(0xFFA855F7)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _animOptions.entries.map((e) {
                    final active = _animationType == e.key;
                    return ChoiceChip(
                      label: Text(e.value),
                      selected: active,
                      onSelected: (_) => setState(() => _animationType = e.key),
                      backgroundColor: Colors.white.withOpacity(0.05),
                      selectedColor: const Color(0xFFA855F7).withOpacity(0.24),
                      side: BorderSide(color: active ? const Color(0xFFA855F7) : Colors.white12),
                      labelStyle: TextStyle(color: active ? const Color(0xFFE9D5FF) : Colors.white70, fontSize: 12),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),
                _buildColorSection('Keyboard Background', _bgColor, (c) => setState(() => _bgColor = c)),
                _buildColorSection('Key Surface', _keyColor, (c) => setState(() => _keyColor = c)),
                _buildColorSection('Text Color', _textColor, (c) => setState(() => _textColor = c)),
                _buildColorSection('Accent & Glow', _accentColor, (c) => setState(() => _accentColor = c)),

                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _buildSlider(
                        label: 'Corner Radius',
                        value: _borderRadius,
                        min: 0.0,
                        max: 20.0,
                        unit: 'dp',
                        onChanged: (v) => setState(() => _borderRadius = v),
                      ),
                      _buildSlider(
                        label: 'Border Thickness',
                        value: _borderWidth,
                        min: 0.0,
                        max: 3.0,
                        unit: 'dp',
                        onChanged: (v) => setState(() => _borderWidth = v),
                      ),
                      _buildSlider(
                        label: 'Font Size',
                        value: _fontSize,
                        min: 14.0,
                        max: 26.0,
                        unit: 'sp',
                        onChanged: (v) => setState(() => _fontSize = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, Color selected, ValueChanged<Color> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _presetColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final color = _presetColors[index];
              final isPicked = color.value == selected.value;

              return InkWell(
                onTap: () => onSelect(color),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPicked ? const Color(0xFF00E5FF) : Colors.white24,
                      width: isPicked ? 2.5 : 1,
                    ),
                  ),
                  child: isPicked ? const Icon(Icons.check, size: 17, color: Color(0xFF00E5FF)) : null,
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
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontSize: 12, color: Color(0xFF00E5FF))),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFF00E5FF),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
