class Product {
  final int? id;
  final String name;
  final String? code;       // mã mặt hàng
  final String? barcode;    // barcode
  final double price;       // giá bán
  final double costPrice;   // giá nhập
  final int stock;          // số lượng tồn
  final String unit;        // đơn vị tính
  int? categoryId;
  final int tax;            // 0 = không áp dụng, 1 = có áp dụng
  final String? note;       // ghi chú
  final String? img;        // ảnh
  bool isFavorite;

  Product({
    this.id,
    required this.name,
    this.code,
    this.barcode,
    required this.price,
    this.costPrice = 0,
    required this.stock,
    this.unit = "Cái",
    this.categoryId,
    this.tax = 0,
    this.note,
    this.img,
    this.isFavorite = false,
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
      'categoryId': categoryId,
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
      categoryId: map['categoryId'] ?? "Mặc định",
      tax: map['tax'] ?? 0,
      note: map['note'],
      img: map['img'],
    );
  }

  /// ✅ Hàm copyWith để cập nhật các field cần thay đổi
  Product copyWith({
    int? id,
    String? name,
    String? code,
    String? barcode,
    double? price,
    double? costPrice,
    int? stock,
    String? unit,
    String? category,
    int? tax,
    String? note,
    String? img,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      tax: tax ?? this.tax,
      note: note ?? this.note,
      img: img ?? this.img,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
