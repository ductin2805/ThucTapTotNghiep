class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? note;
  final String? imagePath;
  final bool isDefault;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.note,
    this.imagePath,
    this.isDefault = false,
  });

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    String? imagePath,
    bool? isDefault,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'note': note,
      'imagePath': imagePath,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      note: map['note'],
      imagePath: map['imagePath'],
    );
  }
}
