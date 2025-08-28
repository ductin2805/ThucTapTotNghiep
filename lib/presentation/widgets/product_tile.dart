import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';

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
      subtitle: Text("Giá: ${product.price} đ - Tồn: ${product.stock}"),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}
