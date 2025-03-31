import 'package:flutter/material.dart';
import '../models/product.dart';
import 'dart:io';

class ProductInfoScreen extends StatelessWidget {
  final File imageFile;
  final bool isFromGallery;
  final Product? product; // Optional product for testing

  const ProductInfoScreen({
    super.key,
    required this.imageFile,
    this.isFromGallery = false,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Burada gerçek ürün bilgilerini API'den alacağız
    // Şimdilik test verisi kullanıyoruz
    final Product testProduct = product ?? Product(
      name: 'Test Ürün',
      marketPrices: {
        'Market A': 29.99,
        'Market B': 32.99,
        'Market C': 28.99,
      },
      nutritionInfo: {
        'Kalori': '100 kcal',
        'Protein': '5g',
        'Karbonhidrat': '20g',
        'Yağ': '2g',
      },
      ingredients: [
        'Su',
        'Şeker',
        'Tuz',
        'Koruyucu',
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Detayları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Favorilere ekleme işlevi
            },
          ),
        ],
      ),
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
                    testProduct.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile,
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
                  ...testProduct.marketPrices.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      trailing: Text(
                        '${entry.value.toStringAsFixed(2)} ₺',
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

            // Besin Değerleri
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Besin Değerleri',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    leading: const Icon(Icons.restaurant_menu),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: testProduct.nutritionInfo.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // İçindekiler
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'İçindekiler',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    leading: const Icon(Icons.list_alt),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: testProduct.ingredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 