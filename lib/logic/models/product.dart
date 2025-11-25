class Product {
    String? id;
  final String title;
  final String subTitle;
  final String description;
  String image;
  final int price;
  final String category;
  final int syncStatus; //لفحص هي توجد تعديلات
  bool isLiked;

  Product({
      this.id,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    this.syncStatus = 0,
    this.isLiked = false,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        title: json["title"],
        subTitle: json["subTitle"],
        description: json["description"],
        image: json["image"],
        price: json["price"],
        category: json["category"],
        syncStatus: json["syncStatus"] ?? 0,
        isLiked: (json["isLiked"] ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "subTitle": subTitle,
        "description": description,
        "image": image,
        "price": price,
        "category": category,
        "syncStatus": syncStatus,
      };
}
