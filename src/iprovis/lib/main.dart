// lib/main.dart
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/unknown_route_page.dart';
import 'themes/app_theme.dart';
import 'package:iprovis/screens/camera_screen.dart';
import 'screens/splash_screen.dart'; // Import SplashScreen

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: Text('Profile Screen Content')),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // Ensure EasyLocalization is initialized
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('es'),
        Locale('de'),
        Locale('fr'),
      ],
      path:
          'assets/translations', // Path to translation files, make sure it matches the one in pubspec.yaml
      fallbackLocale: const Locale('en'),
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: savedThemeMode ?? AdaptiveThemeMode.dark,
      builder:
          (theme, darkTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'iProViS',
            theme: theme,
            darkTheme: darkTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            initialRoute: '/', // Set initial route to SplashScreen
            routes: {
              '/': (context) => SplashScreen(), // Define SplashScreen route
              '/home': (context) => HomeScreen(), // Örnek olarak HomeScreen
              '/profile': (context) => ProfileScreen(), // Profil sayfası
              '/camera_screen': (context) => CameraPage(), // Camera sayfası
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/home') {
                return MaterialPageRoute(builder: (context) => HomeScreen());
              }
              return null;
            },
            onUnknownRoute:
                (settings) =>
                    MaterialPageRoute(builder: (context) => UnknownRoutePage()),
          ),
    );
  }
}
