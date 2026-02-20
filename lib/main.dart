import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'providers/connection_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/widget_setup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/premium_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SnapBeamApp());
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
            
            // Start with splash screen
            home: const SplashScreen(),
            
            // Routes
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/widget-setup': (context) => WidgetSetupScreen(
                onComplete: () {
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
              ),
              '/welcome': (context) => const WelcomeScreen(),
              '/camera': (context) => const CameraScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/premium': (context) => const PremiumScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Main app screen that handles navigation between splash, widget setup, and main app
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  bool _isLoading = true;
  bool _showWidgetSetup = false;
  bool _widgetSetupComplete = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWidgetSetup = prefs.getBool('widget_setup_seen') ?? false;
    
    setState(() {
      _showWidgetSetup = !hasSeenWidgetSetup;
      _isLoading = false;
    });
  }

  Future<void> _completeWidgetSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widget_setup_seen', true);
    
    setState(() {
      _widgetSetupComplete = true;
      _showWidgetSetup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (_showWidgetSetup && !_widgetSetupComplete) {
      return WidgetSetupScreen(
        onComplete: _completeWidgetSetup,
      );
    }

    return const WelcomeScreen();
  }
}
