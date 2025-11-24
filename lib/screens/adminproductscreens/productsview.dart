import 'package:cached_network_image/cached_network_image.dart';
import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/screens/adminproductscreens/addproductscreen.dart';
import 'package:electrical_store_mobile_app/screens/adminproductscreens/updateproductscreen.dart';
import 'package:electrical_store_mobile_app/screens/user/profilescreen.dart';
import 'package:flutter/material.dart';
import '../../logic/models/product.dart';
import '../../logic/controller/product_controller.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ProductController _controller = ProductController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    _products = await _controller.readAllProducts(userId: '');
    _filteredProducts = List.from(_products);
    setState(() => _loading = false);
  }

  Future<void> _deleteProduct(String id) async {
    await _controller.deleteProduct(id);
    await _loadProducts();
  }

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = await _controller.searchProducts(query, userId: '');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("لوحة تحكم المنتجات", style: TextStyle(color: kBackgroundColor)),
        backgroundColor: kPrimaryColor,
          actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_rounded,color: kBackgroundColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "ابحث عن منتج أو تصنيف",
                prefixIcon: Icon(Icons.search,color: kPrimaryColor,),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchProducts,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text("لا توجد منتجات"))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true) await _loadProducts();
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: p.image.contains('assets/')
                  ? Image.asset(p.image, fit: BoxFit.contain)
                  : CachedNetworkImage(
                      imageUrl: p.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(p.subTitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text(p.category, style: const TextStyle(color: kSecondaryColor)),
                Text("${p.price} \$", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: kPrimaryColor),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProductScreen(product: p)),
                        );
                        if (result == true) await _loadProducts();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("تأكيد الحذف"),
                            content: Text("هل تريد حذف المنتج \"${p.title}\"؟"),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("لا")),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("نعم")),
                            ],
                          ),
                        );
                        if (confirmed == true) await _deleteProduct(p.id!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
