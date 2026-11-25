import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../themes/theme_manager.dart';
import '../../../keyboard/engine/keyboard_engine.dart';

class ThemeQuickSwitcher extends StatelessWidget {
  final NoxKeyboardTheme currentTheme;
  final KeyboardEngine engine;

  const ThemeQuickSwitcher({
    super.key,
    required this.currentTheme,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final allThemes = themeManager.allThemes;

    return Container(
      color: currentTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Theme Switcher',
                style: TextStyle(
                  color: currentTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(CupertinoIcons.clear_circled_solid, color: currentTheme.secondaryTextColor, size: 20),
                onPressed: () => engine.closePanel(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allThemes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final t = allThemes[index];
                final isSelected = t.id == currentTheme.id;

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    themeManager.setTheme(t.id);
                  },
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: t.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? currentTheme.accentColor : Colors.white24,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mini preview keys
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _miniKey(t, 'Q'),
                            const SizedBox(width: 3),
                            _miniKey(t, 'W'),
                            const SizedBox(width: 3),
                            _miniKey(t, 'E'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _miniSpace(t),
                        const SizedBox(height: 10),
                        Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: t.textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniKey(NoxKeyboardTheme t, String label) {
    return Container(
      width: 20,
      height: 22,
      decoration: BoxDecoration(
        color: t.keyColor,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: t.textColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _miniSpace(NoxKeyboardTheme t) {
    return Container(
      width: 60,
      height: 12,
      decoration: BoxDecoration(
        color: t.keyColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
