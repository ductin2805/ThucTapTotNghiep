import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final _codeCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'Cái');
  final _categoryCtrl = TextEditingController(text: 'Mặc định');
  final _noteCtrl = TextEditingController();
  bool _applyTax = false;

  final ImagePicker _picker = ImagePicker();
  String? _imgPath;

  // formatter tiền VNĐ
  final _currencyFormatter = NumberFormat("#,##0", "vi_VN");

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _codeCtrl.dispose();
    _barcodeCtrl.dispose();
    _costPriceCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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

      final rawPrice = _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(rawPrice) ?? 0;

      final rawCost = _costPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      final costPrice = double.tryParse(rawCost) ?? 0;

      final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

      final p = Product(
        name: name,
        price: price,
        costPrice: costPrice,
        stock: stock,
        code: _codeCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim(),
        unit: _unitCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
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
                      ? const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey))
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

              // tên sản phẩm (gõ tiếng Việt thoải mái)
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên mặt hàng'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
              ),

              // mã mặt hàng
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã mặt hàng'),
              ),

              // barcode (chỉ số)
              TextFormField(
                controller: _barcodeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),

              // giá nhập (VNĐ)
              TextFormField(
                controller: _costPriceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final formatted = _currencyFormatter.format(int.parse(raw));
                    return newValue.copyWith(
                      text: formatted,
                      selection:
                      TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                decoration: const InputDecoration(labelText: 'Giá nhập (VNĐ)'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập giá nhập' : null,
              ),

              // đơn vị tính
              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(labelText: 'Đơn vị tính'),
              ),

              // danh mục
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),

              // áp dụng thuế
              SwitchListTile(
                value: _applyTax,
                onChanged: (v) => setState(() => _applyTax = v),
                title: const Text("Áp dụng thuế"),
              ),

              // ghi chú
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                maxLines: 2,
              ),

              // giá bán VNĐ
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final formatted = _currencyFormatter.format(int.parse(raw));
                    return newValue.copyWith(
                      text: formatted,
                      selection:
                      TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập giá' : null,
              ),

              // tồn kho
              TextFormField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
