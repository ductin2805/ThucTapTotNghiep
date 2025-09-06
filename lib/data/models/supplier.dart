class Supplier {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? address;
  String? note;
  String? logoPath;

  Supplier({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.note,
    this.logoPath,
  });

  // toMap & fromMap nếu bạn dùng SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'note': note,
      'logoPath': logoPath,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      note: map['note'],
      logoPath: map['logoPath'],
    );
  }
}
