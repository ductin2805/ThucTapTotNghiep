import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../utils/format.dart';

class ProductEditPage extends StatefulWidget {
  final Product? product;
  const ProductEditPage({super.key, this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = ProductRepository();

  late TextEditingController _name;
  late TextEditingController _code;
  late TextEditingController _barcode;
  late TextEditingController _price;
  late TextEditingController _costPrice;
  late TextEditingController _stock;
  late TextEditingController _unit;
  late TextEditingController _note;
  late TextEditingController _categoryId;

  bool _tax = false;
  String? _imgPath;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? "");
    _code = TextEditingController(text: p?.code ?? "");
    _barcode = TextEditingController(text: p?.barcode ?? "");
    _price = TextEditingController(text: formatCurrency(p?.price ?? 0));
    _costPrice = TextEditingController(text: formatCurrency(p?.costPrice ?? 0));
    _stock = TextEditingController(text: p?.stock.toString() ?? "0");
    _unit = TextEditingController(text: p?.unit ?? "Cái");
    _note = TextEditingController(text: p?.note ?? "");
    _categoryId = TextEditingController(text: p?.categoryId?.toString() ?? "");
    _tax = (p?.tax ?? 0) == 1;
    _imgPath = p?.img;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imgPath = picked.path);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _name.text,
        code: _code.text,
        barcode: _barcode.text,
        price: double.tryParse(_price.text.replaceAll('.', '')) ?? 0,
        costPrice: double.tryParse(_costPrice.text.replaceAll('.', '')) ?? 0,
        stock: int.tryParse(_stock.text) ?? 0,
        unit: _unit.text,
        categoryId: int.tryParse(_categoryId.text),
        tax: _tax ? 1 : 0,
        note: _note.text,
        img: _imgPath,
      );

      if (widget.product == null) {
        await _repo.addProduct(product);
      } else {
        await _repo.updateProduct(product);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  void _delete() async {
    if (widget.product != null) {
      await _repo.deleteProduct(widget.product!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa mặt hàng" : "Thêm mặt hàng"),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imgPath != null ? FileImage(File(_imgPath!)) : null,
                  child: _imgPath == null
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Tên mặt hàng"),
              validator: (v) => v!.isEmpty ? "Nhập tên mặt hàng" : null,
            ),
            TextFormField(
              controller: _code,
              decoration: const InputDecoration(labelText: "Mã mặt hàng"),
            ),
            TextFormField(
              controller: _barcode,
              decoration: const InputDecoration(
                labelText: "Barcode",
                suffixIcon: Icon(Icons.qr_code_scanner),
              ),
            ),
            TextFormField(
              controller: _stock,
              decoration: const InputDecoration(labelText: "Số lượng tồn"),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _unit,
              decoration: const InputDecoration(labelText: "Đơn vị tính"),
            ),
            TextFormField(
              controller: _categoryId,
              decoration: const InputDecoration(labelText: "Mã danh mục (categoryId)"),
              keyboardType: TextInputType.number,
            ),

            SwitchListTile(
              title: const Text("Áp dụng thuế"),
              value: _tax,
              onChanged: (val) => setState(() => _tax = val),
            ),

            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: "Ghi chú"),
              maxLines: 2,
            ),

            if (isEdit) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Xóa"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}