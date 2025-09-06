import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../data/dao/category_dao.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category; // nếu có => sửa, nếu null => thêm

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nameController = TextEditingController();
  int? _parentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _parentId = widget.category!.parentId;
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tên nhóm không được để trống")),
      );
      return;
    }

    setState(() => _isSaving = true);

    if (widget.category == null) {
      // thêm mới
      final newCategory = Category(
        name: _nameController.text.trim(),
        parentId: _parentId,
      );
      await CategoryDao().insert(newCategory);
    } else {
      // cập nhật
      final updated = widget.category!.copyWith(
        name: _nameController.text.trim(),
        parentId: _parentId,
      );
      await CategoryDao().update(updated);
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context, true); // trả về true để reload list
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Sửa nhóm mặt hàng" : "Thêm nhóm mặt hàng"),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text("Lưu"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Tên nhóm"),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Category>>(
              future: CategoryDao().getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                final list = snapshot.data!;
                return DropdownButtonFormField<int>(
                  value: _parentId,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text("Không thuộc nhóm nào"),
                    ),
                    ...list.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _parentId = val;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Thuộc nhóm"),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
