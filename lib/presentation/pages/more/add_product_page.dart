import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');

  final ImagePicker _picker = ImagePicker();
  String? _imgPath;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // mở gallery; nếu muốn camera thì dùng ImageSource.camera
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _imgPath = picked.path;
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text.trim();
      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
      final p = Product(name: name, price: price, stock: stock, img: _imgPath);
      await ref.read(productListProvider.notifier).add(p);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm mặt hàng'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imgPath == null
                      ? const Center(child: Icon(Icons.image, size: 40, color: Colors.grey))
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imgPath!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên mặt hàng'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập giá' : null,
              ),
              TextFormField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số lượng tồn'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
