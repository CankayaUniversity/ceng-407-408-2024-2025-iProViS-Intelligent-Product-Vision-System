import 'package:flutter/material.dart';
import '../services/mongo_service.dart';
import 'dart:io';

class ProductInfoScreen extends StatefulWidget {
  final String keyword;
  final String imagePath; // Resim yolu

  const ProductInfoScreen({super.key, required this.keyword, required this.imagePath});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  final MongoService _mongoService = MongoService();
  Map<String, dynamic>? _productInfo;

  @override
  void initState() {
    super.initState();
    _fetchProductInfo();
  }

  Future<void> _fetchProductInfo() async {
    await _mongoService.connect();
    final productData = await _mongoService.getProductByKeyword(widget.keyword);
    setState(() {
      _productInfo = productData;
    });
    await _mongoService.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Bilgisi')),
      body: _productInfo == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ürün resmi
                  Image.file(
                    File(widget.imagePath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ürün Adı: ${_productInfo!['label']}'),
                        const SizedBox(height: 10),
                        Text('Fiyatlar:'),
                        ...(_productInfo!['marketPrices'] as Map<String, dynamic>)
                            .entries
                            .map((entry) => Text('${entry.key}: ${entry.value} TL')),
                        const SizedBox(height: 10),
                        Text('Besin Değerleri:'),
                        ...(_productInfo!['nutritionInfo'] as Map<String, dynamic>)
                            .entries
                            .map((entry) => Text('${entry.key}: ${entry.value}')),
                        const SizedBox(height: 10),
                        Text('İçindekiler:'),
                        ...(_productInfo!['ingredients'] as List<dynamic>)
                            .map((ingredient) => Text('- $ingredient')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}