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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: theme.suggestionBarColor.withOpacity(theme.isDark ? 0.82 : 0.92),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(theme.isDark ? 0.06 : 0.15),
            width: 0.8,
          ),
        ),
      ),
      child: candidates.isEmpty
          ? _buildEmptyState(context)
          : Row(
              children: List.generate(candidates.length, (index) {
                final c = candidates[index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildSuggestionPill(c),
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildSuggestionPill(SuggestionCandidate c) {
    final isAutocorrect = c.isAutocorrect;

    return InkWell(
      onTap: () => engine.selectSuggestion(c),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isAutocorrect
              ? theme.accentColor.withOpacity(0.18)
              : theme.keyColor.withOpacity(theme.isDark ? 0.65 : 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAutocorrect
                ? theme.accentColor.withOpacity(0.65)
                : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.2),
            width: isAutocorrect ? 1.2 : 0.8,
          ),
          boxShadow: isAutocorrect
              ? [
                  BoxShadow(
                    color: theme.accentColor.withOpacity(0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            c.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isAutocorrect ? theme.accentColor : theme.textColor,
              fontSize: isAutocorrect ? 15 : 14.5,
              fontWeight: isAutocorrect ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (engine.isPassword) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(theme.isDark ? 0.05 : 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.16),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 14, color: theme.secondaryTextColor),
              const SizedBox(width: 6),
              Text(
                'Password field (secure mode)',
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPillPunctuation('.'),
        _buildPillPunctuation(','),
        _buildPillPunctuation('!'),
        _buildPillPunctuation('?'),
        _buildPillPunctuation('-'),
        _buildPillPunctuation('@'),
      ],
    );
  }

  Widget _buildPillPunctuation(String p) {
    return InkWell(
      onTap: () {
        engine.onKeyPress(
          engine.activePage.rows.first.keys.first.copyWith(primary: p),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(theme.isDark ? 0.05 : 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(theme.isDark ? 0.07 : 0.18),
            width: 0.8,
          ),
        ),
        child: Text(
          p,
          style: TextStyle(
            color: theme.secondaryTextColor.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
