import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iprovis/screens/product_info_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
  }

  Future<List<Map<String, String>>> _loadSavedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('savedProducts_${_email ?? ""}') ?? [];
    return rawList
        .map((e) => Map<String, String>.from(json.decode(e)))
        .toList();
  }

  Future<void> _removeSavedProduct(Map<String, String> product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved =
        prefs.getStringList('savedProducts_${_email ?? ""}') ?? [];
    saved.removeWhere((item) => item == json.encode(product));
    await prefs.setStringList('savedProducts_${_email ?? ""}', saved);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'user_info'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'email'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _email ?? 'no_email'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'navigation'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('home'.tr()),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr()),
              onTap:
                  () =>
                      Navigator.pushReplacementNamed(context, '/camera_screen'),
            ),
            const SizedBox(height: 20),
            Text(
              'theme'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SwitchListTile(
              title: Text("dark_mode".tr()),
              secondary: const Icon(Icons.brightness_6),
              value: isDark,
              onChanged: (val) {
                if (val) {
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: Text('logout'.tr()),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kaydedilen Ürünler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, String>>>(
              future: _loadSavedProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Kaydedilen ürün yok.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      snapshot.data!.map((product) {
                        return Card(
                          child: ListTile(
                            title: Text(product['keyword'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeSavedProduct(product),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProductInfoScreen(
                                        keyword: product['keyword'] ?? '',
                                        imagePath: product['imagePath'] ?? '',
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
