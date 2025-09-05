class Unit {
  final int? id;
  final String name;

  Unit({
    this.id,
    required this.name,
  });

  Unit copyWith({int? id, String? name}) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }
}
