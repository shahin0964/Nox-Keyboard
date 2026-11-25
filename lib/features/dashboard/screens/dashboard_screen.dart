import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/preferences_helper.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../languages/language_manager.dart';
import '../../../themes/theme_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImePlatformBridge _bridge = ImePlatformBridge();
  final LanguageManager _langManager = LanguageManager();
  final ThemeManager _themeManager = ThemeManager();

  bool _isEnabled = false;
  bool _isDefault = false;
  final TextEditingController _quickTestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _langManager.addListener(_onStateChange);
    _themeManager.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _langManager.removeListener(_onStateChange);
    _themeManager.removeListener(_onStateChange);
    _quickTestController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _checkStatus() async {
    final enabled = await _bridge.isKeyboardEnabled();
    final isDef = await _bridge.isKeyboardDefault();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isDefault = isDef;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeManager.currentTheme;
    final currentLang = _langManager.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(CupertinoIcons.keyboard, size: 22, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info_circle),
            onPressed: () => Navigator.of(context).pushNamed('/about'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkStatus,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Live Testing Input Card
            _buildTestingCard(),

            const SizedBox(height: 20),

            // Section Header
            const Text(
              'Features & Customization',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Navigation Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildActionCard(
                  title: 'Languages',
                  subtitle: '${currentLang.nativeName} (${currentLang.flag})',
                  icon: CupertinoIcons.globe,
                  color: const Color(0xFF3B82F6),
                  route: '/languages',
                ),
                _buildActionCard(
                  title: 'Themes',
                  subtitle: theme.name,
                  icon: Icons.palette,
                  color: const Color(0xFF8B5CF6),
                  route: '/themes',
                ),
                _buildActionCard(
                  title: 'Typing & Smart',
                  subtitle: 'Autocorrect & Suggest',
                  icon: CupertinoIcons.slider_horizontal_3,
                  color: const Color(0xFF10B981),
                  route: '/typing-settings',
                ),
                _buildActionCard(
                  title: 'Custom Dictionary',
                  subtitle: '${PreferencesHelper().userDictionary.length} words',
                  icon: CupertinoIcons.book_fill,
                  color: const Color(0xFFF59E0B),
                  route: '/dictionary-settings',
                ),
                _buildActionCard(
                  title: 'Clipboard',
                  subtitle: '${PreferencesHelper().pinnedClipboard.length} pinned',
                  icon: CupertinoIcons.doc_on_clipboard_fill,
                  color: const Color(0xFF06B6D4),
                  route: '/clipboard',
                ),
                _buildActionCard(
                  title: 'Privacy & Data',
                  subtitle: '100% Offline & Local',
                  icon: CupertinoIcons.shield_lefthalf_fill,
                  color: const Color(0xFFEC4899),
                  route: '/privacy',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Full Screen Playground Link
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF00E5FF),
                  child: Icon(CupertinoIcons.play_circle_fill, color: Colors.black87),
                ),
                title: const Text('Interactive Keyboard Playground', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Try layouts, Bangla phonetic, emojis & gestures'),
                trailing: const Icon(CupertinoIcons.chevron_forward, size: 18),
                onTap: () => Navigator.of(context).pushNamed('/preview'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isReady = _isEnabled && _isDefault;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isReady
              ? [const Color(0xFF065F46), const Color(0xFF047857)]
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isReady ? const Color(0xFF047857) : Colors.black).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isReady ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.exclamationmark_triangle_fill,
                    color: isReady ? const Color(0xFF6EE7B7) : const Color(0xFFFBBF24),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isReady ? 'Active Default Keyboard' : 'Setup Required',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.arrow_clockwise, color: Colors.white70, size: 20),
                onPressed: _checkStatus,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isReady
                ? 'Nox Keyboard is enabled and set as your system input method. Ready to use in all apps!'
                : (!_isEnabled
                    ? 'Nox Keyboard is not enabled in Android Settings yet.'
                    : 'Nox Keyboard is enabled, but not selected as your default keyboard.'),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (!isReady) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (!_isEnabled)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.gear, size: 16),
                      label: const Text('Enable in Settings'),
                      onPressed: () async {
                        await _bridge.openInputMethodSettings();
                        Future.delayed(const Duration(seconds: 1), _checkStatus);
                      },
                    ),
                  ),
                if (_isEnabled && !_isDefault)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EE7B7),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.checkmark, size: 16),
                      label: const Text('Select as Default'),
                      onPressed: () async {
                        await _bridge.showInputMethodPicker();
                        Future.delayed(const Duration(seconds: 1), _checkStatus);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextField(
        controller: _quickTestController,
        decoration: InputDecoration(
          hintText: 'Tap here to test typing with Nox...',
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 14),
          border: InputBorder.none,
          prefixIcon: const Icon(CupertinoIcons.pencil_circle, size: 22),
          suffixIcon: IconButton(
            icon: const Icon(CupertinoIcons.clear_circled, size: 18),
            onPressed: () => _quickTestController.clear(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
