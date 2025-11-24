import 'package:electrical_store_mobile_app/logic/controller/likecontroller.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/user_session.dart';
import 'package:flutter/material.dart';
import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/controller/product_controller.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';
import 'package:electrical_store_mobile_app/screens/auth/loginscreen.dart';
import 'package:electrical_store_mobile_app/screens/user/profilescreen.dart';
import 'package:electrical_store_mobile_app/screens/userscreens/detailsScreen.dart';
import 'package:electrical_store_mobile_app/screens/userscreens/liked_products_screen.dart';
import 'package:electrical_store_mobile_app/widgets/homeWidgets/productCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductController productController = ProductController();

  List<Product> products = [];
  List<Product> filteredProducts = []; // المنتجات بعد البحث
  bool isLoggedIn = false;
  String? userId;
  bool _loading = true;
  int likedCount = 0;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApp();

    // الاستماع لتغييرات البحث
    searchController.addListener(() {
      _searchProducts(searchController.text);
    });
  }

  Future<void> _initializeApp() async {
    await _checkLoginStatus();
    await _loadProducts();
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await UserSession.isLoggedIn();
    userId = await UserSession.getUserId();

    if (isLoggedIn && userId != null) {
      likedCount = await LikeController.getLikesCount(userId!);
    } else {
      likedCount = 0;
    }

    setState(() {
      print('issss loooogin $isLoggedIn');
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);

    try {
      products = await productController.readAllProducts(userId: userId);
      filteredProducts = List.from(products); // نسخ كاملة للفلترة
    } catch (e) {
      debugPrint("Error loading products: $e");
      products = [];
      filteredProducts = [];
    }

    setState(() => _loading = false);
  }

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = await productController.searchProducts(
        query,
        userId: userId,
      );
    }
    setState(() {});
  }

  Future<void> _handleLike(Product p) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول لإضافة إعجاب")),
      );
      return;
    }

    await LikeController.toggleLike(userId!, p);
    likedCount = await LikeController.getLikesCount(userId!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isLoggedIn
              ? "تصفح المنتجات المتنوعة"
              : "مرحباً بكم في متجرنا الإلكتروني",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
          actions: [
          if (!isLoggedIn)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ).then((_) => _initializeApp());
              },
              icon: const Icon(Icons.login, color: Colors.white),
            ),

          if (isLoggedIn) ...[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              icon: const Icon(Icons.person, color: Colors.white),
            ),

            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LikedProductsScreen(),
                  ),
                ).then((_) async {
                  // تحديث العداد عند العودة من صفحة اللايكات
                  if (userId != null) {
                    likedCount = await LikeController.getLikesCount(userId!);
                    setState(() {});
                  }
                });
              },
              icon: Stack(
                children: [
                  const Icon(Icons.favorite, color: Colors.white),
                  if (likedCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          likedCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: kDefaultPadding / 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "ابحث عن منتج...",
                  prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 70),
                    decoration: const BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        )
                      : filteredProducts.isEmpty
                      ? const Center(child: Text("لا توجد منتجات"))
                      : ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final p = filteredProducts[index];
                            return ProductCard(
                              itemIndex: index,
                              product: p,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsScreen(product: p),
                                  ),
                                ).then((_) => _loadProducts());
                              },
                              onLikeChanged: () => _handleLike(p),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
