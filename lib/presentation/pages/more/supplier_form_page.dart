import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/supplier_repository.dart';

class SupplierFormPage extends StatefulWidget {
  final Supplier? supplier;
  const SupplierFormPage({super.key, this.supplier});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();
  final repo = SupplierRepository();

  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _address;
  late TextEditingController _note;

  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.supplier?.name ?? '');
    _phone = TextEditingController(text: widget.supplier?.phone ?? '');
    _email = TextEditingController(text: widget.supplier?.email ?? '');
    _address = TextEditingController(text: widget.supplier?.address ?? '');
    _note = TextEditingController(text: widget.supplier?.note ?? '');
    if (widget.supplier?.logoPath != null &&
        widget.supplier!.logoPath!.isNotEmpty) {
      _logoFile = File(widget.supplier!.logoPath!);
    }
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final s = Supplier(
        id: widget.supplier?.id,
        name: _name.text,
        phone: _phone.text,
        email: _email.text,
        address: _address.text,
        note: _note.text,
        logoPath: _logoFile?.path ?? widget.supplier?.logoPath,
      );

      if (widget.supplier == null) {
        await repo.insertSupplier(s);
      } else {
        await repo.updateSupplier(s);
      }
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    if (widget.supplier != null) {
      await repo.deleteSupplier(widget.supplier!.id!);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Sửa nhà cung cấp" : "Thêm nhà cung cấp"),
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
            // chọn logo
            GestureDetector(
              onTap: _pickLogo,
              child: Center(
                child: _logoFile != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_logoFile!),
                )
                    : (widget.supplier?.logoPath != null &&
                    widget.supplier!.logoPath!.isNotEmpty)
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  FileImage(File(widget.supplier!.logoPath!)),
                )
                    : const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.store, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _name,
              decoration:
              const InputDecoration(labelText: "Tên nhà cung cấp"),
              validator: (v) => v == null || v.isEmpty ? "Nhập tên" : null,
            ),
            TextFormField(
              controller: _phone,
              decoration:
              const InputDecoration(labelText: "Số điện thoại"),
              validator: (v) =>
              v == null || v.isEmpty ? "Nhập số điện thoại" : null,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: "Địa chỉ"),
            ),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: "Ghi chú"),
            ),
            if (isEditing)
              TextButton(
                onPressed: _delete,
                child: const Text("Xóa",
                    style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
