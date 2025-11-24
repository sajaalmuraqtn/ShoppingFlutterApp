import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/controller/likecontroller.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/user_session.dart';
import 'package:electrical_store_mobile_app/screens/userscreens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:electrical_store_mobile_app/widgets/homeWidgets/productCard.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';

class LikedProductsScreen extends StatefulWidget {
  const LikedProductsScreen({super.key});

  @override
  State<LikedProductsScreen> createState() => _LikedProductsScreenState();
}

class _LikedProductsScreenState extends State<LikedProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String? userId;
 
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    userId = await UserSession.getUserId();
    await LikeController.syncLikesToFirestore(); // مزامنة عند فتح الشاشة
    await loadLiked();
  }

  Future<void> loadLiked() async {
    if (userId == null) return;
    products = await LikeController.getLikedProducts(userId!);
    setState(() => isLoading = false);
  }

  Future<void> handleLike(Product p) async {
    if (userId == null) return;

    await LikeController.toggleLike(userId!, p);
    await LikeController.syncLikesToFirestore(); 
    await loadLiked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: kBackgroundColor,

      appBar: AppBar(
        title: const Text("المنتجات المعجب بها", style: TextStyle(color: kBackgroundColor)),
        backgroundColor: kPrimaryColor,
        leading: IconButton(onPressed: (){
           Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ));
        }, icon: Icon(Icons.arrow_back)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : products.isEmpty
              ? Center(child: Text("لا توجد منتجات معجب بها"))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ProductCard(
                       itemIndex: index,
                      product: p,
                       onPressed: () {},
                      onLikeChanged: () => handleLike(p),
                    );
                  },
                ),
    );
  }
}
