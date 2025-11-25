import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:electrical_store_mobile_app/helpers/database_helper.dart';
import 'package:electrical_store_mobile_app/logic/firebaseServices/product.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class ProductController {
  final dbHelper = DatabaseHelper.instance;
  final firebase = FirebaseProductService();

  Future<bool> hasInternet() async {
     var localConnection = await Connectivity().checkConnectivity();
    if (localConnection == ConnectivityResult.none) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

 
  final cloudinary = CloudinaryPublic('dohw3bunv', 'products', cache: false);

  Future<String> uploadImageToCloudinary(File image) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path, // مسار الصورة
          resourceType: CloudinaryResourceType.Image,
          folder: 'products',
        ),
      );

      if (response.secureUrl == null) {
        throw Exception("فشل الحصول على رابط الصورة الآمن من Cloudinary");
      }

      return response.secureUrl!;
    } catch (e) {
      throw Exception("فشل رفع الصورة: ${e.toString()}");
    }
  }

  Future<void> createProduct(Product product, File? imageFile) async {
    final db = await dbHelper.database;

    final String id = (product.id == null || product.id!.isEmpty)
        ? "p_${Random().nextInt(999999999)}"
        : product.id!;

    if (imageFile != null) {
      String imageUrl = await uploadImageToCloudinary(imageFile);
      product.image = imageUrl;
    }

    final data = product.toMap()..["id"] = id;

    await firebase.addProduct(data);
    data["syncStatus"] = 0;

    // تخزين البيانات محليا sqllite بعد نجاح رفعها على الإنترنت
    await db.insert(
      "products",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(Product product, File? newImageFile) async {
    final db = await dbHelper.database;

    if (newImageFile != null) {
      try {
        // رفع الصورة الجديدة
        String newImageUrl = await uploadImageToCloudinary(newImageFile);
        // تحديث رابط الصورة في المنتج
        product.image = newImageUrl;
      } catch (e) {
        throw Exception("فشل رفع الصورة الجديدة: ${e.toString()}");
      }
    }

    final data = product.toMap();

    await firebase.updateProduct(data);

    // تحديث قاعدة البيانات المحلية
    await db.update("products", data, where: "id = ?", whereArgs: [product.id]);
  }

  Future<void> deleteProduct(String id) async {
    final db = await dbHelper.database;

    await firebase.deleteProduct(id);
    await db.delete("products", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Product>> readAllProducts({String? userId}) async {
    bool online = await hasInternet();

    if (online) {
      try {
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

   Future<List<Product>> searchProducts(String query, {String? userId}) async {
    final db = await dbHelper.database;

    if (query.isEmpty) {
      // إذا البحث فارغ رح ترجع كل المنتجات
      return readAllProducts();
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
