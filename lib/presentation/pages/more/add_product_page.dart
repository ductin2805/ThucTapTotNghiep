import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/category_provider.dart';   // ✅ provider danh mục
import '../../../providers/unit_provider.dart';       // ✅ provider đơn vị
import '../../../utils/format.dart';

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
  final _codeCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _unit;
  int? _selectedCategoryId;
  bool _applyTax = false;

  final ImagePicker _picker = ImagePicker();
  String? _imgPath;
  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _codeCtrl.dispose();
    _barcodeCtrl.dispose();
    _costPriceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imgPath = picked.path);
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final p = Product(
        name: _nameCtrl.text.trim(),
        price: parseCurrency(_priceCtrl.text),
        costPrice: parseCurrency(_costPriceCtrl.text),
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        code: _codeCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim(),
        unit: _unit ?? "Cái",
        categoryId: _selectedCategoryId,
        note: _noteCtrl.text.trim(),
        tax: _applyTax ? 1 : 0,
        img: _imgPath,
      );

      await ref.read(productListProvider.notifier).add(p);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider); // ✅ lấy danh mục
    final units = ref.watch(unitListProvider);          // ✅ lấy đơn vị

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm mặt hàng'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Lưu', style: TextStyle(color: Colors.blue)),
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
                      ? const Icon(Icons.image, size: 40, color: Colors.grey)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_imgPath!), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên mặt hàng'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
              ),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã mặt hàng'),
              ),
              TextFormField(
                controller: _barcodeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),

              // ✅ giá nhập
              TextFormField(
                controller: _costPriceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: const InputDecoration(labelText: 'Giá nhập (VNĐ)'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập giá nhập' : null,
              ),

              // ✅ giá bán
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: const InputDecoration(labelText: 'Giá bán (VNĐ)'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập giá' : null,
              ),

              // ✅ dropdown đơn vị (query từ DB)
              DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(labelText: "Đơn vị tính"),
                items: units.when(
                  data: (list) => list
                      .map((u) =>
                      DropdownMenuItem(value: u.name, child: Text(u.name)))
                      .toList(),
                  loading: () => [],
                  error: (_, __) => [],
                ),
                onChanged: (val) => setState(() => _unit = val),
                validator: (v) => v == null ? "Chọn đơn vị" : null,
              ),

              // ✅ dropdown danh mục (query từ DB)
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: "Danh mục"),
                items: categories.when(
                  data: (list) => list
                      .map((c) => DropdownMenuItem(
                      value: c.id, child: Text(c.name)))
                      .toList(),
                  loading: () => [],
                  error: (_, __) => [],
                ),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (v) => v == null ? "Chọn danh mục" : null,
              ),

              SwitchListTile(
                value: _applyTax,
                onChanged: (v) => setState(() => _applyTax = v),
                title: const Text("Áp dụng thuế"),
              ),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
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
