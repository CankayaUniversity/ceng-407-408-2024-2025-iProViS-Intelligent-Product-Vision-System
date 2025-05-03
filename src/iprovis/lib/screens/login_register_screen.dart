// lib/screens/login_register_page.dart
import 'package:flutter/material.dart';
import '../services/mongo_service.dart'; // MongoService'i import et
import 'profile_screen.dart'; // Profil sayfası import edildi
import 'home_screen.dart'; // HomeScreen'i import et
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences import edildi

class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final MongoService _mongoService =
      MongoService(); // MongoService örneği oluştur

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mongoService.connect(); // Bağlantıyı başlat
  }

  @override
  void dispose() {
    _mongoService.close(); // Bağlantıyı kapat
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _mongoService.loginUser(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login başarılı!')));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true); // Giriş bilgisini kaydet
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ), // HomeScreen'e yönlendir
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hatalı email veya şifre')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _mongoService.registerUser(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
            ),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true); // Kayıt bilgisini kaydet
          // Kayıt başarılıysa profil sayfasına yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ProfileScreen(email: emailController.text.trim()),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu email zaten kayıtlı.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen email adresinizi girin.';
                  }
                  if (!RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(value)) {
                    return 'Geçerli bir email adresi girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin.';
                  }
                  if (value.length < 6) {
                    return 'Şifreniz en az 6 karakter olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _handleRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
