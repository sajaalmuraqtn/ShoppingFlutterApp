import 'dart:io';

import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/controller/product_controller.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController title;
  late TextEditingController subTitle;
  late TextEditingController description;
  late TextEditingController price;
  String? selectedCategory;
  File? selectedImage;

   Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  final ProductController controller = ProductController();
  final _formKey = GlobalKey<FormState>();

  final List<String> categories = [
    "الإلكترونيات والأجهزة",
    "الأزياء والملابس",
    "المنزل والمطبخ",
    "الجمال والعناية الشخصية",
    "الكتب والوسائط",
  ];

 
  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.product.title);
    subTitle = TextEditingController(text: widget.product.subTitle);
    description = TextEditingController(text: widget.product.description);
     price = TextEditingController(text: widget.product.price.toString());

    selectedCategory = widget.product.category;
  }

  void update() async {
  if (!_formKey.currentState!.validate()) return;
   
  Product updated = Product(
    id: widget.product.id,
    title: title.text,
    subTitle: subTitle.text,
    description: description.text,
    price: int.parse(price.text),
     image: widget.product.image, 
    category: selectedCategory!,
  );

  try {
     await controller.updateProduct(updated, selectedImage);

    // 3. رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم التعديل على المنتج بنجاح"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  } catch (e) {
    // التعامل مع الأخطاء (مثل فشل الرفع)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("فشل التعديل: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      appBar: AppBar(
        title: const Text(
          "تعديل المنتج",
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: Radius.circular(12),
                ),
                child: (() {
                  final img = widget.product.image;
                  if (img.contains('assets/')) {
                    return Image.asset(img, height: 250, fit: BoxFit.contain);
                  } else if (Uri.tryParse(img)?.hasAbsolutePath ?? false) {
                    return Image.network(img, height: 250, fit: BoxFit.contain);
                  } else {
                    // الصورة الافتراضية إذا الرابط غير صالح
                    return Container(
                      height: 250,
                      color: const Color.fromARGB(255, 209, 199, 199),
                      alignment: Alignment.center,
                      child: const Text(
                        "لا توجد صورة",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                    );
                  }
                })(),
              ),
              const SizedBox(height: 50),
               TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: "العنوان"),
                validator: (value) => value == null || value.isEmpty
                    ? "الرجاء إدخال العنوان"
                    : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: subTitle,
                decoration: const InputDecoration(labelText: "العنوان الفرعي"),
                validator: (value) => value == null || value.isEmpty
                    ? "الرجاء إدخال العنوان الفرعي"
                    : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: description,
                decoration: const InputDecoration(labelText: "الوصف"),
                validator: (value) => value == null || value.isEmpty
                    ? "الرجاء إدخال الوصف"
                    : null,
              ),
              const SizedBox(height: 10),

               TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "السعر"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "الرجاء إدخال السعر";
                  if (int.tryParse(value) == null)
                    return "السعر يجب أن يكون رقم صحيح";
                  return null;
                },
              ),
              const SizedBox(height: 10),

               DropdownButtonFormField(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "التصنيف"),
                items: categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) =>
                    value == null ? "الرجاء اختيار تصنيف" : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text(
                      "رفع صورة",
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                  const SizedBox(width: 15),
                  if (selectedImage != null)
                    const Text(
                      "✔ تم اختيار صورة",
                      style: TextStyle(color: Colors.green),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "تحديث",
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
