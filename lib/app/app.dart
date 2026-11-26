import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/preferences_helper.dart';
import '../services/ime_platform_bridge.dart';
import '../themes/theme_manager.dart';
import '../languages/language_manager.dart';
import 'routes.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../keyboard/widgets/keyboard_view.dart';

class NoxApp extends StatefulWidget {
  final String initialRoute;

  const NoxApp({super.key, this.initialRoute = '/'});

  @override
  State<NoxApp> createState() => _NoxAppState();
}

class _NoxAppState extends State<NoxApp> with WidgetsBindingObserver {
  final PreferencesHelper _prefs = PreferencesHelper();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final ImePlatformBridge _bridge = ImePlatformBridge();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.initialRoute != AppRoutes.ime) {
      _bridge.onNavigateRouteCallback = _handleNavigateRoute;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final extra = await _bridge.getInitialRouteExtra();
        if (extra != null && extra.isNotEmpty) {
          _handleNavigateRoute(extra);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.initialRoute != AppRoutes.ime) {
      _reloadAppPrefs();
    }
  }

  Future<void> _reloadAppPrefs() async {
    await _prefs.reload();
    await ThemeManager().init();
    await LanguageManager().init();
  }

  void _handleNavigateRoute(String route) {
    final nav = _navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If launching in IME mode for system keyboard surface
    if (widget.initialRoute == AppRoutes.ime) {
      return ListenableBuilder(
        listenable: ThemeManager(),
        builder: (context, _) {
          final theme = ThemeManager().currentTheme;
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: theme.isDark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: theme.backgroundColor,
              colorSchemeSeed: theme.accentColor,
            ),
            home: Scaffold(
              backgroundColor: theme.backgroundColor,
              body: const Align(
                alignment: Alignment.bottomCenter,
                child: NoxKeyboardView(isImeMode: true),
              ),
            ),
          );
        },
      );
    }

    // Standard App Launch (Settings, Onboarding, Dashboard)
    // Fixed, consistent Material 3 app theme. Keyboard themes only affect the keyboard.
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        fontFamily: 'Roboto',
      ),
      home: _prefs.onboardingCompleted ? const DashboardScreen() : const OnboardingScreen(),
      routes: AppRoutes.routes,
    );
  }
}
