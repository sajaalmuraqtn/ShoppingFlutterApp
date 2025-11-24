import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:electrical_store_mobile_app/helpers/database_helper.dart';
import 'package:electrical_store_mobile_app/logic/firebaseServices/product.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';

class ProductController {
  final dbHelper = DatabaseHelper.instance;
  final firebase = FirebaseProductService();

  // ----------- CHECK INTERNET ------------
  Future<bool> hasInternet() async {
    var c = await Connectivity().checkConnectivity();
    return c != ConnectivityResult.none;
  }

  // ----------- ADD PRODUCT ------------
Future<void> createProduct(Product product) async {
  final db = await dbHelper.database;
  bool online = await hasInternet();

  // 🔥 إصلاح المشكلة: تجنّب استخدام ! عندما يكون null
  final String id = (product.id == null || product.id!.isEmpty)
      ? "p_${Random().nextInt(999999999)}"
      : product.id!;

  final data = product.toMap()..["id"] = id;

  if (online) {
    await firebase.addProduct(data);
    data["syncStatus"] = 0;
  } else {
    data["syncStatus"] = 1;
  }

  await db.insert(
    "products",
    data,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  // ----------- UPDATE PRODUCT ------------
  Future<void> updateProduct(Product product) async {
    final db = await dbHelper.database;
    bool online = await hasInternet();

    final data = product.toMap();

    if (online) {
      await firebase.updateProduct(data);
      data["syncStatus"] = 0;
    } else {
      data["syncStatus"] = 1;
    }

    await db.update("products", data, where: "id = ?", whereArgs: [product.id]);
  }

  // ----------- DELETE PRODUCT ------------
  Future<void> deleteProduct(String id) async {
    final db = await dbHelper.database;
    bool online = await hasInternet();

    if (online) {
      await firebase.deleteProduct(id);
      await db.delete("products", where: "id = ?", whereArgs: [id]);
    } else {
      // نحذفه محلياً فقط
      await db.update(
        "products",
        {"syncStatus": 1},
        where: "id = ?",
        whereArgs: [id],
      );
    }
  }

  Future<List<Product>> readAllProducts({String? userId}) async {
    bool online = await hasInternet();

    if (online) {
      try {
        // Fetch from Firestore
        final products = await firebase.fetchProducts();

        // Save to local SQLite
        final db = await dbHelper.database;
        for (var p in products) {
          await db.insert(
            "products",
            p.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        return products;
      } catch (e) {
        print("Error fetching from Firestore: $e");
        return _getProductsFromLocal(userId);
      }
    } else {
      return _getProductsFromLocal(userId);
    }
  }

  Future<List<Product>> _getProductsFromLocal(String? userId) async {
    final db = await dbHelper.database;
    final id = userId?.isNotEmpty == true ? userId : null;

    final result = await db.rawQuery("""
      SELECT 
        p.*, 
        CASE 
          WHEN l.productId IS NOT NULL THEN 1 
          ELSE 0 
        END AS isLiked
      FROM products p
      LEFT JOIN likes l
        ON l.productId = p.id
        ${id != null ? "AND l.userId = ?" : ""}
    """, id != null ? [id] : []);

    return result.map((e) => Product.fromMap(e)).toList();
  }
// ----------- SEARCH PRODUCTS (local DB) ------------
Future<List<Product>> searchProducts(String query, {String? userId}) async {
  final db = await dbHelper.database;

  if (query.isEmpty) {
    // إذا البحث فارغ، ارجع كل المنتجات
    return readAllProducts( );
  }

  final q = '%${query.toLowerCase()}%';
  final id = userId?.isNotEmpty == true ? userId : null;

  final result = await db.rawQuery("""
    SELECT 
      p.*, 
      CASE 
        WHEN l.productId IS NOT NULL THEN 1 
        ELSE 0 
      END AS isLiked
    FROM products p
    LEFT JOIN likes l
      ON l.productId = p.id
      ${id != null ? "AND l.userId = ?" : ""}
    WHERE LOWER(p.title) LIKE ? 
       OR LOWER(p.subTitle) LIKE ? 
       OR LOWER(p.category) LIKE ?
  """, id != null ? [id, q, q, q] : [q, q, q]);

  return result.map((e) => Product.fromMap(e)).toList();
}


  // ----------- SYNC OFFLINE DATA ------------
  Future<void> syncPendingProducts() async {
    final db = await dbHelper.database;

    bool online = await hasInternet();
    if (!online) return;

    final pending = await db.query("products", where: "syncStatus = 1");

    for (var p in pending) {
      await firebase.addProduct(p);
      p["syncStatus"] = 0;

      await db.update("products", p, where: "id = ?", whereArgs: [p["id"]]);
    }
  }
}
