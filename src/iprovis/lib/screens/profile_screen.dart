import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iprovis/services/mongo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:iprovis/screens/product_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MongoService _mongoService = MongoService();
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      await _mongoService.connect();
      final userInfo = await _mongoService.getUserByEmail(widget.email);
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() {
        _isLoading = false;
      });
    } finally {
      await _mongoService.close();
    }
  }

  Future<List<Map<String, String>>> loadSavedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList =
        prefs.getStringList('savedProducts_${_userInfo?['email'] ?? ""}') ?? [];
    return rawList
        .map((e) => Map<String, String>.from(json.decode(e)))
        .toList();
  }

  Future<void> removeSavedProduct(Map<String, String> product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved =
        prefs.getStringList('savedProducts_${_userInfo?['email'] ?? ""}') ?? [];
    saved.removeWhere((item) => item == json.encode(product));
    await prefs.setStringList(
      'savedProducts_${_userInfo?['email'] ?? ""}',
      saved,
    );
    setState(() {}); // Update the UI after removing the product
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userInfo == null
              ? Center(child: Text('user_info_not_found'.tr()))
              : SingleChildScrollView(
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
                            _buildUserInfoRow(
                              Icons.person,
                              'name'.tr(),
                              _userInfo?['name'] ?? '',
                            ),
                            const SizedBox(height: 10),
                            _buildUserInfoRow(
                              Icons.person_outline,
                              'surname'.tr(),
                              _userInfo?['surname'] ?? '',
                            ),
                            const SizedBox(height: 10),
                            _buildUserInfoRow(
                              Icons.calendar_today,
                              'birth_date'.tr(),
                              _userInfo?['birthDate'] ?? '',
                            ),
                            const SizedBox(height: 10),
                            _buildUserInfoRow(
                              Icons.phone,
                              'phone_number'.tr(),
                              _userInfo?['phoneNumber'] ?? '',
                            ),
                            const SizedBox(height: 10),
                            _buildUserInfoRow(
                              Icons.email,
                              'email'.tr(),
                              _userInfo?['email'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'saved_products'
                          .tr(), // Localized key for "Kaydedilen Ürünler"
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, String>>>(
                      future: loadSavedProducts(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text(
                            'no_saved_products'.tr(),
                          ); // Localized key for "Kaydedilen ürün yok."
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
                                      onPressed:
                                          () => removeSavedProduct(product),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ProductInfoScreen(
                                                keyword:
                                                    product['keyword'] ?? '',
                                                imagePath:
                                                    product['imagePath'] ?? '',
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
                          await prefs.clear(); // Clear all saved preferences
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(
                            context,
                            '/home',
                          ); // Navigate to home screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('logout'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
