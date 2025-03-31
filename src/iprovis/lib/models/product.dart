class Product {
  final String name;
  final String? imageUrl;
  final Map<String, double> marketPrices;
  final Map<String, String> nutritionInfo;
  final List<String> ingredients;

  Product({
    required this.name,
    this.imageUrl,
    required this.marketPrices,
    required this.nutritionInfo,
    required this.ingredients,
  });

  // Örnek veri oluşturmak için factory metod
  factory Product.example() {
    return Product(
      name: 'Ülker Çikolatalı Gofret',
      imageUrl: 'assets/images/product.jpg',
      marketPrices: {
        'A101': 12.90,
        'BİM': 12.50,
        'ŞOK': 12.75,
        'Migros': 13.90,
      },
      nutritionInfo: {
        'Kalori': '240 kcal',
        'Protein': '3.2g',
        'Karbonhidrat': '28g',
        'Yağ': '12g',
        'Şeker': '18g',
      },
      ingredients: [
        'Buğday Unu',
        'Şeker',
        'Bitkisel Yağ',
        'Kakao',
        'Süt Tozu',
        'Peynir Altı Suyu Tozu',
        'Tuz',
        'Aroma verici',
      ],
    );
  }
} 