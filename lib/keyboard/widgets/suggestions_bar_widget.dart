import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../engine/keyboard_engine.dart';
import '../suggestions/suggestion_engine.dart';

class SuggestionsBarWidget extends StatelessWidget {
  final KeyboardEngine engine;
  final NoxKeyboardTheme theme;

  const SuggestionsBarWidget({
    super.key,
    required this.engine,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final candidates = engine.candidates;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: theme.suggestionBarColor,
        border: Border(
          bottom: BorderSide(
            color: theme.textColor.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: candidates.isEmpty
          ? _buildEmptyState(context)
          : Row(
              children: List.generate(candidates.length, (index) {
                final c = candidates[index];
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => engine.selectSuggestion(c),
                          child: Center(
                            child: Text(
                              c.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.isAutocorrect ? theme.accentColor : theme.textColor,
                                fontSize: c.isAutocorrect ? 16 : 15,
                                fontWeight: c.isAutocorrect ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index < candidates.length - 1)
                        Container(
                          width: 1,
                          height: 18,
                          color: theme.textColor.withOpacity(0.12),
                        ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (engine.isPassword) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 14, color: theme.secondaryTextColor),
            const SizedBox(width: 6),
            Text(
              'Password field (private mode)',
              style: TextStyle(
                color: theme.secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickPunctuation('.'),
        _buildQuickPunctuation(','),
        _buildQuickPunctuation('!'),
        _buildQuickPunctuation('?'),
        _buildQuickPunctuation('-'),
        _buildQuickPunctuation('@'),
      ],
    );
  }

  Widget _buildQuickPunctuation(String p) {
    return InkWell(
      onTap: () {
        engine.onKeyPress(
          engine.activePage.rows.first.keys.first.copyWith(primary: p),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          p,
          style: TextStyle(
            color: theme.secondaryTextColor.withOpacity(0.8),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
