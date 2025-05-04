// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart'; // Ana sayfa import edildi
import 'screens/unknown_route_page.dart'; // Ensure this file exists and contains the UnknownRoutePage class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iProViS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6750A4),
          secondary: const Color(0xFF03DAC6),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
          error: const Color(0xFFCF6679),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2C2C2C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF6750A4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF6750A4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6750A4),
            side: const BorderSide(color: Color(0xFF6750A4)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/home', // Başlangıç rotası artık /home
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ); // HomeScreen'i kullan
        }
        return null; // Eğer rota bulunamazsa null döndürülür
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => UnknownRoutePage());
      },
      // home: const SplashScreen(), // SplashScreen kaldırıldı
    );
  }
}
