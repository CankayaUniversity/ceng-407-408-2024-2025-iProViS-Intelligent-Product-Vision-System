import 'package:flutter/material.dart';
import '../services/mongo_service.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  LatLng? _userLocation;
  GoogleMapController? _mapController;
  bool _isLoggedIn = false; // <-- Eklendi

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProductInfo();
    _checkLoginStatus(); // <-- Eklendi
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
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

  Future<List<Marker>> fetchNearbyMarketsFromPlacesAPI(LatLng location) async {
    const String apiKey = "AIzaSyBJS4mhiK-84DcJmS6VILYR50QkExbewx0";

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=1500'
      '&keyword=market'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final List results = data['results'];
      return results.map((place) {
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        final name = place['name'];
        return Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toList();
    } else {
      print('Places API failed: ${data['status']}');
      return [];
    }
  }

  Future<void> _showGoogleMapDialog(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Konum izni gerekli!')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng userLoc = LatLng(position.latitude, position.longitude);

    final userMarker = Marker(
      markerId: const MarkerId("user_location"),
      position: userLoc,
      infoWindow: const InfoWindow(title: "You"),
    );

    final marketMarkers = await fetchNearbyMarketsFromPlacesAPI(userLoc);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: userLoc,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                markers: {userMarker, ...marketMarkers},
                onMapCreated: (controller) => _mapController = controller,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
            ],
          ),
    );
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          _isLoggedIn
                              ? ElevatedButton.icon(
                                onPressed: () => _showGoogleMapDialog(context),
                                icon: const Icon(Icons.map),
                                label: const Text('Haritada Marketleri Göster'),
                              )
                              : ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Lütfen harita özelliğini kullanmak için giriş yapınız.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.lock),
                                label: const Text('Haritada Marketleri Göster'),
                              ),
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
