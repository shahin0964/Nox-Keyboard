import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../app/widgets/modern_ui.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../themes/theme_model.dart';
import '../../../themes/theme_manager.dart';
import '../../../keyboard/widgets/keyboard_view.dart';

class ThemeGalleryScreen extends StatefulWidget {
  const ThemeGalleryScreen({super.key});

  @override
  State<ThemeGalleryScreen> createState() => _ThemeGalleryScreenState();
}

class _ThemeGalleryScreenState extends State<ThemeGalleryScreen>
    with SingleTickerProviderStateMixin {
  final ThemeManager _themeManager = ThemeManager();
  late AnimationController _animController;
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Animated RGB',
    'Dynamic Glass',
    '3D & Mechanical',
    'Minimal',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _themeManager.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _animController.dispose();
    _themeManager.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _openInteractiveDemo(NoxKeyboardTheme theme) {
    final bridge = ImePlatformBridge();
    final demoController = TextEditingController();
    bridge.setMockMode(true);
    bridge.mockCommitCallback = (text) {
      demoController.text = demoController.text + text;
    };
    bridge.mockDeleteBackwardCallback = () {
      if (demoController.text.isNotEmpty) {
        demoController.text = demoController.text.substring(0, demoController.text.length - 1);
      }
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C111D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${theme.category} • ${theme.keyShape.replaceAll('_', ' ')}',
                                  style: TextStyle(color: theme.accentColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(CupertinoIcons.checkmark_alt, size: 16),
                            label: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              await _themeManager.setTheme(theme.id);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Applied "${theme.name}" to your keyboard!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: demoController,
                              builder: (_, val, __) {
                                return Text(
                                  val.text.isEmpty ? 'Tap keys below to test this theme live...' : val.text,
                                  style: TextStyle(
                                    color: val.text.isEmpty ? Colors.white38 : Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled, size: 18, color: Colors.white54),
                            onPressed: () => demoController.clear(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    NoxKeyboardView(isImeMode: false, overrideTheme: theme),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      bridge.setMockMode(false);
      demoController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allThemes = _themeManager.allThemes;
    final filtered = _selectedCategory == 'All'
        ? allThemes
        : allThemes.where((t) => t.category == _selectedCategory).toList();
    final currentId = _themeManager.currentTheme.id;

    return ModernScaffold(
      title: 'Keyboard Themes',
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.35)),
          ),
          child: IconButton(
            icon: const Icon(CupertinoIcons.plus, color: Color(0xFF00E5FF), size: 20),
            tooltip: 'Create Custom Theme',
            onPressed: () => Navigator.of(context).pushNamed('/theme-editor'),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          // Custom Builder Hero Card
          GlassCard(
            onTap: () => Navigator.of(context).pushNamed('/theme-editor'),
            padding: const EdgeInsets.all(14),
            borderColor: const Color(0xFFA855F7).withOpacity(0.35),
            child: Row(
              children: [
                const ModernIconBadge(icon: Icons.auto_awesome, color: Color(0xFFA855F7), size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Theme Studio',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Design custom colors & styles (applies only to keyboard)',
                        style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.55)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7).withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.5)),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Color(0xFFE9D5FF), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Category Filter Chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final active = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  selectedColor: const Color(0xFF00E5FF).withOpacity(0.22),
                  side: BorderSide(
                    color: active ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.12),
                  ),
                  labelStyle: TextStyle(
                    color: active ? const Color(0xFF00E5FF) : Colors.white70,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Live Animated Theme Cards Grid
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              final animVal = _animController.value;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.86,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  final isSelected = t.id == currentId;
                  return _buildLiveThemeCard(t, isSelected, animVal);
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLiveThemeCard(NoxKeyboardTheme t, bool isSelected, double animVal) {
    Color dynamicGlow = t.accentColor;
    if (t.animationType == 'rgb_wave') {
      dynamicGlow = HSVColor.fromAHSV(1.0, (animVal * 360.0) % 360.0, 0.9, 1.0).toColor();
    } else if (t.animationType == 'cyber_scan') {
      final p = (math.sin(animVal * 2 * math.pi) + 1) * 0.5;
      dynamicGlow = Color.lerp(const Color(0xFFFF2A85), const Color(0xFF00E5FF), p) ?? t.accentColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: t.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00E5FF)
              : (t.isAnimated ? dynamicGlow.withOpacity(0.55) : Colors.white.withOpacity(0.12)),
          width: isSelected ? 2.2 : 1.1,
        ),
        boxShadow: [
          if (t.isAnimated || isSelected)
            BoxShadow(
              color: (isSelected ? const Color(0xFF00E5FF) : dynamicGlow).withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _themeManager.setTheme(t.id),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Style / Animation Badge row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: dynamicGlow.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t.isAnimated ? 'LIVE RGB' : t.keyShape.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: dynamicGlow,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF00E5FF), size: 17),
                  ],
                ),
                const SizedBox(height: 6),

                // Animated Mini-Keyboard Demo
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: t.toolbarColor,
                      borderRadius: BorderRadius.circular(10),
                      gradient: t.animationType == 'aurora' && t.gradientColors.length >= 2
                          ? LinearGradient(
                              begin: Alignment(-1 + animVal * 2, -1),
                              end: Alignment(1 - animVal * 2, 1),
                              colors: [
                                t.toolbarColor,
                                t.gradientColors[0].withOpacity(0.18),
                                t.gradientColors[1].withOpacity(0.15),
                              ],
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['Q', 'W', 'E', 'R']
                              .asMap()
                              .entries
                              .map((e) => _miniKey(t, e.value, e.key, animVal))
                              .toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['A', 'S', 'D', 'F']
                              .asMap()
                              .entries
                              .map((e) => _miniKey(t, e.value, e.key + 2, animVal))
                              .toList(),
                        ),
                        Container(
                          width: 72,
                          height: 11,
                          decoration: BoxDecoration(
                            color: t.keyShape == 'neon_outline' ? t.keyColor.withOpacity(0.35) : t.keyColor,
                            borderRadius: BorderRadius.circular(t.keyShape == 'pill' ? 10 : 4),
                            border: Border.all(
                              color: t.isAnimated ? dynamicGlow.withOpacity(0.65) : Colors.white24,
                              width: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  t.name,
                  style: TextStyle(
                    color: t.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Interactive Demo + Apply row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _openInteractiveDemo(t),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(t.isDark ? 0.08 : 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Try Demo',
                            style: TextStyle(
                              color: t.isDark ? Colors.white : Colors.black87,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () => _themeManager.setTheme(t.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00E5FF)
                                : t.accentColor.withOpacity(0.24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isSelected ? 'Active' : 'Apply',
                            style: TextStyle(
                              color: isSelected ? Colors.black : t.accentColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniKey(NoxKeyboardTheme t, String char, int col, double animVal) {
    Color borderCol = t.keyBorderColor;
    if (t.animationType == 'rgb_wave') {
      borderCol = HSVColor.fromAHSV(1.0, (animVal * 360 + col * 38) % 360, 0.9, 1.0).toColor();
    } else if (t.animationType == 'cyber_scan') {
      final p = (math.sin(animVal * 2 * math.pi - col * 0.6) + 1) * 0.5;
      borderCol = Color.lerp(const Color(0xFFFF2A85), const Color(0xFF00E5FF), p) ?? t.accentColor;
    } else if (t.animationType != 'none') {
      borderCol = t.accentColor.withOpacity(0.65);
    }

    final double radius = t.keyShape == 'pill'
        ? 10.0
        : (t.keyShape == 'cyber_sharp' ? 3.0 : (t.keyShape == 'soft_blob' ? 8.0 : 5.0));

    return Container(
      width: 24,
      height: 20,
      decoration: BoxDecoration(
        color: t.keyShape == 'neon_outline' ? t.keyColor.withOpacity(0.3) : t.keyColor,
        borderRadius: BorderRadius.circular(radius),
        border: t.keyShape == 'mechanical_3d'
            ? Border(
                top: BorderSide(color: Colors.white.withOpacity(0.2), width: 0.7),
                bottom: BorderSide(color: Colors.black.withOpacity(0.55), width: 2.5),
              )
            : Border.all(
                color: borderCol == Colors.transparent ? Colors.white24 : borderCol,
                width: t.isAnimated || t.keyShape == 'neon_outline' ? 1.0 : 0.5,
              ),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(color: t.textColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
