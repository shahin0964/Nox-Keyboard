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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_rounded, size: 16, color: currentTheme.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    'Keyboard Themes (${allThemes.length})',
                    style: TextStyle(
                      color: currentTheme.textColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => engine.closePanel(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(CupertinoIcons.clear_circled_solid, color: currentTheme.secondaryTextColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allThemes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final t = allThemes[index];
                final isSelected = t.id == currentTheme.id;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await themeManager.setTheme(t.id);
                  },
                  child: Container(
                    width: 112,
                    decoration: BoxDecoration(
                      color: t.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? currentTheme.accentColor : Colors.white24,
                        width: isSelected ? 2.2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.isAnimated ? 'RGB' : t.keyShape.split('_').first.toUpperCase(),
                              style: TextStyle(
                                color: t.accentColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isSelected)
                              Icon(CupertinoIcons.checkmark_circle_fill, color: t.accentColor, size: 13),
                          ],
                        ),
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
                        _miniSpace(t),
                        Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: t.textColor,
                            fontSize: 11,
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
      width: 21,
      height: 21,
      decoration: BoxDecoration(
        color: t.keyColor,
        borderRadius: BorderRadius.circular(t.keyShape == 'pill' ? 10 : 4),
        border: Border.all(color: t.accentColor.withOpacity(0.4), width: 0.7),
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
      width: 62,
      height: 11,
      decoration: BoxDecoration(
        color: t.keyColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: t.accentColor.withOpacity(0.35), width: 0.7),
      ),
    );
  }
}
