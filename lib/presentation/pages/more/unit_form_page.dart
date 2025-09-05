import 'package:flutter/material.dart';
import '../../../data/models/unit.dart';
import '../../../data/dao/unit_dao.dart';

class UnitFormPage extends StatefulWidget {
  final Unit? unit;
  const UnitFormPage({super.key, this.unit});

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.unit != null) {
      _nameController.text = widget.unit!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit == null ? "Thêm đơn vị" : "Sửa đơn vị"),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tên đơn vị không được trống")),
                );
                return;
              }

              if (widget.unit == null) {
                await UnitDao().insert(
                  Unit(
                    name: _nameController.text.trim(),
                  ),
                );
              } else {
                await UnitDao().update(
                  widget.unit!.copyWith(
                    name: _nameController.text.trim(),
                  ),
                );
              }

              Navigator.pop(context, true);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Tên đơn vị"),
        ),
      ),
    );
  }
}
