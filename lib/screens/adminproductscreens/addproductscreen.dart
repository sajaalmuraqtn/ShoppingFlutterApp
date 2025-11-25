import 'dart:io';
import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/models/product.dart';
import 'package:electrical_store_mobile_app/logic/controller/product_controller.dart';
import 'package:flutter/material.dart';
 
import 'package:image_picker/image_picker.dart';
 
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
  final price = TextEditingController();

  File? selectedImage;

  final ProductController controller = ProductController();

  final List<String> categories = [
    "الإلكترونيات والأجهزة",
    "الأزياء والملابس",
    "المنزل والمطبخ",
    "الجمال والعناية الشخصية",
    "الكتب والوسائط",
  ];

  String? selectedCategory;

   Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

 
 void addProduct() async {

  if (!_formKey.currentState!.validate()) return;

  if (selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("الرجاء اختيار صورة للمنتج")),
    );
    return;
  }

  Product p = Product(
    title: title.text,
    subTitle: subTitle.text,
    description: description.text,
    price: int.parse(price.text),
    image: "", // سيتم تحديثها داخل createProduct بعد رفع الصورة
    category: selectedCategory!,
  );

  try {
    await controller.createProduct(p, selectedImage);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تمت إضافة المنتج بنجاح"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("فشل إضافة المنتج: $e") ,backgroundColor: Colors.red,),
    );
  }
}

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("إضافة منتج", style: TextStyle(color: Colors.white)),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: price,
                decoration: const InputDecoration(labelText: "السعر"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "السعر مطلوب";
                  if (int.tryParse(value) == null) return "السعر يجب أن يكون رقم";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "التصنيف"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) => value == null ? "يجب اختيار تصنيف" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text("رفع صورة", style: TextStyle(color: kPrimaryColor)),
                  ),
                  const SizedBox(width: 15),
                  if (selectedImage != null)
                    const Text("✔ تم اختيار صورة", style: TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "إضافة",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
