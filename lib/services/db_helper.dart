import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class DBHelper {
  static Database? _database;

  // Retrieve database singleton instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize database and create schemas
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'market.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            price REAL,
            description TEXT
          )
        ''');
      },
    );
  }

  // [Create] Insert a new second-hand item listing
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  // [Retrieve] Fetch all item listings sorted by newest ID
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'id DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // [Update] Modify existing product properties
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // [Delete] Remove a product listing permanently from the market table
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
