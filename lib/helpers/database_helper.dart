import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
 
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "electrical_store.db");

    return await openDatabase(path, version: 3, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // ---------------- USERS ------------------
    await db.execute("""
    CREATE TABLE users(
      id TEXT PRIMARY KEY,
      name TEXT,
      email TEXT UNIQUE,
      password TEXT
    )
    """);

    // ---------------- PRODUCTS ------------------
    await db.execute("""
    CREATE TABLE products(
      id TEXT PRIMARY KEY,
      title TEXT,
      subTitle TEXT,
      description TEXT,
      price INTEGER,
      image TEXT,
      category TEXT,
      syncStatus INTEGER   -- 0 synced / 1 pending
    )
    """);

    // ---------------- LIKES ------------------
    await db.execute("""
    CREATE TABLE likes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT,
      productId TEXT
    )
    """);

     await db.execute("CREATE INDEX idx_user_email ON users(email);");
    await db.execute("CREATE INDEX idx_likes_user ON likes(userId);");
    await db.execute("CREATE INDEX idx_likes_product ON likes(productId);");

  }


}
