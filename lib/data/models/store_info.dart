class StoreInfo {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? address;
  String? website;
  String? other;
  String? logoPath;

  StoreInfo({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.other,
    this.logoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'other': other,
      'logoPath': logoPath,
    };
  }

  factory StoreInfo.fromMap(Map<String, dynamic> map) {
    return StoreInfo(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      website: map['website'],
      other: map['other'],
      logoPath: map['logoPath'],
    );
  }
}
