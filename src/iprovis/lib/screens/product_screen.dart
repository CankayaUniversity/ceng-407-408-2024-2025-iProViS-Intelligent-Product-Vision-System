import 'package:flutter/material.dart';
import 'dart:io'; // For mobile platforms
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection

class ProductPage extends StatelessWidget {
  final String productName;
  final String productImage;
  final List<Map<String, String>> prices;

  ProductPage({
    required this.productName,
    required this.productImage,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Display the image based on the platform
            kIsWeb
                ? Image.network(productImage) // Use Image.network for web
                : Image.file(File(productImage)), // Use Image.file for mobile
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                productName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: prices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(prices[index]['store']!),
                  trailing: Text(prices[index]['price']!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
