// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'login_register_screen.dart';
import 'camera_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Price Comparison App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Price Comparison App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginRegisterPage()),
                );
              },
              child: Text('Login / Register'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                );
              },
              child: Text('Scan Product'),
            ),
          ],
        ),
      ),
    );
  }
}
