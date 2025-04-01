// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_register_screen.dart';
import 'camera_screen.dart';
import 'product_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductInfoScreen(
                    imageFile: File(image.path),
                    isFromGallery: true,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf seçilirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    double width = double.infinity,
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
          width: width,
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Image.asset(
            'assets/images/logo.png',
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginRegisterPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Hoş geldin kartı
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ürün Taramasına Başlayın',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ürünün fotoğrafını çekerek fiyat karşılaştırması ve içerik bilgilerini görüntüleyin',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Kamera butonu
              _buildAnimatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
                icon: Icons.camera_alt,
                label: 'Fotoğraf Çek',
                backgroundColor: const Color(0xFF6750A4),
                foregroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              // Galeri butonu
              _buildAnimatedButton(
                onPressed: () => _pickImage(context),
                icon: Icons.photo_library,
                label: 'Galeriden Seç',
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFF6750A4),
              ),
              const Spacer(),
              // Alt bilgi kartı
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hesap oluşturarak tarama geçmişinizi kaydedebilirsiniz',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
