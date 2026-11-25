import 'dart:ui';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/routes.dart';
import 'data/preferences_helper.dart';
import 'themes/theme_manager.dart';
import 'languages/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await PreferencesHelper().init();
  await ThemeManager().init();
  await LanguageManager().init();

  // Read initial route passed by Android system or launcher
  final defaultRoute = PlatformDispatcher.instance.defaultRouteName;
  final initialRoute = (defaultRoute == AppRoutes.ime) ? AppRoutes.ime : AppRoutes.root;

  runApp(NoxApp(initialRoute: initialRoute));
}

// Dedicated IME entrypoint if invoked directly by FlutterEngine
@pragma('vm:entry-point')
void keyboardMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesHelper().init();
  await ThemeManager().init();
  await LanguageManager().init();

  runApp(const NoxApp(initialRoute: AppRoutes.ime));
}
