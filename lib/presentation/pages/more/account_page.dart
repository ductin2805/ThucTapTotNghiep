import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/store_info.dart';
import '../../../data/repositories/store_info_repository.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final repo = StoreInfoRepository();

  File? _logo;
  final picker = ImagePicker();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _otherController = TextEditingController();

  StoreInfo? currentInfo;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  Future<void> _pickLogo() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    final info = StoreInfo(
      id: currentInfo?.id,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      website: _websiteController.text,
      other: _otherController.text,
      logoPath: _logo?.path,
    );

    if (currentInfo == null) {
      await repo.insertStoreInfo(info);
    } else {
      await repo.updateStoreInfo(info);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu thông tin cửa hàng")),
    );
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    final info = await repo.getStoreInfo();
    if (info != null) {
      setState(() {
        currentInfo = info;
        _nameController.text = info.name ?? "";
        _phoneController.text = info.phone ?? "";
        _emailController.text = info.email ?? "";
        _addressController.text = info.address ?? "";
        _websiteController.text = info.website ?? "";
        _otherController.text = info.other ?? "";
        if (info.logoPath != null) {
          _logo = File(info.logoPath!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản"),
        actions: [
          TextButton(
            onPressed: _saveData,
            child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _logo != null ? FileImage(_logo!) : null,
                  child: _logo == null
                      ? const Icon(Icons.add_a_photo, size: 32, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Tên cửa hàng", _nameController),
              _buildTextField("Số điện thoại", _phoneController),
              _buildTextField("Email", _emailController),
              _buildTextField("Địa chỉ", _addressController),
              _buildTextField("Website", _websiteController),
              _buildTextField("Khác", _otherController, maxLines: 3),
              const SizedBox(height: 10),
              const Text(
                "Lưu ý: Các thông tin trên sẽ được hiển thị trên hóa đơn khi in hoặc gửi",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
