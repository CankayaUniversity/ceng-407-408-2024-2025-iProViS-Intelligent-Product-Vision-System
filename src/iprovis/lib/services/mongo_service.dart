import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  // Yerel MongoDB bağlantı dizesi
  final String _connectionString = 'mongodb://10.0.2.2:27017/iprovis';
  late Db _db;

  Future<void> connect() async {
    try {
      _db = Db(_connectionString);
      await _db.open();
      print('MongoDB bağlantısı başarılı.');
    } catch (e) {
      print('MongoDB bağlantı hatası: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProductInfo(String productId) async {
    try {
      final collection = _db.collection('products');
      final product = await collection.findOne(where.eq('_id', ObjectId.parse(productId)));
      return product;
    } catch (e) {
      print('Ürün bilgisi alınırken hata: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductByKeyword(String keyword) async {
    try {
      final collection = _db.collection('products');
      final product = await collection.findOne(where.eq('label', keyword));
      return product;
    } catch (e) {
      print('Ürün bilgisi alınırken hata: $e');
      return null;
    }
  }

  Future<void> close() async {
    await _db.close();
    print('MongoDB bağlantısı kapatıldı.');
  }
}