import 'package:flutter/material.dart';
import '../services/mongo_service.dart';
import 'dart:io';

class ProductInfoScreen extends StatefulWidget {
  final String keyword;
  final String imagePath;

  const ProductInfoScreen({
    Key? key,
    required this.keyword,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen>
    with SingleTickerProviderStateMixin {
  final MongoService _mongoService = MongoService();
  Map<String, dynamic>? _productInfo;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProductInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductInfo() async {
    await _mongoService.connect();
    final productData = await _mongoService.getProductByKeyword(widget.keyword);
    setState(() {
      _productInfo = productData;
    });
    await _mongoService.close();
  }

  Widget _buildPricesTab() {
    return ListView(
      padding: const EdgeInsets.all(8.0), // Liste öğelerine padding eklendi
      children:
          (_productInfo!['marketPrices'] as Map<String, dynamic>).entries
              .map(
                (entry) => Card(
                  // Her fiyat bilgisi için Card widget'ı
                  elevation: 2,
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text('${entry.value} TL'),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildNutritionInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(8.0), // Liste öğelerine padding eklendi
      children:
          (_productInfo!['nutritionInfo'] as Map<String, dynamic>).entries
              .map(
                (entry) => Card(
                  // Her besin bilgisi için Card widget'ı
                  elevation: 2,
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(entry.value.toString()),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView(
      padding: const EdgeInsets.all(8.0), // Liste öğelerine padding eklendi
      children:
          (_productInfo!['ingredients'] as List<dynamic>)
              .map(
                (ingredient) => Card(
                  // Her içerik bilgisi için Card widget'ı
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.arrow_right),
                    title: Text(ingredient),
                  ),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Bilgisi')),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Sayfaya genel padding eklendi
        child:
            _productInfo == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    // Ürün fotoğrafı ve ismi
                    Stack(
                      alignment:
                          Alignment.topCenter, // Ürün ismi üstte ortalanacak
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AspectRatio(
                            aspectRatio: 1.0, // Kare şeklinde olması için
                            child: Image.file(
                              File(widget.imagePath),
                              width: 10, // Resim boyutu daha da küçültüldü
                              height: 10, // Resim boyutu daha da küçültüldü
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            widget.keyword,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // TabBar
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Fiyatlar'),
                        Tab(text: 'Besin Değerleri'),
                        Tab(text: 'İçindekiler'),
                      ],
                    ),
                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPricesTab(),
                          _buildNutritionInfoTab(),
                          _buildIngredientsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
