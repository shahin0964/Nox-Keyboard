import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/widgets/modern_ui.dart';
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
  final PreferencesHelper _prefs = PreferencesHelper();

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
    final isReady = _isEnabled && _isDefault;
    final dictCount = _prefs.userDictionary.length + _prefs.learnedWordFreq.length;
    final shortcutsCount = _prefs.customShortcuts.length;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.keyboard, size: 19, color: Colors.black),
            ),
            const SizedBox(width: 11),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: IconButton(
              icon: const Icon(CupertinoIcons.info, size: 19, color: Colors.white70),
              onPressed: () => Navigator.of(context).pushNamed('/about'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Subtle ambient glow
          Positioned(
            top: -110,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withOpacity(0.11),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              await _prefs.reload();
              await _checkStatus();
              _onStateChange();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: [
                // Auto-hidden once Nox Keyboard is enabled & set as default
                if (!isReady) ...[
                  _buildSetupBannerCard(),
                  const SizedBox(height: 14),
                ],

                // Compact sleek quick-test pill
                _buildCompactTestBar(),

                const SizedBox(height: 18),

                const ModernSectionHeader(title: 'Features & Customization'),

                // Modern Glassmorphic Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.28,
                  children: [
                    _buildActionCard(
                      title: 'Languages',
                      subtitle: '${currentLang.nativeName} ${currentLang.flag}',
                      icon: CupertinoIcons.globe,
                      color: const Color(0xFF38BDF8),
                      route: '/languages',
                    ),
                    _buildActionCard(
                      title: 'Themes & RGB',
                      subtitle: '${theme.name} • ${theme.category}',
                      icon: Icons.palette_rounded,
                      color: const Color(0xFFA855F7),
                      route: '/themes',
                    ),
                    _buildActionCard(
                      title: 'Typing & Smart',
                      subtitle: 'Size, Sound, Accuracy',
                      icon: CupertinoIcons.slider_horizontal_3,
                      color: const Color(0xFF10B981),
                      route: '/typing-settings',
                    ),
                    _buildActionCard(
                      title: 'Shortcuts',
                      subtitle: '$shortcutsCount quick keys',
                      icon: CupertinoIcons.bolt_fill,
                      color: const Color(0xFF38BDF8),
                      route: '/shortcuts',
                    ),
                    _buildActionCard(
                      title: 'Custom Dictionary',
                      subtitle: '$dictCount learned & custom',
                      icon: CupertinoIcons.book_fill,
                      color: const Color(0xFFF59E0B),
                      route: '/dictionary-settings',
                    ),
                    _buildActionCard(
                      title: 'Clipboard',
                      subtitle: '${_prefs.pinnedClipboard.length} pinned • images',
                      icon: CupertinoIcons.doc_on_clipboard_fill,
                      color: const Color(0xFF06B6D4),
                      route: '/clipboard',
                    ),
                    _buildActionCard(
                      title: 'Key',
                      subtitle: 'C=Copy, V=Paste, X=Cut...',
                      icon: CupertinoIcons.command,
                      color: const Color(0xFF00E5FF),
                      route: '/key-mode',
                    ),
                    _buildActionCard(
                      title: 'Data',
                      subtitle: '${_prefs.typingHistoryTotalCount} saved • by date',
                      icon: CupertinoIcons.tray_full_fill,
                      color: const Color(0xFF38BDF8),
                      route: '/data-history',
                    ),
                    _buildActionCard(
                      title: 'Privacy & Data',
                      subtitle: '100% Offline & Local',
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      color: const Color(0xFFEC4899),
                      route: '/privacy',
                    ),
                    _buildActionCard(
                      title: 'App Updates',
                      subtitle: 'OTA Check & Auto-Install',
                      icon: CupertinoIcons.arrow_down_circle_fill,
                      color: const Color(0xFF00E5FF),
                      route: '/updates',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Interactive Playground Card
                GlassCard(
                  onTap: () => Navigator.of(context).pushNamed('/preview'),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  borderColor: const Color(0xFF00E5FF).withOpacity(0.24),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(CupertinoIcons.play_fill, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Interactive Keyboard Playground',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Test Bangla Avro, RGB themes, gestures & voice',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.58),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_forward, size: 17, color: Colors.white.withOpacity(0.5)),
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

  Widget _buildSetupBannerCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      fillColor: const Color(0xFFF59E0B).withOpacity(0.09),
      borderColor: const Color(0xFFF59E0B).withOpacity(0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Color(0xFFFBBF24), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Finish Setting Up Nox Keyboard',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: _checkStatus,
                child: const Icon(CupertinoIcons.arrow_clockwise, color: Colors.white70, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            !_isEnabled
                ? 'Enable Nox Keyboard in Android Settings to use it everywhere.'
                : 'Select Nox Keyboard as your active default keyboard.',
            style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFBBF24),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(!_isEnabled ? CupertinoIcons.gear : CupertinoIcons.checkmark, size: 16),
              label: Text(!_isEnabled ? 'Enable in Settings' : 'Set as Default Keyboard'),
              onPressed: () async {
                if (!_isEnabled) {
                  await _bridge.openInputMethodSettings();
                } else {
                  await _bridge.showInputMethodPicker();
                }
                Future.delayed(const Duration(seconds: 1), _checkStatus);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTestBar() {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextField(
        controller: _quickTestController,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Quick test typing here...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 13.5),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          prefixIcon: Icon(CupertinoIcons.sparkles, size: 18, color: const Color(0xFF00E5FF).withOpacity(0.85)),
          suffixIcon: IconButton(
            icon: Icon(CupertinoIcons.clear_circled_solid, size: 17, color: Colors.white.withOpacity(0.4)),
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
    return GlassCard(
      borderRadius: 20,
      onTap: () {
        Navigator.of(context).pushNamed(route).then((_) async {
          await _prefs.reload();
          await _themeManager.init();
          await _langManager.init();
          _checkStatus();
          _onStateChange();
        });
      },
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ModernIconBadge(icon: icon, color: color, size: 20),
              Icon(CupertinoIcons.chevron_forward, size: 15, color: Colors.white.withOpacity(0.32)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: Color(0xFFF8FAFC),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white.withOpacity(0.54),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
