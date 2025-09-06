import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../utils/format.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: product.img != null && product.img!.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(product.img!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      )
          : const Icon(Icons.image, size: 40, color: Colors.grey),

      title: Text(product.name),

      // ✅ dùng formatCurrency cho giá
      subtitle: Text(
        "Giá: ${formatCurrency(product.price)} • Tồn: ${product.stock}"" " "${product.unit}",
        style: const TextStyle(color: Colors.black54),
      ),

      onTap: onTap,

      // nút xoá
      trailing: onDelete != null
          ? IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      )
          : null,
    );
  }
}
