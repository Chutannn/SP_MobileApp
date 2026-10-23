import 'package:flutter/material.dart';
import 'core/theme/twilight_palette.dart';
import 'features/shell/presentation/pages/main_shell_screen.dart';

class SariPurnamaApp extends StatelessWidget {
  const SariPurnamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sari Purnama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: TwilightPalette.background,
        colorScheme: const ColorScheme.dark(
          surface: TwilightPalette.surface,
          onSurface: TwilightPalette.onSurface,
          primary: TwilightPalette.primary,
          onPrimary: TwilightPalette.onPrimary,
          secondary: TwilightPalette.accent,
          onSecondary: TwilightPalette.background,
          error: TwilightPalette.destructive,
        ),
        useMaterial3: true,
      ),
      home: const MainShellScreen(),
    );
  }
}

/// Alias kept for backward compatibility in tests.
typedef KartaPoApp = SariPurnamaApp;
