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
      final product = await collection.findOne(
        where.eq('_id', ObjectId.parse(productId)),
      );
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

  // Kullanıcı kayıt işlemi
  Future<bool> registerUser(String email, String password) async {
    try {
      final users = _db.collection('users');
      final existingUser = await users.findOne({'email': email});
      if (existingUser != null) {
        print('Bu email zaten kayıtlı.');
        return false; // Email zaten kayıtlı
      }
      await users.insertOne({'email': email, 'password': password});
      print('Kullanıcı başarıyla kaydedildi.');
      return true; // Kayıt başarılı
    } catch (e) {
      print('Kayıt sırasında hata oluştu: $e');
      return false; // Kayıt başarısız
    }
  }

  // Kullanıcı giriş işlemi
  Future<bool> loginUser(String email, String password) async {
    try {
      final users = _db.collection('users');
      final user = await users.findOne({'email': email, 'password': password});
      if (user != null) {
        print('Giriş başarılı.');
        return true; // Giriş başarılı
      } else {
        print('Hatalı email veya şifre.');
        return false; // Giriş başarısız
      }
    } catch (e) {
      print('Giriş sırasında hata oluştu: $e');
      return false; // Giriş başarısız
    }
  }

  Future<void> close() async {
    await _db.close();
    print('MongoDB bağlantısı kapatıldı.');
  }
}
