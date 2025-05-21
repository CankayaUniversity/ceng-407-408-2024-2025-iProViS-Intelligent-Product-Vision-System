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
  GoogleMapController? _mapController;
  bool _isLoggedIn = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchProductInfo();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('email');
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

    // Extract market information for the list
    final marketList =
        marketMarkers.map((marker) {
          double distance = Geolocator.distanceBetween(
            userLoc.latitude,
            userLoc.longitude,
            marker.position.latitude,
            marker.position.longitude,
          );
          return {
            'name': marker.infoWindow.title ?? '',
            'distance': distance,
            'marker': marker, // Store the marker itself
          };
        }).toList();

    // Sort by distance
    marketList.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    // Added variable to hold the selected market's position
    LatLng? selectedMarketPosition;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: userLoc,
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      markers: {userMarker, ...marketMarkers},
                      onMapCreated: (controller) {
                        _mapController = controller;
                        // Animate to the first market if available
                        if (marketList.isNotEmpty) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(
                              (marketList.first['marker'] as Marker).position,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      itemCount: marketList.length,
                      itemBuilder: (context, index) {
                        final market = marketList[index];
                        final distance =
                            (market['distance'] as num?)?.toDouble() ??
                            0.0 / 1000.0; // in km
                        final formattedDistance =
                            distance < 1
                                ? '${(distance * 1000).toStringAsFixed(0)} m'
                                : '${distance.toStringAsFixed(1)} km';

                        return ListTile(
                          leading: const Icon(Icons.store),
                          title: Text(market['name'].toString()),
                          trailing: Text(formattedDistance),
                          onTap: () {
                            // When a market is tapped, update the camera position
                            selectedMarketPosition =
                                (market['marker'] as Marker).position;
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(selectedMarketPosition!),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
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

  Widget _buildRecyclingInfoTab() {
    if (_productInfo == null || _productInfo!['recyclingInfo'] == null) {
      return const Center(
        child: Text('Geri dönüşüm bilgisi bulunmamaktadır.'),
      ); // "Recycling information not available"
    }

    Map<String, dynamic> recyclingInfo =
        _productInfo!['recyclingInfo'] as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Card(
          elevation: 2,
          child: ListTile(
            title: Text('Material'.tr()), //"Material"
            trailing: Text(recyclingInfo['material'] ?? 'N/A'),
          ),
        ),
        Card(
          elevation: 2,
          child: ListTile(
            title: Text('Recyclability Rate - Plastic'.tr()),
            trailing: Text(
              (recyclingInfo['recyclabilityRate']?['Plastik']?.toString() ??
                      'N/A') +
                  '%',
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: ListTile(
            title: Text('Recyclability Rate - Cardboard'.tr()),
            trailing: Text(
              (recyclingInfo['recyclabilityRate']?['Karton']?.toString() ??
                      'N/A') +
                  '%',
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: ListTile(
            title: Text('Instructions'.tr()),
            subtitle: Text(recyclingInfo['instructions'] ?? 'N/A'),
          ),
        ),
      ],
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed:
                                _isLoggedIn
                                    ? () => _showGoogleMapDialog(context)
                                    : () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Lütfen harita özelliğini kullanmak için giriş yapınız.',
                                          ),
                                        ),
                                      );
                                    },
                            icon: const Icon(Icons.map),
                            tooltip: 'Haritada Marketleri Göster',
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.favorite),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final email = _userEmail ?? '';
                              List<String> saved =
                                  prefs.getStringList('savedProducts_$email') ??
                                  [];
                              Map<String, String> product = {
                                'keyword': widget.keyword,
                                'imagePath': widget.imagePath,
                              };
                              saved.add(jsonEncode(product));
                              await prefs.setStringList(
                                'savedProducts_$email',
                                saved.toSet().toList(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ürün kaydedildi.'),
                                ),
                              );
                            },
                            tooltip: 'Kaydet',
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'prices'.tr()),
                        Tab(text: 'nutrition'.tr()),
                        Tab(text: 'ingredients'.tr()),
                        Tab(text: 'recycling'.tr()), // Added Recycling Tab
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPricesTab(),
                          _buildNutritionInfoTab(),
                          _buildIngredientsTab(),
                          _buildRecyclingInfoTab(), // Added Recycling Tab View
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
