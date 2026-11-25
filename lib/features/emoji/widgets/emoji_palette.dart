import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../data/preferences_helper.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../keyboard/engine/keyboard_engine.dart';

class EmojiPalette extends StatefulWidget {
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const EmojiPalette({
    super.key,
    required this.theme,
    required this.engine,
  });

  @override
  State<EmojiPalette> createState() => _EmojiPaletteState();
}

class _EmojiPaletteState extends State<EmojiPalette> {
  final PreferencesHelper _prefs = PreferencesHelper();
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Recent',
      'icon': CupertinoIcons.clock,
      'emojis': <String>[],
    },
    {
      'name': 'Smileys',
      'icon': CupertinoIcons.smiley,
      'emojis': [
        '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃',
        '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙',
        '😋', '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫', '🤔',
        '🤐', '🤨', '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥',
        '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮',
        '🤧', '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '😎', '🤓',
      ],
    },
    {
      'name': 'Gestures',
      'icon': CupertinoIcons.hand_thumbsup,
      'emojis': [
        '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤏', '✌️', '🤞', '🤟',
        '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍', '👎',
        '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝', '🙏',
        '✍️', '💅', '🤳', '💪', '🦾', '🦿', '🦵', '🦶', '👂', '🦻',
      ],
    },
    {
      'name': 'Hearts',
      'icon': CupertinoIcons.heart,
      'emojis': [
        '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
        '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️',
      ],
    },
    {
      'name': 'Animals',
      'icon': CupertinoIcons.paw,
      'emojis': [
        '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
        '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🐤', '🦆',
        '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋',
      ],
    },
    {
      'name': 'Food',
      'icon': CupertinoIcons.cart,
      'emojis': [
        '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐',
        '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🥑', '🍔',
        '🍟', '🍕', '🌭', '🥪', '🌮', '🌯', '🍜', '🍲', '🍣', '🍦',
      ],
    },
    {
      'name': 'Travel',
      'icon': CupertinoIcons.airplane,
      'emojis': [
        '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐',
        '🚚', '🚛', '🚜', '🛵', '🏍️', '🚲', '🛴', '✈️', '🚀', '🛸',
      ],
    },
    {
      'name': 'Activities',
      'icon': CupertinoIcons.sportscourt,
      'emojis': [
        '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🥏', '🎱',
        '🪀', '🏓', '🏸', '🏒', '🏑', '🥍', '🏏', '🎯', '🪁', '🎮',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    // Resolve emojis for current view
    List<String> displayEmojis;
    if (_searchQuery.isNotEmpty) {
      displayEmojis = _categories
          .expand((c) => (c['emojis'] as List<String>))
          .toSet()
          .toList();
    } else if (_selectedCategoryIndex == 0) {
      displayEmojis = _prefs.recentEmojis;
    } else {
      displayEmojis = _categories[_selectedCategoryIndex]['emojis'] as List<String>;
    }

    return Container(
      color: theme.backgroundColor,
      child: Column(
        children: [
          // Top search & control bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.keyColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.textColor.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.search, size: 14, color: theme.secondaryTextColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: theme.textColor, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search emoji...',
                              hintStyle: TextStyle(color: theme.secondaryTextColor.withOpacity(0.6), fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              setState(() => _searchQuery = val.trim());
                            },
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(CupertinoIcons.clear_circled_solid, size: 14, color: theme.secondaryTextColor),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Backspace button in emoji bar
                InkWell(
                  onTap: () => ImePlatformBridge().deleteBackward(),
                  child: Container(
                    width: 36,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.keyColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(CupertinoIcons.delete_left, size: 18, color: theme.textColor),
                  ),
                ),
                const SizedBox(width: 4),
                // Return to keyboard button
                InkWell(
                  onTap: () => widget.engine.closePanel(),
                  child: Container(
                    width: 44,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.actionKeyColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('ABC', style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),

          // Emoji Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: displayEmojis.length,
              itemBuilder: (context, index) {
                final emoji = displayEmojis[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    await ImePlatformBridge().commitText(emoji);
                    await _prefs.addRecentEmoji(emoji);
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom category tab selector
          Container(
            height: 36,
            color: theme.suggestionBarColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_categories.length, (index) {
                final cat = _categories[index];
                final isSelected = (_selectedCategoryIndex == index && _searchQuery.isEmpty);

                return InkWell(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? theme.accentColor : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 18,
                      color: isSelected ? theme.accentColor : theme.secondaryTextColor,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
