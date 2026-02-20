import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';

import 'l10n/app_localizations.dart';
import 'providers/connection_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/settings_screen.dart';
import 'services/widget_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize home widget callback
  HomeWidget.registerInteractivityCallback(interactiveCallback);
  
  runApp(const SnapBeamApp());
}

@pragma('vm:entry-point')
void interactiveCallback(Uri? uri) {
  // Handle widget tap
  if (uri != null) {
    // Navigate to specific screen based on uri
    print('Widget tapped with URI: $uri');
  }
}

class SnapBeamApp extends StatelessWidget {
  const SnapBeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SnapBeam',
            debugShowCheckedModeBanner: false,
            
            // Localization
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
              Locale('es'),
            ],
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Routes
            home: const WelcomeScreen(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/camera': (context) => const CameraScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
