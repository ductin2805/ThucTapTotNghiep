import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/supplier_repository.dart';
import 'supplier_form_page.dart';

class SupplierListPage extends StatefulWidget {
  const SupplierListPage({super.key});

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  final SupplierRepository repo = SupplierRepository();
  List<Supplier> suppliers = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  void _loadSuppliers() async {
    final data = await repo.getSuppliers();
    setState(() => suppliers = data);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = suppliers.where((s) {
      final q = query.toLowerCase();
      return (s.name ?? "").toLowerCase().contains(q) ||
          (s.phone ?? "").toLowerCase().contains(q) ||
          (s.email ?? "").toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhà cung cấp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupplierFormPage()),
              );
              _loadSuppliers();
            },
          )
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Nhập tên, số điện thoại, email",
            ),
            onChanged: (val) => setState(() => query = val),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final s = filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (s.logoPath != null && s.logoPath!.isNotEmpty)
                        ? (s.logoPath!.startsWith("/") // nếu path là file
                        ? FileImage(File(s.logoPath!))
                        : AssetImage(s.logoPath!) as ImageProvider)
                        : null,
                    child: (s.logoPath == null || s.logoPath!.isEmpty)
                        ? const Icon(Icons.store)
                        : null,
                  ),
                  title: Text(s.name ?? ""),
                  subtitle: Text("${s.phone ?? ''}\n${s.address ?? ''}"),
                  isThreeLine: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SupplierFormPage(supplier: s),
                      ),
                    );
                    _loadSuppliers();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
