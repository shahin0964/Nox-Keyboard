import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/preferences_helper.dart';
import '../themes/theme_manager.dart';
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

class _NoxAppState extends State<NoxApp> {
  final ThemeManager _themeManager = ThemeManager();
  final PreferencesHelper _prefs = PreferencesHelper();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themeManager.currentTheme;

    // If launching in IME mode for system keyboard surface
    if (widget.initialRoute == AppRoutes.ime) {
      return MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: currentTheme.isDark ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: currentTheme.backgroundColor,
          colorSchemeSeed: currentTheme.accentColor,
        ),
        home: const Scaffold(
          body: NoxKeyboardView(isImeMode: true),
        ),
      );
    }

    // Standard App Launch (Settings, Onboarding, Dashboard)
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: currentTheme.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
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
