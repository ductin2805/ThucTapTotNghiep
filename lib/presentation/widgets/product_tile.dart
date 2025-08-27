import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductTile({super.key, required this.product, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('Giá: ${product.price.toStringAsFixed(0)}đ • Tồn: ${product.stock}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.edit, size: 20),
            tooltip: 'Sửa / cập nhật tồn'),
        IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Xóa'),
      ]),
    );
  }
}
