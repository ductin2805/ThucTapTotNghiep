import 'package:flutter/material.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import 'customer_form_page.dart';
import 'dart:io';

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final CustomerRepository repo = CustomerRepository();
  List<Customer> customers = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    await repo.ensureDefaultCustomer(); // đảm bảo có khách lẻ trong DB
    final data = await repo.fetchCustomers();
    setState(() => customers = data);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = customers.where((c) {
      final q = query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Khách hàng"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CustomerFormPage()),
              );
              _load();
            },
          )
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Nhập tên, số điện thoại, email",
            ),
            onChanged: (val) => setState(() => query = val),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final c = filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (c.imagePath != null && c.imagePath!.isNotEmpty)
                        ? FileImage(File(c.imagePath!))
                        : null,
                    child: (c.imagePath == null || c.imagePath!.isEmpty)
                        ? Icon(Icons.person)
                        : null,
                  ),
                  title: Text(c.name),
                  subtitle: Text("${c.phone}\n${c.address ?? ''}"),
                  isThreeLine: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerFormPage(customer: c),
                      ),
                    );
                    _load();
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
