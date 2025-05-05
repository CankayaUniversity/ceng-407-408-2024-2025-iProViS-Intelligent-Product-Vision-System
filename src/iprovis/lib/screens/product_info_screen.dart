import 'package:flutter/material.dart';
import '../services/mongo_service.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

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
      padding: const EdgeInsets.all(8.0),
      children:
          (_productInfo!['marketPrices'] as Map<String, dynamic>).entries
              .map(
                (entry) => Card(
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
      padding: const EdgeInsets.all(8.0),
      children:
          (_productInfo!['nutritionInfo'] as Map<String, dynamic>).entries
              .map(
                (entry) => Card(
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
      padding: const EdgeInsets.all(8.0),
      children:
          (_productInfo!['ingredients'] as List<dynamic>)
              .map(
                (ingredient) => Card(
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
      appBar: AppBar(title: Text('product_info'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            _productInfo == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.file(
                              File(widget.imagePath),
                              width: 10,
                              height: 10,
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
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'prices'.tr()),
                        Tab(text: 'nutrition'.tr()),
                        Tab(text: 'ingredients'.tr()),
                      ],
                    ),
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
