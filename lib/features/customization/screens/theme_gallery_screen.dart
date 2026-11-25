import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_model.dart';
import '../../../themes/theme_manager.dart';

class ThemeGalleryScreen extends StatefulWidget {
  const ThemeGalleryScreen({super.key});

  @override
  State<ThemeGalleryScreen> createState() => _ThemeGalleryScreenState();
}

class _ThemeGalleryScreenState extends State<ThemeGalleryScreen> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allThemes = _themeManager.allThemes;
    final currentId = _themeManager.currentTheme.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add_circled),
            tooltip: 'Create Custom Theme',
            onPressed: () => Navigator.of(context).pushNamed('/theme-editor'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Banner
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            child: ListTile(
              leading: Icon(Icons.palette, color: Theme.of(context).colorScheme.primary, size: 28),
              title: const Text('Custom Theme Builder', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Design your own colors, key radii, fonts & borders'),
              trailing: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/theme-editor'),
                child: const Text('Create'),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Built-in Themes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          // Themes Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: allThemes.length,
            itemBuilder: (context, index) {
              final t = allThemes[index];
              final isSelected = t.id == currentId;

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _themeManager.setTheme(t.id);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: t.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.2),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini preview layout
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: t.toolbarColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Row 1
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: ['Q', 'W', 'E', 'R'].map((char) => _miniKey(t, char)).toList(),
                              ),
                              // Row 2
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: ['A', 'S', 'D', 'F'].map((char) => _miniKey(t, char)).toList(),
                              ),
                              // Spacebar
                              Container(
                                width: 70,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: t.keyColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Name and selection check
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              t.name,
                              style: TextStyle(
                                color: t.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: t.accentColor,
                              size: 18,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _miniKey(NoxKeyboardTheme t, String char) {
    return Container(
      width: 22,
      height: 20,
      decoration: BoxDecoration(
        color: t.keyColor,
        borderRadius: BorderRadius.circular(t.keyBorderRadius / 2),
        border: t.keyBorderWidth > 0 ? Border.all(color: t.keyBorderColor, width: 0.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(color: t.textColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
