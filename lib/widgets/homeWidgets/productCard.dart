import 'package:flutter/material.dart';
import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/controller/likecontroller.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/user_session.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatefulWidget {
  final int itemIndex;
  final Product product;
  final Function() onPressed;
  final Future<void> Function() onLikeChanged;

  const ProductCard({
    super.key,
    required this.itemIndex,
    required this.product,
    required this.onPressed,
    required this.onLikeChanged,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool checkingLocalLike = true;
  late bool isLiked;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.7,
      upperBound: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _initLikeStatus(); // 🔥 تهيئة حالة اللايك وعدد اللايكات
  }

  // --------------------------------------------
  // 🔥 تهيئة حالة اللايك وعدد اللايكات
  // --------------------------------------------
  Future<void> _initLikeStatus() async {
    final userId = await UserSession.getUserId();

    // ⚠️ تحقق من أن product.id ليس null
    if (widget.product.id == null) {
      likesCount = 0;
      isLiked = false;
      setState(() {
        checkingLocalLike = false;
      });
      return;
    }

    // عدد اللايكات للمنتج
    likesCount = await LikeController.getProductLikesCount(widget.product.id!);

    // حالة اللايك الخاصة بالمستخدم إذا مسجّل دخول
    if (userId != null) {
      isLiked = await LikeController.isProductLiked(userId, widget.product.id!);
    } else {
      isLiked = false;
    }

    setState(() {
      checkingLocalLike = false;
    });
  }

  // --------------------------------------------
  // ❤️ عند الضغط على زر Like
  // --------------------------------------------
  void onLikePressed() async {
    _controller.forward().then((value) => _controller.reverse());

    // تنفيذ تغيير اللايك من HomeScreen
    await widget.onLikeChanged();

    // إعادة تحديث عدد اللايكات وحالة اللايك
    await _initLikeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---------------------- CARD ----------------------
        InkWell(
          onTap: widget.onPressed,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: 10,
            ),
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // IMAGE
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: widget.product.image.contains('assets/')
                        ? Image.asset(widget.product.image, fit: BoxFit.cover)
                        : CachedNetworkImage(
                            imageUrl: widget.product.image,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // INFO
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(widget.product.subTitle),
                        Text(
                          widget.product.category,
                          style: const TextStyle(color: kSecondaryColor),
                        ),
                        Text(
                          "السعر: ${widget.product.price}\$",
                          style: const TextStyle(color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---------------------- LIKE BUTTON + COUNT ----------------------
        Positioned(
          top: 10,
          left: 25,
          child: checkingLocalLike
              ? const CircularProgressIndicator(strokeWidth: 2)
              : FutureBuilder<bool>(
                  future: UserSession.isLoggedIn(),
                  builder: (context, snapshot) {
                    final loggedIn = snapshot.data ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          // 🔥 عدد اللايكات يظهر دائمًا
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              likesCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // ❤️ القلب
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: GestureDetector(
                              onTap: loggedIn
                                  ? onLikePressed
                                  : null, // الضغط فقط عند تسجيل الدخول
                              child: Icon(
                                loggedIn
                                    ? (isLiked
                                          ? Icons.favorite
                                          : Icons
                                                .favorite_border) // إذا مسجل دخول
                                    : Icons
                                          .favorite, // إذا غير مسجل دخول → دائمًا أحمر
                                color: loggedIn
                                    ? (isLiked
                                          ? Colors.red
                                          : Colors.grey) // مستخدم مسجل
                                    : Colors.red, // غير مسجل → أحمر دائمًا
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
