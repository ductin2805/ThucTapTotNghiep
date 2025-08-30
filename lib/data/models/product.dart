class Product {
  final int? id;
  final String name;
  final String? code;       // mã mặt hàng
  final String? barcode;    // barcode
  final double price;       // giá bán
  final double costPrice;   // giá nhập
  final int stock;          // số lượng tồn
  final String unit;        // đơn vị tính
  final String category;    // danh mục
  final int tax;            // 0 = không áp dụng, 1 = có áp dụng
  final String? note;       // ghi chú
  final String? img;        // ảnh

  Product({
    this.id,
    required this.name,
    this.code,
    this.barcode,
    required this.price,
    this.costPrice = 0,
    required this.stock,
    this.unit = "Cái",
    this.category = "Mặc định",
    this.tax = 0,
    this.note,
    this.img,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'barcode': barcode,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'unit': unit,
      'category': category,
      'tax': tax,
      'note': note,
      'img': img,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      barcode: map['barcode'],
      price: (map['price'] as num).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      unit: map['unit'] ?? "Cái",
      category: map['category'] ?? "Mặc định",
      tax: map['tax'] ?? 0,
      note: map['note'],
      img: map['img'],
    );
  }
}
