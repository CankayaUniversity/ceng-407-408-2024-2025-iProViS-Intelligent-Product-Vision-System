import 'package:flutter/material.dart';
import 'dart:io'; // For mobile platforms
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection;

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
      appBar: AppBar(title: Text(productName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ürün Adı ve Resmi
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        kIsWeb
                            ? Image.network(
                              productImage,
                              height: 200,
                              fit: BoxFit.contain,
                            )
                            : Image.file(
                              File(productImage),
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                  ),
                ],
              ),
            ),

            // Market Fiyatları
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Market Fiyatları',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    leading: const Icon(Icons.store),
                  ),
                  const Divider(),
                  ...prices.map((price) {
                    return ListTile(
                      title: Text(price['store']!),
                      trailing: Text(
                        price['price']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
