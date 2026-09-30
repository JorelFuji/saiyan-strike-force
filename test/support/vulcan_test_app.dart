import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vulcan_fitness/ui/core/theme/vulcan_theme.dart';

/// [MaterialApp] configured with production [VulcanTheme] light/dark themes.
Widget vulcanMaterialApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    theme: VulcanTheme.light(),
    darkTheme: VulcanTheme.dark(),
    themeMode: themeMode,
    home: child,
  );
}

/// [MaterialApp.router] with the same theme wiring as [VulcanApp].
Widget vulcanMaterialAppRouter({
  required GoRouter routerConfig,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp.router(
    theme: VulcanTheme.light(),
    darkTheme: VulcanTheme.dark(),
    themeMode: themeMode,
    routerConfig: routerConfig,
  );
}
