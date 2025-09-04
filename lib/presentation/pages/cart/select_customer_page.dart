import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dao/customer_dao.dart';
import '../../../data/models/customer.dart';
import '../../../providers/cart_provider.dart';

class SelectCustomerPage extends ConsumerWidget {
  const SelectCustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chọn khách hàng")),
      body: FutureBuilder<List<Customer>>(
        future: CustomerDao().getAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data!;

          return ListView(
            children: [
              // Danh sách khách hàng
              ...customers.map((c) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: (c.imagePath != null &&
                      c.imagePath!.isNotEmpty)
                      ? FileImage(File(c.imagePath!))
                      : const AssetImage("assets/img/default_user.png")
                  as ImageProvider,
                ),
                title: Text(c.name),
                subtitle: Text(
                  "${c.phone}\n${c.address ?? ''}",
                ),
                isThreeLine: true,
                onTap: () {
                  ref.read(cartProvider.notifier).setCustomer(c);
                  Navigator.pop(context);
                },
              )),
            ],
          );
        },
      ),
    );
  }
}
