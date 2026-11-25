import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';

class LongPressAlternatesPopup extends StatelessWidget {
  final List<String> alternates;
  final NoxKeyboardTheme theme;
  final ValueChanged<String> onSelect;

  const LongPressAlternatesPopup({
    super.key,
    required this.alternates,
    required this.theme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: theme.actionKeyColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.accentColor.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: alternates.map((alt) {
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onSelect(alt),
              child: Container(
                constraints: const BoxConstraints(minWidth: 38, minHeight: 44),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  alt,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
