import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? customer;
  CustomerFormPage({this.customer});

  @override
  _CustomerFormPageState createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final repo = CustomerRepository();

  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _address;
  late TextEditingController _note;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.customer?.name ?? '');
    _phone = TextEditingController(text: widget.customer?.phone ?? '');
    _email = TextEditingController(text: widget.customer?.email ?? '');
    _address = TextEditingController(text: widget.customer?.address ?? '');
    _note = TextEditingController(text: widget.customer?.note ?? '');
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final c = Customer(
        id: widget.customer?.id,
        name: _name.text,
        phone: _phone.text,
        email: _email.text,
        address: _address.text,
        note: _note.text,
        imagePath: _imageFile?.path ?? widget.customer?.imagePath,
      );
      if (widget.customer == null) {
        await repo.addCustomer(c);
      } else {
        await repo.updateCustomer(c);
      }
      Navigator.pop(context);
    }
  }

  void _delete() async {
    if (widget.customer != null) {
      await repo.deleteCustomer(widget.customer!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Sửa khách hàng" : "Thêm khách hàng"),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text("Lưu", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // phần chọn ảnh
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: _imageFile != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_imageFile!),
                )
                    : (widget.customer?.imagePath != null &&
                    widget.customer!.imagePath!.isNotEmpty)
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  FileImage(File(widget.customer!.imagePath!)),
                )
                    : CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.camera_alt, size: 30),
                ),
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: "Tên khách hàng"),
              validator: (v) => v == null || v.isEmpty ? "Nhập tên" : null,
            ),
            TextFormField(
              controller: _phone,
              decoration: InputDecoration(labelText: "Số điện thoại"),
              validator: (v) =>
              v == null || v.isEmpty ? "Nhập số điện thoại" : null,
            ),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: _address,
              decoration: InputDecoration(labelText: "Địa chỉ"),
            ),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: "Ghi chú"),
            ),
            if (isEditing)
              TextButton(
                onPressed: _delete,
                child: Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
