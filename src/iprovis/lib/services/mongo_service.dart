import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  final String _connectionString = 
    'mongodb://10.0.2.2:27017/iprovis';
  Db? _db;
  bool _isConnecting = false;

  Future<void> connect() async {
    if (_db != null && _db!.state == State.OPEN) {
      print('Already connected');
      return;
    }

    if (_isConnecting) {
      print('Connection in progress');
      return;
    }

    _isConnecting = true;
    try {
      _db = await Db.create(_connectionString);
      await _db!.open();
      print('MongoDB connection successful');
    } catch (e) {
      print('MongoDB connection error: $e');
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<Db> _getDb() async {
    if (_db != null && _db!.state == State.OPEN) {
      return _db!;
    }

    if (_isConnecting) {
      // Wait until the existing connection attempt completes
      while (_isConnecting) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      if (_db != null && _db!.state == State.OPEN) {
        return _db!;
      }
    }

    _isConnecting = true;
    try {
      _db = Db(_connectionString);
      await _db!.open();
      print('MongoDB bağlantısı başarılı.');
      return _db!;
    } catch (e) {
      print('MongoDB bağlantı hatası: $e');
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  Future<Map<String, dynamic>?> getProductInfo(String productId) async {
    try {
      final db = await _getDb();
      final collection = db.collection('products');
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
      final db = await _getDb();
      final collection = db.collection('products');
      final product = await collection.findOne(where.eq('label', keyword));
      return product;
    } catch (e) {
      print('Ürün bilgisi alınırken hata: $e');
      return null;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final db = await _getDb();
      final collection = db.collection('users');
      final user = await collection.findOne({
        'email': email,
        'password': password
      });
      return user != null;
    } catch (e) {
      print('Giriş sırasında hata oluştu: $e');
      return false;
    }
  }

  Future<bool> registerUser(String email, String password) async {
    if (_db == null || _db!.state != State.OPEN) {
      await connect();
    }

    try {
      final users = _db!.collection('users');
      
      // Check if user already exists
      final existingUser = await users.findOne({'email': email});
      if (existingUser != null) {
        print('Email already registered');
        return false;
      }

      // Insert new user
      await users.insertOne({
        'email': email,
        'password': password,
        'createdAt': DateTime.now(),
      });
      
      print('User registered successfully');
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.state == State.OPEN) {
      await _db!.close();
    }
  }
}
