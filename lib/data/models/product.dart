class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final String? img; // thêm trường ảnh

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.img,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'img': img,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stock: map['stock'],
      img: map['img'],
    );
  }
}
