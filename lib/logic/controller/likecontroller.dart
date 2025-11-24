import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electrical_store_mobile_app/helpers/database_helper.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/user_session.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';

class LikeController {
  static final likesRef = FirebaseFirestore.instance.collection("likes");

  // ======== CHECK INTERNET ========
  static Future<bool> hasInternet() async {
    return (await Connectivity().checkConnectivity()) != ConnectivityResult.none;
  }

  // ======== READ LIKES (ONLINE or OFFLINE) ========
  static Future<List<String>> _getOnlineLikedIds(String userId) async {
    final doc = await likesRef.doc(userId).get();

    if (!doc.exists) return [];

    final list = (doc.data()?["products"] as List?)?.cast<String>() ?? [];
    return list;
  }

  static Future<List<Product>> getLikedProducts(String userId) async {
    final online = await hasInternet();

    List<String> likedIds = [];

    if (online) {
      likedIds = await _getOnlineLikedIds(userId);
    } else {
      // read from local SQLite
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery("""
        SELECT p.*, 1 AS isLiked
        FROM products p
        INNER JOIN likes l
          ON p.id = l.productId
        WHERE l.userId = ?
      """, [userId]);

      return result.map((e) => Product.fromMap(e)).toList();
    }

    if (likedIds.isEmpty) return [];

    final productsSnap = await FirebaseFirestore.instance
        .collection("products")
        .where("id", whereIn: likedIds)
        .get();

    return productsSnap.docs.map((e) {
      final data = e.data();
      data["isLiked"] = 1;
      return Product.fromMap(data);
    }).toList();
  }

  // ======== TOGGLE LIKE ========
  static Future<void> toggleLike(String userId, Product product) async {
    final hasNet = await hasInternet();
    final db = await DatabaseHelper.instance.database;

    // (1) Always update local SQLite
    final check = await db.query(
      "likes",
      where: "userId = ? AND productId = ?",
      whereArgs: [userId, product.id],
    );

    if (check.isEmpty) {
      await db.insert("likes", {"userId": userId, "productId": product.id});
      product.isLiked = true;
    } else {
      await db.delete(
        "likes",
        where: "userId = ? AND productId = ?",
        whereArgs: [userId, product.id],
      );
      product.isLiked = false;
    }

    // (2) Update Firestore if online
    if (hasNet) {
      final doc = await likesRef.doc(userId).get();

      List products = [];
      if (doc.exists) {
        products = List<String>.from(doc["products"]);
      }

      if (product.isLiked) {
        if (!products.contains(product.id)) products.add(product.id);
      } else {
        products.remove(product.id);
      }

      await likesRef.doc(userId).update({"products": products});
    }
  }

  // ======== SYNC LOCAL → FIRESTORE ========
  static Future<void> syncLikesToFirestore() async {
    final hasNet = await hasInternet();
    if (!hasNet) return;

    final db = await DatabaseHelper.instance.database;

    final local = await db.rawQuery("SELECT productId FROM likes");
    List<String> localLikes = local.map((e) => e["productId"] as String).toList();

    final userId = await UserSession.getUserId();
    if (userId == null) return;

    await likesRef.doc(userId).set({
      "userId": userId,
      "products": localLikes,
    }, SetOptions(merge: true));
  }

  // ======== GET COUNT ========
  static Future<int> getLikesCount(String userId) async {
    final online = await hasInternet();

    if (online) {
      final doc = await likesRef.doc(userId).get();
      return (doc.data()?["products"] as List?)?.length ?? 0;
    }

    // offline
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM likes WHERE userId = ?",
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<bool> isProductLiked(String userId, String productId) async {
  final db = await DatabaseHelper.instance.database;

  final result = await db.query(
    "likes",
    where: "userId = ? AND productId = ?",
    whereArgs: [userId, productId],
    limit: 1,
  );

  return result.isNotEmpty;
}
// ======== GET NUMBER OF LIKES FOR A PRODUCT ========
  static Future<int> getProductLikesCount(String productId) async {
    final db = await DatabaseHelper.instance.database;

    // أولًا: حساب عدد اللايكات محليًا
    final localResult = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM likes WHERE productId = ?",
      [productId],
    );
    int count = Sqflite.firstIntValue(localResult) ?? 0;

    // إذا متصل بالإنترنت، تحديث العدد من Firestore
    if (await hasInternet()) {
      final likesSnapshot = await FirebaseFirestore.instance
          .collection("likes")
          .where("products", arrayContains: productId)
          .get();

      count = likesSnapshot.docs.length;
    }

    return count;
  }

}
