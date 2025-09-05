import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dao/customer_dao.dart';
import '../../../data/models/customer.dart';
import '../../../providers/cart_provider.dart';
import '../../pages/more/customer_form_page.dart'; // đảm bảo file này tồn tại

// Provider để load danh sách khách từ DB
final customersProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  return CustomerDao().getAll();
});

class SelectCustomerPage extends ConsumerWidget {
  const SelectCustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn khách hàng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // NOTE: nếu CustomerFormPage constructor không phải const -> gọi không const
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CustomerFormPage()),
              );
              // reload lại danh sách khách sau khi quay về
              ref.refresh(customersProvider);
            },
          ),
        ],
      ),
      body: customersAsync.when(
        data: (customers) {
          return ListView(
            children: [
              // Khách lẻ mặc định
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage("assets/img/default_user.png"),
                ),
                title: const Text("Khách lẻ"),
                onTap: () {
                  // Đặt customer = null nghĩa là Khách lẻ
                  ref.read(cartProvider.notifier).setCustomer(null);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              // Danh sách khách từ DB
              ...customers.map(
                    (c) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (c.imagePath != null && c.imagePath!.isNotEmpty)
                        ? FileImage(File(c.imagePath!))
                        : const AssetImage("assets/img/default_user.png") as ImageProvider,
                  ),
                  title: Text(c.name),
                  subtitle: Text("${c.phone}\n${c.address ?? ''}"),
                  isThreeLine: true,
                  onTap: () {
                    ref.read(cartProvider.notifier).setCustomer(c);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Lỗi khi tải khách hàng: $e")),
      ),
    );
  }
}
