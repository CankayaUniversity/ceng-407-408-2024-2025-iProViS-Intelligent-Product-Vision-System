import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'camera_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted)
      return; // Check if the widget is still mounted before calling setState
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF111111)
                : Colors.white,
        elevation: 0,
        title: Text(
          'iProViS',
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          DropdownButton<Locale>(
            underline: const SizedBox(),
            icon: Icon(
              Icons.language,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            onChanged: (Locale? locale) {
              if (locale != null) {
                context.setLocale(locale);
              }
            },
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text("EN")),
              DropdownMenuItem(value: Locale('tr'), child: Text("TR")),
              DropdownMenuItem(value: Locale('es'), child: Text("ES")),
              DropdownMenuItem(value: Locale('de'), child: Text("DE")),
              DropdownMenuItem(value: Locale('fr'), child: Text("FR")),
            ],
          ),
          if (_isLoggedIn)
            IconButton(
              icon: Icon(
                Icons.person_outline,
                size: 28,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final email =
                    prefs.getString('email') ?? 'kullanici@example.com';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(email: email),
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Center(
            // Ensures the content is vertically and horizontally centered
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Glassmorphism card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(
                        (255 * 0.35).toInt(),
                      ), // Updated opacity
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            (255 * 0.12).toInt(),
                          ), // Updated opacity
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withAlpha(
                          (255 * 0.5).toInt(),
                        ), // Updated opacity
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Text(
                            'start_scanning'.tr(),
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(
                                    (255 * 0.25).toInt(),
                                  ),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'description'.tr(),
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(
                                    (255 * 0.18).toInt(),
                                  ),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Camera button
                  Center(
                    child: GestureDetector(
                      onTapDown: (_) {
                        _controller.forward();
                        HapticFeedback.lightImpact();
                      },
                      onTapUp: (_) {
                        _controller.reverse();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraPage()),
                        );
                      },
                      onTapCancel: () => _controller.reverse(),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 79, 176, 255),
                                Color(0xFF1565C0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(
                                  255,
                                  4,
                                  75,
                                  156,
                                ).withAlpha(
                                  (255 * 0.4).toInt(),
                                ), // Updated opacity
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 44,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(
                                    (255 * 0.25).toInt(),
                                  ),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_isLoggedIn)
                    Column(
                      children: [
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.login, color: Colors.white),
                            label: Text('login'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shadowColor: Colors.black.withAlpha(
                                (255 * 0.25).toInt(),
                              ), // Updated opacity
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.white.withAlpha(
                                    (255 * 0.7).toInt(),
                                  ),
                                  width: 1.2,
                                ), // Updated opacity
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.person_add_alt_1,
                              color: Colors.white,
                            ),
                            label: Text('register'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shadowColor: Colors.black.withAlpha(
                                (255 * 0.25).toInt(),
                              ), // Updated opacity
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.white.withAlpha(
                                    (255 * 0.7).toInt(),
                                  ),
                                  width: 1.2,
                                ), // Updated opacity
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
