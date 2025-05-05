import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';

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
              onTap: () => Navigator.pushNamed(context, '/camera'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('settings'.tr()),
              onTap: () => Navigator.pushNamed(context, '/settings'),
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
          ],
        ),
      ),
    );
  }
}
