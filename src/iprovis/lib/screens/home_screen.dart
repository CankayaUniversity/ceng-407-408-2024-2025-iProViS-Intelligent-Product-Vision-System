import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'camera_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoggedIn = false;
  String _email = 'E-posta Yok';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadEmail();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? 'E-posta Yok';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 64,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          DropdownButton<Locale>(
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.white),
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
              icon: const Icon(Icons.person_outline, size: 28),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'start_scanning'.tr(),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'description'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildAnimatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
                icon: Icons.camera_alt,
                label: 'take_photo'.tr(),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              if (!_isLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text('login'.tr()),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: Text('register'.tr()),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
