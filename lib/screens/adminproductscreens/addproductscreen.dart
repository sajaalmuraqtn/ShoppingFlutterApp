import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';
import 'package:flutter/material.dart';
import '../../logic/controller/product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final subTitle = TextEditingController();
  final description = TextEditingController();
  final image = TextEditingController();
  final price = TextEditingController();

  final ProductController controller = ProductController();

  final List<String> categories = [
    "الإلكترونيات والأجهزة",
    "الأزياء والملابس",
    "المنزل والمطبخ",
    "الجمال والعناية الشخصية",
    "الكتب والوسائط",
  ];

  String? selectedCategory;

  void addproduct() async {
    if (!_formKey.currentState!.validate()) return;

    Product p = Product(
      title: title.text,
      subTitle: subTitle.text,
      description: description.text,
      price: int.parse(price.text),
      image: image.text,
      category: selectedCategory!,
    );

    await controller.createProduct(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تمت إضافة منتج بنجاح"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      appBar: AppBar(
        title: const Text(
          "إضافة منتج",
          style: TextStyle(color: kBackgroundColor),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: "العنوان"),
                validator: (value) =>
                    value == null || value.isEmpty ? "العنوان مطلوب" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: subTitle,
                decoration: const InputDecoration(labelText: "العنوان الفرعي"),
                validator: (value) => value == null || value.isEmpty
                    ? "العنوان الفرعي مطلوب"
                    : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: description,
                decoration: const InputDecoration(labelText: "الوصف"),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? "الوصف مطلوب" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: image,
                decoration: const InputDecoration(labelText: "رابط الصورة"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "الرجاء إدخال رابط الصورة";

                  // تحقق إذا كان رابط URL صالح
                  final uri = Uri.tryParse(value);
                  if ((uri?.isAbsolute ?? false) || value.contains('assets/')) {
                    return null; // رابط صالح
                  }

                  return "رابط الصورة غير صالح، يجب أن يكون URL أو مسار assets/";
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: price,
                decoration: const InputDecoration(labelText: "السعر"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "السعر مطلوب";
                  if (int.tryParse(value) == null)
                    return "السعر يجب أن يكون رقم";
                  return null;
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "التصنيف"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) => value == null ? "يجب اختيار تصنيف" : null,
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: addproduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "إضافة",
                  style: TextStyle(color: kBackgroundColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
